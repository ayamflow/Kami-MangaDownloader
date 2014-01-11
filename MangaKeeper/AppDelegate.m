//
//  AppDelegate.m
//  MangaKeeper
//
//  Created by Florian Morel on 27/12/13.
//  Copyright (c) 2013 Florian Morel. All rights reserved.
//

#import "AppDelegate.h"
#import "DownloadManager.h"
#import "MasterViewController.h"
#import "DownloadPane.h"
#import "SearchPane.h"
#import "PreferencesPane.h"
#import "PaneProtocol.h"

@interface AppDelegate ()

@property (strong, nonatomic) NSViewController<PaneProtocol> *currentController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self checkIfApplicationSUpportFolderExists];
    [self checkIfPreferencesAreSet];

    [self createSidebar];
    [self showSearchPane ];
}

#pragma Sidebar management

- (void)createSidebar {
    [self.sidebar addItemWithImage:[NSImage imageNamed:@"bookmarkButton.png"] target:self action:@selector(showBookmarkPane)];
    [self.sidebar addItemWithImage:[NSImage imageNamed:@"searchButton.png"] target:self action:@selector(showSearchPane)];
    [self.sidebar addItemWithImage:[NSImage imageNamed:@"downloadButton.png"] target:self action:@selector(showDownloadPane)];
    [self.sidebar addItemWithImage:[NSImage imageNamed:@"settingsButton.png"] target:self action:@selector(showPreferencesPane)];
}

- (void)showBookmarkPane {
    [self showPane:@"MasterViewController"];
}

- (void)showSearchPane {
    [self showPane:@"SearchPane"];
}

- (void)showDownloadPane {
    [self showPane:@"DownloadPane"];
}

- (void)showPreferencesPane {
    [self showPane:@"PreferencesPane"];
}

- (IBAction)showSettingsPaneFromMenu:(id)sender {
    [self showPreferencesPane];
}

- (void)showPane:(NSString *)className {
    [self.currentController.view removeFromSuperview];
    [self.currentController dispose];
    self.currentController = [[NSClassFromString(className) alloc] initWithNibName:className bundle:nil];
    [self.centerView addSubview:self.currentController.view];
    self.currentController.view.frame = ((NSView *)self.window.contentView).bounds;
}

#pragma Exit application

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    if([[DownloadManager sharedInstance] hasPendingDownloads]) {
        NSAlert *closeAlert = [[NSAlert alloc] init];
        [closeAlert setMessageText:@"You have active downloads."];
        [closeAlert setInformativeText:@"All active downloads will be lost. Exit anyway ?"];
        [closeAlert addButtonWithTitle:@"Cancel"];
        [closeAlert addButtonWithTitle:@"Exit"];
        [closeAlert setAlertStyle:NSWarningAlertStyle];
        [closeAlert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(closeApplicationAlertClosed:returnCode:) contextInfo:nil];
        return NSTerminateLater;
    }
    return NSTerminateNow;
}

- (void)closeApplicationAlertClosed:(NSAlert *)alert returnCode:(NSInteger)returnCode {
    if(returnCode == NSAlertSecondButtonReturn) {
        [NSApp replyToApplicationShouldTerminate:YES];
    }
    else {
        [NSApp replyToApplicationShouldTerminate:NO];
    }
}

#pragma Default settings

- (void)checkIfPreferencesAreSet {
    // Check that the downloadDirectory preference exists, or defaults to Documents directory.
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    NSString *downloadDirectory = [userPreferences stringForKey:@"downloadDirectory"];
    if(downloadDirectory == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        [userPreferences setObject:documentsDirectory forKey:@"downloadDirectory"];
    }
}

#pragma Application support directory

- (void)checkIfApplicationSUpportFolderExists {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *kamiFolderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Kami"];

    BOOL isDir;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:kamiFolderPath isDirectory:&isDir]) {
        if(![fileManager createDirectoryAtPath:kamiFolderPath withIntermediateDirectories:YES attributes:nil error:NULL]) {
            NSLog(@"Error: Create folder failed %@", kamiFolderPath);
        }
    }
}

@end
