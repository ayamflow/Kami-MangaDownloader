//
//  NotificationManager.h
//  MangaKeeper
//
//  Created by Florian Morel on 04/01/14.
//  Copyright (c) 2014 Florian Morel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationManager : NSObject <NSUserNotificationCenterDelegate>

+ (id)sharedInstance;
- (void)showDownloadCompleteNotificationWithDetails:(NSString *)details;
- (void)showDownloadFailedNotificationWithDetails:(NSString *)details;

@end
