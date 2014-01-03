//
//  DownloadQueueDelegate.h
//  MangaKeeper
//
//  Created by Florian on 02/01/14.
//  Copyright (c) 2014 Florian Morel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class  ProgressDownloadQueue;

@protocol DownloadQueueDelegate <NSObject>

@property (strong, nonatomic) ProgressDownloadQueue *downloadQueue;
@property (strong, nonatomic) NSString *status;

- (void)progressDidUpdate:(CGFloat)progress;
- (void)pause;
- (void)resume;
- (void)complete;
- (void)remove;

@end
