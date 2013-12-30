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

@interface MasterViewController ()

@property (strong, nonatomic) NSArray *chaptersList;

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
    
    // Replace/parse url to get only info after "/" and host

    if([url contains:@"mangareader.net"]) {
        self.chaptersList = [self fetchHtmlWithURL:url];
        [self.chapterListView reloadData];
    }
}

- (NSArray *)fetchHtmlWithURL:(NSString *)url {
    NSURL *mangaUrl = [NSURL URLWithString:url];
    NSData *htmlData = [NSData dataWithContentsOfURL:mangaUrl];
    
    TFHpple *htmlParser = [TFHpple hppleWithHTMLData:htmlData];

/*    NSString *mangaNameQuery = @"//h2[@class='aname']";
    NSArray *mangaName = [htmlParser searchWithXPathQuery:mangaNameQuery];
    NSString *mangaTitle = [[(TFHppleElement *)[mangaName objectAtIndex:0] firstChild] content];*/
    
    NSString *chaptersListQuery = @"//table[@id='listing']/tr/td/a";
    NSArray *chaptersNodes = [htmlParser searchWithXPathQuery:chaptersListQuery];
    
    NSMutableArray *chaptersList = [NSMutableArray array];
    for(TFHppleElement *element in chaptersNodes) {
        ChapterModel *chapter = [[ChapterModel alloc] init];
        chapter.chapterURL = [[element attributes] objectForKey:@"href"];
        chapter.chapterTitle = [[element firstChild] content];
//        [chaptersList addObject:chapter];
        [chaptersList addObject:chapter.chapterTitle];
    }

    return [NSArray arrayWithArray:chaptersList];
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
    NSLog(@"%@", selectedChapters);
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
