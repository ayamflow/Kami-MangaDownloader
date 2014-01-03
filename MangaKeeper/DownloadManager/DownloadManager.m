//
//  DownloadManager.m
//  MangaKeeper
//
//  Created by Florian Morel on 01/01/14.
//  Copyright (c) 2014 Florian Morel. All rights reserved.
//

#import "DownloadManager.h"
#import "DownloadItem.h"
#import "ProgressDownloadQueue.h"

@interface DownloadManager ()

@property (strong, nonatomic) ProgressDownloadQueue *currentQueue;

@end

@implementation DownloadManager

+ (id)sharedInstance {
    static DownloadManager *sharedInstance = nil;
    @synchronized(self) {
        if (sharedInstance == nil)
            sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

- (id)init {
    if(self = [super init]) {
        self.downloadQueues = [NSMutableArray array];
        self.isPaused = YES;
    }
    return self;
}

#pragma Flow control

- (void)resume {
    for(ProgressDownloadQueue *queue in self.downloadQueues) {
        [queue.chapter download];
    }

    if(self.currentQueue != nil) {
        [self.currentQueue setSuspended:NO];
        [self.currentQueue.chapter resume];
    }
    else if([self.downloadQueues count] > 0) {
        [self startNextQueue];
    }
    
    self.isPaused = NO;
}

- (void)pause {
    if(self.currentQueue == nil) return;
    [self.currentQueue setSuspended:YES];
    [self.currentQueue.chapter pause];
    
    self.isPaused = YES;
}

- (void)stop {
    [self.currentQueue removeObserver:self forKeyPath:@"operations"];
    self.currentQueue = nil;
    for(ProgressDownloadQueue *queue in self.downloadQueues) {
        [queue cancelAllOperations];
        [queue.chapter remove];
    }
    [self.downloadQueues removeAllObjects];
    
    self.isPaused = YES;
}

- (void)startNextQueue {
    if([self.downloadQueues count] == 0) return;
    self.currentQueue = [self.downloadQueues objectAtIndex:0];

    [self.currentQueue addObserver:self forKeyPath:@"operations" options:0 context:NULL];
    [self.currentQueue setSuspended:NO];
    [self.currentQueue.chapter resume];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(object == self.currentQueue && [keyPath isEqualToString:@"operations"]) {
        [self.currentQueue removeObserver:self forKeyPath:@"operations"];
        [self.downloadQueues removeObject:self.currentQueue];
        [self.currentQueue.chapter complete];
        [self startNextQueue];
    }
}

#pragma Add/remove

- (void)addQueue:(ProgressDownloadQueue *)queue {
    if([self.downloadQueues indexOfObject:queue] != NSNotFound) return;
    [queue setSuspended:YES];
    [self.downloadQueues addObject:queue];
}

- (void)removeQueue:(ProgressDownloadQueue *)queue {
    if([self.downloadQueues indexOfObject:queue] == NSNotFound) return;
    [queue cancelAllOperations];
    [self.downloadQueues removeObject:queue];
}

- (void)setConnectionsNumber:(NSInteger)connectionsNumber {
    for(ProgressDownloadQueue *queue in self.downloadQueues) {
        queue.maxConcurrentOperationCount = connectionsNumber;
    }
}

@end
