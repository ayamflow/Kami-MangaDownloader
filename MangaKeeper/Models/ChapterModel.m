//
//  ChapterModel.m
//  MangaKeeper
//
//  Created by Florian on 30/12/13.
//  Copyright (c) 2013 Florian Morel. All rights reserved.
//

#import "ChapterModel.h"
#import "DownloadItem.h"
#import "DownloadManager.h"
#import "ProgressDownloadQueue.h"

#define kStatusIdle @"Idle"
#define kStatusDownloading @"Downloading"
#define kStatusPaused @"Paused"
#define kStatusCompleted @"Completed"
#define kStatusFetchingData @"Fetching data"

@interface ChapterModel ()

@property (assign, nonatomic) BOOL isReady;

@end

@implementation ChapterModel

@synthesize downloadQueue;
@synthesize status;

- (void)addToDownloadQueue {
    if(self.downloadQueue == nil) {
        self.downloadQueue = [[ProgressDownloadQueue alloc] init];
        self.downloadQueue.title = self.title;
        self.downloadQueue.chapter = self;
    }
    [[DownloadManager sharedInstance] addQueue:self.downloadQueue];
    self.status = kStatusIdle;
}

- (void)download {
    // Fetch the chapters on a background thread
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSInvocationOperation *fetchChapterData = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(fetchData) object:nil];
    [fetchChapterData setCompletionBlock:^{
        [self performSelectorOnMainThread:@selector(dataFetched) withObject:nil waitUntilDone:YES];
    }];
    [queue addOperation:fetchChapterData];
}

- (void)fetchData {
    if([self.status isEqualToString:kStatusFetchingData]) return;
    self.status = kStatusFetchingData;
    self.pagesNumber = [self.mangaSite getPagesNumberForChapter:self];
    self.imagesURLs = [self.mangaSite getImagesURLsForChapter:self];
}

- (void)dataFetched {
    self.isReady = YES;
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    NSString *downloadDirectory = [userPreferences stringForKey:@"downloadDirectory"];
    NSString *chapterPath = [downloadDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", self.title]];

    BOOL isDir;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:chapterPath isDirectory:&isDir]) { // Pref download file + chapter title
        if(![fileManager createDirectoryAtPath:chapterPath withIntermediateDirectories:YES attributes:nil error:NULL]) {
            NSLog(@"Error: Create folder failed %@", chapterPath);
        }
    }

    [self.downloadQueue cancelAllOperations]; // Prevent doubles

    for(NSString *pageURL in self.imagesURLs) {
        DownloadItem *item = [[DownloadItem alloc] initWithURL:pageURL andDirectory:self.title];
        item.delegate = self;
        [self.downloadQueue addOperation:item];
    }

    self.status = kStatusDownloading;
}

#pragma DownloadQueueDelegate

- (void)resume {
    self.status = kStatusDownloading;
}

- (void)pause {
    self.status = kStatusPaused;
}

- (void)complete {
    self.status = kStatusCompleted;
}

- (void)progressDidUpdate:(CGFloat)progressPercent {
    CGFloat onePage = 1.0 / (CGFloat)self.pagesNumber;
    self.downloadQueue.progress = onePage * (self.pagesNumber - self.downloadQueue.operationCount) + progressPercent * onePage;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadNeedsUpdate" object:nil];
}

@end