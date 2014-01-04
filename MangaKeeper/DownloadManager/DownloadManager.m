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

@property (strong, nonatomic) NSMutableArray *activesQueues;

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
        if(queue != nil) {
            [self resumeQueue:queue];
        }
    }
}

- (void)pause {
    if(_isPaused || [self.downloadQueues count] == 0) return;
    _isPaused = YES;

    for(ProgressDownloadQueue *queue in self.activesQueues) {
        [self pauseQueue:queue];
    }
    [self.activesQueues removeAllObjects];

}

- (void)stop {
    _isPaused = YES;

    for(ProgressDownloadQueue *queue in self.downloadQueues) {
        [self stopQueue:queue];
    }
    [self.activesQueues removeAllObjects];
    [self.downloadQueues removeAllObjects];
}

- (void)startNextQueue {
    if([self.downloadQueues count] == 0) return;
    if([self.activesQueues count] >= self.connectionsNumber) return;

    ProgressDownloadQueue *queue = [self.downloadQueues objectAtIndex:[self.activesQueues count]];
    if(!queue.chapter.isReady) return;

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
    [queue setSuspended:NO];
    [queue.chapter resume];
    [queue addObserver:self forKeyPath:@"operations" options:0 context:NULL];
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

- (void)setIsPaused:(BOOL)isPaused {
    NSLog(@"setIsPause %@", isPaused ? @"YES" : @"NO");
    if([self.downloadQueues count] == 0) return;

    if(isPaused) {
        [self pause];
    }
    else {
        [self resume];
    }
}

- (void)stopQueue:(ProgressDownloadQueue *)queue {
    [self pauseQueue:queue];
    [queue cancelAllOperations];
    [queue.chapter remove];
    queue.delegate = nil;
}

- (void)queueDidFinish:(ProgressDownloadQueue *)queue {
    [queue removeObserver:self forKeyPath:@"operations"];
    [self.activesQueues removeObject:queue];
//    [self.downloadQueues removeObject:queue];
    [queue.chapter complete];
//    [self startNextQueue];
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

@end
