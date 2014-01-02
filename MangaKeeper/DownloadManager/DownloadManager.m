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

@property (strong, nonatomic) NSOperationQueue *downloadQueue;
@property (strong, nonatomic) NSMutableArray *items;
@property (assign, nonatomic) NSInteger queuePosition;
@property (assign, nonatomic) NSInteger currentItemsNumber;

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
        self.downloadQueue = [[NSOperationQueue alloc] init];
        [self.downloadQueue setSuspended:YES];
    }
    return self;
}

#pragma Flow control

- (void)resume {
    [self.downloadQueue setSuspended:NO];
}

- (void)pause {
    [self.downloadQueue setSuspended:YES];
}

- (void)stop {
    [self.downloadQueue cancelAllOperations];
}

#pragma Queue management

- (void)addToQueue:(DownloadItem *)item {
    item.delegate = self;
    [self.items addObject:item];
    [self.downloadQueue addOperation:item];
}

- (void)removeFromQueue:(DownloadItem *)item {
    item.delegate = nil;
    [item cancel];
    [self.items removeObject:item];
}

- (void)proceedQueue {
    while(self.currentItemsNumber < self.connectionsNumber) {
        [self downloadNextItem];
    }
}

- (void)downloadNextItem {
    self.queuePosition++;
    self.currentItemsNumber++;
    DownloadItem *item = [self.items objectAtIndex:self.queuePosition];
    [item start];
}

- (void)setConnectionsNumber:(NSInteger)connectionsNumber {
    self.downloadQueue.maxConcurrentOperationCount = connectionsNumber;
}

#pragma DownloadItemDelegate

- (void)itemDidCompleteDownload:(DownloadItem *)item {
    item.delegate = nil;
    self.currentItemsNumber--;
    [self proceedQueue];
}

@end
