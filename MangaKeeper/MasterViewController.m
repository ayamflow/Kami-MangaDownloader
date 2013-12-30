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
    [self showProgressIndicator];
    
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

    [self hideProgressIndicator];
    
    if([chaptersNodes count] == 0) {

    }
    
   [self.chaptersNumberLabel setStringValue:[NSString stringWithFormat:@"%li", [chaptersNodes count]]];
    
    NSMutableArray *chaptersList = [NSMutableArray array];
    NSMutableArray *chaptersModels = [NSMutableArray array];
    for(TFHppleElement *element in chaptersNodes) {
        ChapterModel *chapter = [[ChapterModel alloc] init];
        chapter.url = [[element attributes] objectForKey:@"href"];
        chapter.title = [[element firstChild] content];
        chapter.host = [NSString stringWithFormat:@"http://%@", [mangaUrl host]];
        [chaptersModels addObject:chapter];
        [chaptersList addObject:chapter.title];
    }

    self.chaptersList = [NSArray arrayWithArray:chaptersList];
    self.chaptersModels = [NSArray arrayWithArray:chaptersModels];
}

#pragma  Download queue Management

- (IBAction)addSelectionToDownloadQueue:(id)sender {
    [self showProgressIndicator];
    NSIndexSet *selectedChapters = [self.chapterListView selectedRowIndexes];
    [selectedChapters enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
//        [[DownloadManager sharedInstance] addFileToQueueWithURL:[self.chaptersModels objectAtIndex:idx]];
        [self getPagesURLWithChapter:[self.chaptersModels objectAtIndex:idx]];
    }];
    [self hideProgressIndicator];
}

- (void)getPagesURLWithChapter:(ChapterModel *)chapter {
    NSURL *chapterURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", chapter.host, chapter.url]];
    NSData *htmlData = [NSData dataWithContentsOfURL:chapterURL];
    TFHpple *htmlParser = [TFHpple hppleWithHTMLData:htmlData];
    
    // Get number of pages
    NSString *pagesNumberQuery = @"//select[@id='pageMenu']";
    NSArray *pagesNumberNodes = [htmlParser searchWithXPathQuery:pagesNumberQuery];
    NSInteger pagesNumber = [[(TFHppleElement *)[pagesNumberNodes objectAtIndex:0] children] count];
    
    // Get URL of pages
    NSString *pagesURLQuery = @"//select[@id='pageMenu']/option";
    NSArray *pagesURLNodes = [htmlParser searchWithXPathQuery:pagesURLQuery];
    NSMutableArray *pagesURLs = [NSMutableArray arrayWithCapacity:pagesNumber];
    for(TFHppleElement *element in pagesURLNodes) {
        [pagesURLs addObject:[[element attributes] objectForKey:@"value"]];
    }
    
    // Get URL of images
    NSMutableArray *imagesURL = [NSMutableArray arrayWithCapacity: pagesNumber];
    for(NSString *url in pagesURLs) {
        NSURL *pageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", chapter.host, url]];
        NSData *htmlData = [NSData dataWithContentsOfURL:pageURL];
        TFHpple *htmlParser = [TFHpple hppleWithHTMLData:htmlData];
        
        NSString *imageQuery = @"//img[@id='img']";
        NSArray *imageNodes = [htmlParser searchWithXPathQuery:imageQuery];
        NSString *imageURL = [[(TFHppleElement *)[imageNodes objectAtIndex:0] attributes] objectForKey:@"src"];
        [imagesURL addObject:imageURL];
    }
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
