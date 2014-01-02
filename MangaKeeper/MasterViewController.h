//
//  MasterViewController.h
//  MangaKeeper
//
//  Created by Florian Morel on 27/12/13.
//  Copyright (c) 2013 Florian Morel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MasterViewController : NSViewController <NSComboBoxDataSource, NSComboBoxDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSButton *goButton;
@property (weak) IBOutlet NSComboBox *urlInput;
@property (weak) IBOutlet NSButton *addBookmarkButton;
@property (weak) IBOutlet NSButton *removeBookmarkButton;
@property (weak) IBOutlet NSTableView *chapterListView;
@property (weak) IBOutlet NSButton *downloadButton;
@property (weak) IBOutlet NSTextField *chaptersNumberLabel;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSTextField *connectionsNumberInput;
@property (weak) IBOutlet NSStepper *stepper;
@property (weak) IBOutlet NSTableView *downloadsListView;
@property (weak) IBOutlet NSTextField *statusLabel;

@end
