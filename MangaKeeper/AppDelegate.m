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

@interface AppDelegate ()

@property (strong, nonatomic) MasterViewController *masterViewController;
@property (strong, nonatomic) PreferencesPaneWindowController *preferencesPane;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Check that the downloadDirectory preference exists, or defaults to Documents directory.
    NSUserDefaults *userPreferences = [NSUserDefaults standardUserDefaults];
    NSString *downloadDirectory = [userPreferences stringForKey:@"downloadDirectory"];
    if(downloadDirectory == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        [userPreferences setObject:documentsDirectory forKey:@"downloadDirectory"];
    }

    self.masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];

    [self.window.contentView addSubview:self.masterViewController.view];
    self.masterViewController.view.frame = ((NSView *)self.window.contentView).bounds;
}

#pragma Preferences pane

- (IBAction)openPreferencesPane:(id)sender {
    self.preferencesPane = [[PreferencesPaneWindowController alloc] initWithWindowNibName:@"PreferencesPane"];
    [self.preferencesPane showWindow:nil];
}

@end
