//
//  DownloadItem.m
//  MangaKeeper
//
//  Created by Florian on 31/12/13.
//  Copyright (c) 2013 Florian Morel. All rights reserved.
//

#import "DownloadItem.h"

@interface DownloadItem ()

@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSURLRequest *request;
@property (strong, nonatomic) NSURLDownload *download;
@property (assign, nonatomic) CGFloat progress;
@property (assign, nonatomic) NSInteger bytesReceived;
@property (strong, nonatomic) NSURLResponse *response;

@end

@implementation DownloadItem

- (id)initWithURL:(NSURL *)url {
    if(self = [super init]) {
        self.url = url;
    }
    return self;
}

- (void)start {
    NSLog(@"Starting to download %@", self.url);
    self.progress = 0;
    self.request = [NSURLRequest requestWithURL:self.url];
    self.download = [[NSURLDownload alloc] initWithRequest:self.request delegate:self];
    
    if(!self.download) {
        // It failed
        NSLog(@"Download failed.");
    }
}

#pragma NSURLDownload delegate

- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    self.bytesReceived = 0;
    self.response = response;
}

- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(NSUInteger)length {
    NSLog(@"didReceiveDataOfLength %li", length);
    NSInteger expectedLength = [self.response expectedContentLength];
    self.bytesReceived += length;
    
    if(expectedLength != NSURLResponseUnknownLength) {
        self.progress = self.bytesReceived / (CGFloat)expectedLength * 100.0;
    }
    
    NSLog(@"Progress: %f", self.progress);
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error {
    
}

- (void)downloadDidFinish:(NSURLDownload *)download {
    NSLog(@"Download complete");
}

- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename {
    NSString *destinationFileName;
    NSString *homeDirectory = NSHomeDirectory();
    
    destinationFileName = [[homeDirectory stringByAppendingPathComponent:@"Desktop"] stringByAppendingPathComponent:filename];
    [self.download setDestination:destinationFileName allowOverwrite:NO];
}

@end
