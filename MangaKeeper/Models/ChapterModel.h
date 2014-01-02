//
//  ChapterModel.h
//  MangaKeeper
//
//  Created by Florian on 30/12/13.
//  Copyright (c) 2013 Florian Morel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MangaSite.h"
#import "DownloadQueueDelegate.h"

@interface ChapterModel : NSObject <DownloadQueueDelegate>

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *host;
@property (strong, nonatomic) NSArray *imagesURLs;
@property (assign, nonatomic) NSInteger pagesNumber;
@property (strong, nonatomic) NSObject<MangaSite> *mangaSite;

- (void)download;

@end
