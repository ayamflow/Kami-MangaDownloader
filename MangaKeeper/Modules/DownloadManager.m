//
//  DownloadManager.m
//  MangaKeeper
//
//  Created by Florian on 30/12/13.
//  Copyright (c) 2013 Florian Morel. All rights reserved.
//

#import "DownloadManager.h"

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
        
    }
    return self;
}

- (void)addFileToQueueWithURL:(NSString *)url {
    
}

@end
