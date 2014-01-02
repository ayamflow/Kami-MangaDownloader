//
//  DownloadQueueDelegate.h
//  MangaKeeper
//
//  Created by Florian on 02/01/14.
//  Copyright (c) 2014 Florian Morel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProgressDownloadQueue.h"

@protocol DownloadQueueDelegate <NSObject>

@property (strong, nonatomic) ProgressDownloadQueue *downloadQueue;

- (void)progressDidUpdate:(CGFloat)progress;

@end
