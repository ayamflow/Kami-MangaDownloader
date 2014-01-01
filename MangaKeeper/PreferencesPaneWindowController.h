//
//  PreferencesPaneWindowController.h
//  MangaKeeper
//
//  Created by Florian Morel on 01/01/14.
//  Copyright (c) 2014 Florian Morel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesPaneWindowController : NSWindowController
@property (weak) IBOutlet NSButton *browseButton;
@property (weak) IBOutlet NSTextField *downloadDirectoryLabel;

@end
