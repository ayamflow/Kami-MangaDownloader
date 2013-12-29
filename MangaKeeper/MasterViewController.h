//
//  MasterViewController.h
//  MangaKeeper
//
//  Created by Florian Morel on 27/12/13.
//  Copyright (c) 2013 Florian Morel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MasterViewController : NSViewController <NSComboBoxDataSource, NSComboBoxDelegate>

@property (weak) IBOutlet NSButton *goButton;
@property (weak) IBOutlet NSComboBox *urlInput;
@property (weak) IBOutlet NSButton *addBookmarkButton;
@property (weak) IBOutlet NSButton *removeBookmarkButton;

@end
