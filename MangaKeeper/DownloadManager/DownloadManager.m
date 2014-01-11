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
#import "NotificationManager.h"

@interface DownloadManager ()

@property (strong, nonatomic) NSMutableArray *activesQueues;
@property (assign, nonatomic) BOOL isPaused;

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
        self.activesQueues = [NSMutableArray array];
        _connectionsNumber = 1;
        _isPaused = NO;
    }
    return self;
}

#pragma Flow control

- (void)resume {
    if(!_isPaused || [self.downloadQueues count] == 0) return;
    _isPaused = NO;

    for(int i = 0; i < self.connectionsNumber; i++) {
        ProgressDownloadQueue *queue = [self.downloadQueues objectAtIndex:i];
        if(queue != nil && !queue.isCompleted) {
            [self resumeQueue:queue];
        }
    }
}

- (void)pause {
    if(_isPaused || [self.downloadQueues count] == 0) return;
    _isPaused = YES;

    for(ProgressDownloadQueue *queue in self.activesQueues) {
        if(!queue.isCompleted) {
            [self pauseQueue:queue];
        }
    }
    [self.activesQueues removeAllObjects];

}

- (void)stop {
    _isPaused = YES;

    for(ProgressDownloadQueue *queue in self.downloadQueues) {
        if(!queue.isCompleted) {
            [self stopQueue:queue];
        }
    }
    [self.activesQueues removeAllObjects];
    [self.downloadQueues removeAllObjects];
}

- (void)startNextQueue {
    if([self.downloadQueues count] == 0) return;
    if([self.activesQueues count] >= self.connectionsNumber) return;

    NSInteger index = [self.activesQueues count];
    ProgressDownloadQueue *queue;
    do {
         queue = [self.downloadQueues objectAtIndex:index++];
    }
    while(index < [self.downloadQueues count] && (!queue.chapter.isReady || queue.isCompleted));
    if(!queue.chapter.isReady || queue.isCompleted) return;

    [self resumeQueue:queue];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([self.activesQueues indexOfObject:object] != NSNotFound && [keyPath isEqualToString:@"operations"]) {
        ProgressDownloadQueue *queue = (ProgressDownloadQueue *)object;
        if(queue.operationCount == 0) {
            [self queueDidFinish:queue];
        }
    }
}

#pragma ProgressDownloadQueue methods

- (void)resumeQueue:(ProgressDownloadQueue *)queue {
    [queue.chapter resume];
    [queue addObserver:self forKeyPath:@"operations" options:0 context:NULL];
    [queue setSuspended:NO];
    [self.activesQueues addObject:queue];
}

- (void)pauseQueue:(ProgressDownloadQueue *)queue {
    [queue setSuspended:YES];
    [queue.chapter pause];
    @try {
        [queue removeObserver:self forKeyPath:@"operations"];
    }
    @catch (NSException *exception) {
        // No observer was attached, moving on
    }
}

- (void)stopQueue:(ProgressDownloadQueue *)queue {
    [self pauseQueue:queue];
    [queue cancelAllOperations];
    [queue.chapter remove];
    queue.delegate = nil;
}

- (void)removeQueue:(ProgressDownloadQueue *)queue {
    if([self.downloadQueues indexOfObject:queue] == NSNotFound) return;
    if([self.activesQueues indexOfObject:queue] != NSNotFound) {
        [self.activesQueues removeObject:queue];
    }
    [self.downloadQueues removeObject:queue];
    [self startNextQueue];
}

- (void)queueDidFinish:(ProgressDownloadQueue *)queue {
    [queue removeObserver:self forKeyPath:@"operations"];
    [self.activesQueues removeObject:queue];
    [queue.chapter complete];
//    [self.downloadQueues removeObject:queue];
    queue.isCompleted = YES;
    [[NotificationManager sharedInstance] showDownloadCompleteNotificationWithDetails:queue.chapter.title];
    [self startNextQueue];
}

#pragma Add/remove

- (void)addQueue:(ProgressDownloadQueue *)queue {
    if([self.downloadQueues indexOfObject:queue] != NSNotFound) return;
    [queue setSuspended:YES];
    queue.delegate = self;
    [queue setMaxConcurrentOperationCount:1];
    [self.downloadQueues addObject:queue];
    [self startNextQueue];
}

- (void)setConnectionsNumber:(NSInteger)connectionsNumber {
    _connectionsNumber = connectionsNumber;
    [self startNextQueue];
}

#pragma DownloadManagerDelegate methods

- (void)queueIsReadyToDownload:(ProgressDownloadQueue *)queue {
    if(self.isPaused) return;
    [self startNextQueue];
}

#pragma Pending downloads

- (BOOL)hasPendingDownloads {
    return [self.downloadQueues count] > 0;
}

@end
