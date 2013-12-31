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
    
    DownloadItem *item = [[DownloadItem alloc] initWithURL:[self.imagesURLs objectAtIndex:0]];
    [item start];
}

@end
