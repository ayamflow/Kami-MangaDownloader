//
//  DownloadManagerDelegate.h
//  MangaKeeper
//
//  Created by Florian Morel on 04/01/14.
//  Copyright (c) 2014 Florian Morel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProgressDownloadQueue.h"

@protocol DownloadManagerDelegate <NSObject>

- (void)queueIsReadyToDownload:(ProgressDownloadQueue *)queue;

@end
