//
//  DownloadItem.h
//  MangaKeeper
//
//  Created by Florian on 31/12/13.
//  Copyright (c) 2013 Florian Morel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadQueueDelegate.h"

@interface DownloadItem : NSOperation <NSURLConnectionDataDelegate>

@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *fileName;
@property (assign, nonatomic) CGFloat progress;
@property (weak, nonatomic) id<DownloadQueueDelegate> delegate;

- (id)initWithURL:(NSString *)url andDirectory:(NSString *)directory;
- (void)start;

@end
