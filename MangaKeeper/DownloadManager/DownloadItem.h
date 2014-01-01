//
//  DownloadItem.h
//  MangaKeeper
//
//  Created by Florian on 31/12/13.
//  Copyright (c) 2013 Florian Morel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadItem : NSObject <NSURLConnectionDataDelegate>

- (id)initWithURL:(NSURL *)url andDirectory:(NSString *)directory;
- (void)start;

@end
