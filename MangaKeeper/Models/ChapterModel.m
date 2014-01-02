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

@implementation ChapterModel

@synthesize downloadQueue;

- (void)download {
    self.pagesNumber = [self.mangaSite getPagesNumberForChapter:self];
    self.imagesURLs = [self.mangaSite getImagesURLsForChapter:self];
    
    NSLog(@"Downloading chapter %@ with %li pages.", self.title, self.pagesNumber);

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

    self.downloadQueue = [[ProgressDownloadQueue alloc] init];
    self.downloadQueue.title = self.title;
    for(NSString *pageURL in self.imagesURLs) {
        DownloadItem *item = [[DownloadItem alloc] initWithURL:pageURL andDirectory:self.title];
        item.delegate = self;
        [self.downloadQueue addOperation:item];
        [[DownloadManager sharedInstance] addQueue:self.downloadQueue];
    }
}

- (void)progressDidUpdate:(CGFloat)progressPercent {
    CGFloat onePage = 1.0 / (CGFloat)self.pagesNumber;
    self.downloadQueue.progress = onePage * (self.pagesNumber - self.downloadQueue.operationCount) + progressPercent * onePage;
}

@end