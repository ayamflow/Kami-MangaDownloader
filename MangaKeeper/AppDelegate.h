//
//  AppDelegate.h
//  MangaKeeper
//
//  Created by Florian Morel on 27/12/13.
//  Copyright (c) 2013 Florian Morel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ITSidebar.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSView *centerView;
@property (weak) IBOutlet ITSidebar *sidebar;

@end
