//
//  SettingsView.m
//  MangaKeeper
//
//  Created by Florian Morel on 11/01/14.
//  Copyright (c) 2014 Florian Morel. All rights reserved.
//

#import "PreferencesPane.h"

@interface PreferencesPane ()

@property (strong, nonatomic) NSString *downloadDirectory;
@property (assign, nonatomic) BOOL autoCheckUpdates;
@property (assign, nonatomic) NSUInteger autoCheckFrequency;

@end

@implementation PreferencesPane

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
        self.downloadDirectory = [userPreferences stringForKey:@"downloadDirectory"];
    }
    return self;
}

- (IBAction)browseDownloadDirectory:(id)sender {
    NSOpenPanel *fileBrowser = [NSOpenPanel openPanel];

    // Enable the selection of files in the dialog.
    fileBrowser.canChooseFiles = NO;
    fileBrowser.canChooseDirectories = YES;
    fileBrowser.canCreateDirectories = YES;
    fileBrowser.allowsMultipleSelection = NO;
    [fileBrowser runModal];

    self.downloadDirectory = [[fileBrowser directoryURL] path];
}

#pragma Save/cancel

- (IBAction)cancelChanges:(id)sender {
    // Reset pref
    // Reset downloadDirectory (easy)
    // Reset updates pref (dunno)
}

- (IBAction)saveChanges:(id)sender {
    // Save everything
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    [userPreferences setObject:self.downloadDirectory forKey:@"downloadDirectory"];
}

#pragma PaneProtocol

- (void)dispose {
    [self cancelChanges:nil];
}


@end
