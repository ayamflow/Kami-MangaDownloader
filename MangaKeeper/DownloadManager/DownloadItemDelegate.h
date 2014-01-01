//
//  DownloadItemDelegate.h
//  MangaKeeper
//
//  Created by Florian Morel on 01/01/14.
//  Copyright (c) 2014 Florian Morel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class  DownloadItem;

@protocol DownloadItemDelegate <NSObject>

@required

- (void)itemDidCompleteDownload:(DownloadItem *)item;

@end
