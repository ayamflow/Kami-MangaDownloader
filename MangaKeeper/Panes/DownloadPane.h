//
//  DownloadPane.h
//  MangaKeeper
//
//  Created by Florian Morel on 11/01/14.
//  Copyright (c) 2014 Florian Morel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PaneProtocol.h"

@interface DownloadPane : NSViewController <NSTableViewDataSource, NSTableViewDelegate, PaneProtocol>
@property (weak) IBOutlet NSTableView *tableView;

@end
