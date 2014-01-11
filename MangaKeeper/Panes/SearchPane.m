//
//  SearchPane.m
//  MangaKeeper
//
//  Created by Florian Morel on 11/01/14.
//  Copyright (c) 2014 Florian Morel. All rights reserved.
//

#import "SearchPane.h"
#import "DownloadManager.h"
#import "NSString+Common.h"
#import "Statuses.h"
#import "BookmarksManager.h"

#import "MangaSite.h"
#import "MangaReader.h"
#import "MangaFox.h"

@interface SearchPane ()

@property (strong, nonatomic) NSArray *chaptersModels;
@property (strong, nonatomic) NSObject<MangaSite> *currentMangaSite;

@end

@implementation SearchPane

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.statusLabel setStringValue:kStatusIdle];
    }
    return self;
}

- (IBAction)getMangaSite:(id)sender {
    [self showProgressIndicator];

    NSString *url = [[self.urlInput stringValue] stringByReplacingOccurrencesOfString:@"www." withString:@""];
    if(![url contains:@"http://"]) {
        url = [NSString stringWithFormat:@"http://%@", url];
    }

    NSURL *inputURL = [NSURL URLWithString:url];

    SearchModel *search = [[SearchModel alloc] init];
    search.url = inputURL;

    if([search.host isEqualToString:@"mangareader.net"]) {
        self.currentMangaSite = [[MangaReader alloc] initWithSearch:search];
    }
    else if([search.host isEqualToString:@"mangafox.me"]) {
        self.currentMangaSite = [[MangaFox alloc] initWithSearch:search];
    }

    // Fetch the chapters on a background thread
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSInvocationOperation *fetchChaptersListOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(fetchChaptersList) object:nil];
    [fetchChaptersListOperation setCompletionBlock:^{
        [self performSelectorOnMainThread:@selector(chaptersListFetched) withObject:nil waitUntilDone:YES];
    }];

    [queue addOperation:fetchChaptersListOperation];
}

- (void)fetchChaptersList {
    [self.statusLabel setStringValue:kStatusFetchingChaptersList];
    if(self.currentMangaSite != nil) {
        self.chaptersModels = [self.currentMangaSite getChaptersList];
    }
    else {
        self.chaptersModels = [NSArray array];
    }
}

- (void)chaptersListFetched {
    [self.chaptersListView reloadData];
    [self hideProgressIndicator];
    [self.chaptersNumberLabel setStringValue:[NSString stringWithFormat:@"%li", [self.chaptersModels count]]];
    [self.statusLabel setStringValue:kStatusIdle];
}

#pragma Chapters selection Management

- (IBAction)selectAllChapters:(id)sender {
    [self.chaptersListView selectAll:nil];
}

- (IBAction)selectNoneChapter:(id)sender {
    [self.chaptersListView deselectAll:nil];
}

#pragma Download queue Management

- (IBAction)addSelectionToDownloadQueue:(id)sender {
    [self showProgressIndicator];
    NSIndexSet *selectedChaptersIndexes = [self.chaptersListView selectedRowIndexes];
    [selectedChaptersIndexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        [[self.chaptersModels objectAtIndex:index] addToDownloadQueue];
    }];
    [self hideProgressIndicator];
}

#pragma Bookmark Management

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
    return [[[BookmarksManager sharedInstance] getBookmarks] count];
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index {
    return [[[[BookmarksManager sharedInstance] getBookmarks] objectAtIndex:index] url];
}

#pragma  NSTableView delegate/datasource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.chaptersModels count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if([tableColumn.identifier isEqualToString:@"titleColumn"]) {
        return [[self.chaptersModels objectAtIndex:row] title];
    }
    else if([tableColumn.identifier isEqualToString:@"dateColumn"]) {
        return [[self.chaptersModels objectAtIndex:row] date];
    }
    return nil;
}

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
    NSArray *newDescriptors = [tableView sortDescriptors];
    [self.chaptersModels sortedArrayUsingDescriptors:newDescriptors];
    [self.chaptersListView reloadData];
}

#pragma Progress indicator

- (void)showProgressIndicator {
    [self.progressIndicator setHidden:NO];
    [self.progressIndicator startAnimation:nil];
}

- (void)hideProgressIndicator {
    [self.progressIndicator setHidden:YES];
    [self.progressIndicator stopAnimation:nil];
}

#pragma PaneProtocol

- (void)dispose {

}

@end
