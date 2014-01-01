//
//  DownloadManager.h
//  MangaKeeper
//
//  Created by Florian Morel on 01/01/14.
//  Copyright (c) 2014 Florian Morel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadItem.h"
#import "DownloadItemDelegate.h"

@interface DownloadManager : NSObject <DownloadItemDelegate>

@property (assign, nonatomic) NSInteger connectionsNumber;

+ (id)sharedInstance;
- (void)start;
- (void)pause;
- (void)stop;
- (void)addToQueue:(DownloadItem *)item;
- (void)removeFromQueue:(DownloadItem *)item;

@end
