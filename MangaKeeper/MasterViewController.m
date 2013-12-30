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
#import "MangaSite.h"
#import "MangaReader.h"

@interface MasterViewController ()

@property (strong, nonatomic) NSArray *chaptersList;
@property (strong, nonatomic) NSArray *chaptersModels;
@property (strong, nonatomic) NSObject<MangaSite> *siteContent;

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
    if(![url contains:@"http://"]) {
        url = [NSString stringWithFormat:@"http://%@", url];
    }

    NSURL *inputURL = [NSURL URLWithString:url];

    NSString *host = [inputURL host];
    if([host isEqualToString:@"mangareader.net"]) {
        self.siteContent = [[MangaReader alloc] init];
    }

    if(self.siteContent != nil) {
        self.chaptersModels = [self.siteContent getChaptersListWithURL:inputURL];
        self.chaptersList = [self.chaptersModels valueForKey:@"title"];
    }
    else {
        self.chaptersModels = [NSArray array];
        self.chaptersList = [NSArray array];
    }

    [self.chapterListView reloadData];
    [self hideProgressIndicator];
    [self.chaptersNumberLabel setStringValue:[NSString stringWithFormat:@"%li", [self.chaptersModels count]]];
}

#pragma  Download queue Management

- (IBAction)addSelectionToDownloadQueue:(id)sender {
    [self showProgressIndicator];
    NSIndexSet *selectedChapters = [self.chapterListView selectedRowIndexes];
//    [self.siteContent getImagesListForChapters:selectedChapters withModels:self.chaptersModels];
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
