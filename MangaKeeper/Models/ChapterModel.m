//
//  ChapterModel.m
//  MangaKeeper
//
//  Created by Florian on 30/12/13.
//  Copyright (c) 2013 Florian Morel. All rights reserved.
//

#import "ChapterModel.h"
#import "DownloadItem.h"

@implementation ChapterModel

- (void)download {
    self.pagesNumber = [self.mangaSite getPagesNumberForChapter:self];
    self.imagesURLs = [self.mangaSite getImagesURLsForChapter:self];
    
    NSLog(@"Downloading chapter %@ with %@ pages.", self.title, self.pagesNumber);

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

    for(NSString *pageURL in self.imagesURLs) {
        DownloadItem *item = [[DownloadItem alloc] initWithURL:pageURL andDirectory:self.title];
        [item start];
    }
}

@end
