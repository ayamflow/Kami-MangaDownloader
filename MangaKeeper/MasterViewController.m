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
#import "DownloadManager.h"

@interface MasterViewController ()

@property (strong, nonatomic) NSArray *chaptersList;
@property (strong, nonatomic) NSArray *chaptersModels;

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
    [self.progressIndicator setHidden:NO];
    [self.progressIndicator startAnimation:nil];
    
    NSString *url = [self.urlInput stringValue];
    
    // Replace/parse url to get only info after "/" and host

    if(![url contains:@"http://"]) {
        url = [NSString stringWithFormat:@"http://%@", url];
    }
    
    if([url contains:@"mangareader.net"]) {
        [self fetchHtmlWithURL:url];
        [self.chapterListView reloadData];
    }
}

- (void)fetchHtmlWithURL:(NSString *)url {
    [self.chaptersNumberLabel setStringValue:@"--"];
    
    NSURL *mangaUrl = [NSURL URLWithString:url];
    NSData *htmlData = [NSData dataWithContentsOfURL:mangaUrl];
    
    TFHpple *htmlParser = [TFHpple hppleWithHTMLData:htmlData];
    
    NSString *chaptersListQuery = @"//table[@id='listing']/tr/td/a";
    NSArray *chaptersNodes = [htmlParser searchWithXPathQuery:chaptersListQuery];

    NSLog(@"stop");
    [self.progressIndicator setHidden:YES];
    [self.progressIndicator stopAnimation:nil];
    
    if([chaptersNodes count] == 0) {

    }
    
   [self.chaptersNumberLabel setStringValue:[NSString stringWithFormat:@"%li", [chaptersNodes count]]];
    
    NSMutableArray *chaptersList = [NSMutableArray array];
    NSMutableArray *chaptersModels = [NSMutableArray array];
    for(TFHppleElement *element in chaptersNodes) {
        ChapterModel *chapter = [[ChapterModel alloc] init];
        chapter.chapterURL = [[element attributes] objectForKey:@"href"];
        chapter.chapterTitle = [[element firstChild] content];
        [chaptersModels addObject:chapter];
        [chaptersList addObject:chapter.chapterTitle];
    }

    self.chaptersList = [NSArray arrayWithArray:chaptersList];
    self.chaptersModels = [NSArray arrayWithArray:chaptersModels];
}

#pragma Bookmark Management

- (void)restoreBookmarks {
    NSLog(@"%@", [[BookmarksManager sharedInstance] getBookmarks]);
}

- (IBAction)addBookmark:(id)sender {
    [[BookmarksManager sharedInstance] addBookmarkWithURL:[self.urlInput stringValue]];
    [self.urlInput reloadData];
}

- (IBAction)removeBookmark:(id)sender {
    [[BookmarksManager sharedInstance] removeBookMarkWithURL:[self.urlInput stringValue]];
    [self.urlInput reloadData];
}

#pragma  Download queue Management

- (IBAction)addSelectionToDownloadQueue:(id)sender {
    NSIndexSet *selectedChapters = [self.chapterListView selectedRowIndexes];
    [selectedChapters enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [[DownloadManager sharedInstance] addFileToQueueWithURL:[self.chaptersModels objectAtIndex:idx]];
    }];
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
    return [self.chaptersList count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [self.chaptersList objectAtIndex:row];
}

@end
