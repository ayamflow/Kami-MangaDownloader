//
//  PreferencesPaneWindowController.m
//  MangaKeeper
//
//  Created by Florian Morel on 01/01/14.
//  Copyright (c) 2014 Florian Morel. All rights reserved.
//

#import "PreferencesPaneWindowController.h"

@interface PreferencesPaneWindowController ()

@end

@implementation PreferencesPaneWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    self.downloadDirectoryLabel.stringValue = [userPreferences stringForKey:@"downloadDirectory"];
}

- (IBAction)browseDownloadDirectory:(id)sender {
    NSOpenPanel *fileBrowser = [NSOpenPanel openPanel];

    // Enable the selection of files in the dialog.
    fileBrowser.canChooseFiles = NO;
    fileBrowser.canChooseDirectories = YES;
    fileBrowser.canCreateDirectories = YES;
    fileBrowser.allowsMultipleSelection = NO;
    [fileBrowser runModal];

    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setObject:[[fileBrowser directoryURL] path] forKey:@"downloadDirectory"];
    self.downloadDirectoryLabel.stringValue = [userPreferences stringForKey:@"downloadDirectory"];
}

@end
