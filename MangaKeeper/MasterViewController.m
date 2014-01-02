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
#import "TFHpple.h"
#import "ChapterModel.h"
#import "MangaSite.h"
#import "SearchModel.h"
#import "MangaReader.h"
#import "DownloadManager.h"
#import "Statuses.h"

@interface MasterViewController ()

@property (strong, nonatomic) NSArray *chaptersModels;
@property (strong, nonatomic) NSObject<MangaSite> *currentMangaSite;
@property (assign, nonatomic) NSInteger connectionsNumber;

@end

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.connectionsNumber = 1;
        [self.statusLabel setStringValue:kStatusIdle];
        [[DownloadManager sharedInstance] setConnectionsNumber:self.connectionsNumber];
    }
    return self;
}

- (IBAction)parseURL:(id)sender {
    [self showProgressIndicator];
    
    NSString *url = [self.urlInput stringValue];
    if(![url contains:@"http://"]) {
        url = [NSString stringWithFormat:@"http://%@", url];
    }

    NSURL *inputURL = [NSURL URLWithString:url];

    SearchModel *search = [[SearchModel alloc] init];
    search.url = inputURL;
    
    if([search.host isEqualToString:@"mangareader.net"]) {
        self.currentMangaSite = [[MangaReader alloc] initWithSearch:search];
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
    [self.chapterListView reloadData];
    [self hideProgressIndicator];
    [self.chaptersNumberLabel setStringValue:[NSString stringWithFormat:@"%li", [self.chaptersModels count]]];
    [self.statusLabel setStringValue:kStatusIdle];
}

#pragma Chapters selection Management

- (IBAction)selectAllChapters:(id)sender {
    [self.chapterListView selectAll:nil];
}

- (IBAction)selectNoneChapter:(id)sender {
    [self.chapterListView deselectAll:nil];
}

#pragma Download queue Management

- (IBAction)addSelectionToDownloadQueue:(id)sender {
    [self showProgressIndicator];
    NSIndexSet *selectedChaptersIndexes = [self.chapterListView selectedRowIndexes];
    [selectedChaptersIndexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        [[self.chaptersModels objectAtIndex:index] addToDownloadQueue];
    }];
    [self.downloadsListView reloadData];
    [self hideProgressIndicator];
}

- (IBAction)resumeDownloadQueue:(id)sender {
    [self.downloadsListView reloadData];
    [(DownloadManager *)[DownloadManager sharedInstance] resume];
}

- (IBAction)pauseDownloadQueue:(id)sender {
    [(DownloadManager *)[DownloadManager sharedInstance] pause];
}

#pragma Connections number Management
- (IBAction)connectionsNumberUpdated:(id)sender {
    self.connectionsNumber = MAX(0, MIN(10, self.connectionsNumber));
}

- (void)setConnectionsNumber:(NSInteger)connectionsNumber {
    _connectionsNumber = connectionsNumber;
    [[DownloadManager sharedInstance] setConnectionsNumber:connectionsNumber];
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
    return [[self.chaptersModels objectAtIndex:row] title];
}

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
    NSLog(@"coucou %@", oldDescriptors);
    NSArray *newDescriptors = [tableView sortDescriptors];
    [self.chaptersModels sortedArrayUsingDescriptors:newDescriptors];
    [self.chapterListView reloadData];
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

@end
