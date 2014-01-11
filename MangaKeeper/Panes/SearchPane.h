//
//  SearchPane.h
//  MangaKeeper
//
//  Created by Florian Morel on 11/01/14.
//  Copyright (c) 2014 Florian Morel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PaneProtocol.h"

@interface SearchPane : NSViewController <NSComboBoxDataSource, NSComboBoxDelegate, NSTableViewDataSource, NSTableViewDelegate, PaneProtocol>

@property (weak) IBOutlet NSComboBox *urlInput;
@property (weak) IBOutlet NSTextField *chaptersNumberLabel;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSTableView *chaptersListView;
@property (weak) IBOutlet NSTextField *statusLabel;

@end
