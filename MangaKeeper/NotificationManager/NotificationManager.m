//
//  NotificationManager.m
//  MangaKeeper
//
//  Created by Florian Morel on 04/01/14.
//  Copyright (c) 2014 Florian Morel. All rights reserved.
//

#import "NotificationManager.h"

#define kDownloadCompleteTitle @"Download complete"
#define kDownloadFailedTitle @"Download failed"

@implementation NotificationManager

#pragma Singleton init

+ (NotificationManager *)sharedInstance {
    static NotificationManager *sharedInstance = nil;
    @synchronized(self) {
        if (sharedInstance == nil)
            sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

- (id)init {
    if(self = [super init]) {
        [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    }
    return self;
}

#pragma Notifications methods

- (void)showDownloadCompleteNotificationWithDetails:(NSString *)details {
    NSUserNotification *notification = [self getNotificationWithTitle:kDownloadCompleteTitle andDetails:details];
    notification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (void)showDownloadFailedNotificationWithDetails:(NSString *)details {
    NSUserNotification *notification = [self getNotificationWithTitle:kDownloadFailedTitle andDetails:details];
    notification.soundName = NSUserNotificationDefaultSoundName; // Implement a buzzing sound for error ?
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (NSUserNotification *)getNotificationWithTitle:(NSString *)title andDetails:(NSString *)details {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = title;
    notification.informativeText = details;

    return notification;
}

#pragma UserNotificationCenter delegate

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}


@end
