//
//  DownloadManager.m
//  MangaKeeper
//
//  Created by Florian Morel on 01/01/14.
//  Copyright (c) 2014 Florian Morel. All rights reserved.
//

#import "DownloadManager.h"
#import "DownloadItem.h"

@interface DownloadManager ()

@property (strong, nonatomic) NSOperationQueue *currentQueue;
@property (strong, nonatomic) NSMutableArray *items;

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
    }
    return self;
}

#pragma Flow control

- (void)resume {
    if(self.currentQueue != nil) {
        [self.currentQueue setSuspended:NO];
    }
    else if([self.downloadQueues count] > 0) {
        [self startNextQueue];
    }
}

- (void)pause {
    if(self.currentQueue == nil) return;
    [self.currentQueue setSuspended:YES];
}

- (void)stop {
    for(NSOperationQueue *queue in self.downloadQueues) {
        [queue cancelAllOperations];
        [self.currentQueue removeObserver:self forKeyPath:@"operations"];
        self.currentQueue = nil;
    }
}

- (void)startNextQueue {
    if([self.downloadQueues count] == 0) return;
    self.currentQueue = [self.downloadQueues objectAtIndex:0];
    [self.currentQueue addObserver:self forKeyPath:@"operations" options:0 context:NULL];
    [self.currentQueue setSuspended:NO];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(object == self.currentQueue && [keyPath isEqualToString:@"operations"]) {
        [self.currentQueue removeObserver:self forKeyPath:@"operations"];
        [self.downloadQueues removeObject:self.currentQueue];
        [self startNextQueue];
    }
}

#pragma Add/remove

- (void)addQueue:(NSOperationQueue *)queue {
    [queue setSuspended:YES];
    [self.downloadQueues addObject:queue];
}

- (void)removeQueue:(NSOperationQueue *)queue {
    [queue cancelAllOperations];
    [self.downloadQueues removeObject:queue];
}

- (void)setConnectionsNumber:(NSInteger)connectionsNumber {
    for(NSOperationQueue *queue in self.downloadQueues) {
        queue.maxConcurrentOperationCount = connectionsNumber;
    }
}

@end
