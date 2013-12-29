//
//  MasterViewController.m
//  MangaKeeper
//
//  Created by Florian Morel on 27/12/13.
//  Copyright (c) 2013 Florian Morel. All rights reserved.
//

#import "MasterViewController.h"
#import "NSString+Common.h"
#import "BookmarksManager.h"
#import "BookmarkModel.h"

@interface MasterViewController ()

@end

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self restoreBookmarks];
    }
    return self;
}

- (IBAction)parseURL:(id)sender {
    NSString *url = [self.urlInput stringValue];

    if([url contains:@"mangareader.net"]) {
        NSLog(@"mangareader");
    }
}

#pragma Bookmark Management

- (void)restoreBookmarks {

}

- (IBAction)addBookmark:(id)sender {
    [[BookmarksManager sharedInstance] addBookmarkWithURL:[self.urlInput stringValue]];
    [self.urlInput reloadData];
}

- (IBAction)removeBookmark:(id)sender {
    [[BookmarksManager sharedInstance] removeBookMarkWithURL:[self.urlInput stringValue]];
    [self.urlInput reloadData];
}

#pragma NSComboBox delegate/datasource

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox {
    NSLog(@"number of items: %li", [[[BookmarksManager sharedInstance] getBookmarks] count]);
    return [[[BookmarksManager sharedInstance] getBookmarks] count];
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index {
    NSLog(@"object for index %li: %@", index, [[[BookmarksManager sharedInstance] getBookmarks] objectAtIndex:index]);
    return [[[BookmarksManager sharedInstance] getBookmarks] objectAtIndex:index];
}

@end
