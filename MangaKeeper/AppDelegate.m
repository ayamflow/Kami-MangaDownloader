//
//  AppDelegate.m
//  MangaKeeper
//
//  Created by Florian Morel on 27/12/13.
//  Copyright (c) 2013 Florian Morel. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "PreferencesPaneWindowController.h"
#import "DownloadManager.h"

@interface AppDelegate ()

@property (strong, nonatomic) MasterViewController *masterViewController;
@property (strong, nonatomic) PreferencesPaneWindowController *preferencesPane;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self checkIfApplicationSUpportFolderExists];
    [self checkIfPreferencesAreSet];

    self.masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    [self.window.contentView addSubview:self.masterViewController.view];
    self.masterViewController.view.frame = ((NSView *)self.window.contentView).bounds;
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

#pragma Preferences pane

- (IBAction)openPreferencesPane:(id)sender {
    self.preferencesPane = [[PreferencesPaneWindowController alloc] initWithWindowNibName:@"PreferencesPane"];
    [self.preferencesPane showWindow:nil];
}

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
