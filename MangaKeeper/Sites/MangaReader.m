//
//  MangaReader.m
//  MangaKeeper
//
//  Created by Florian on 30/12/13.
//  Copyright (c) 2013 Florian Morel. All rights reserved.
//

#import "MangaReader.h"
#import "TFHpple.h"
#import "TFHppleElement.h"
#import "ChapterModel.h"

@implementation MangaReader

@synthesize title;
@synthesize host;
@dynamic parser;

- (id)init {
    if(self = [super init]) {
        self.title = @"MangaReader";
        self.host = @"http://mangareader.net";
    }
    return self;
}

- (void)getParserWithURL:(NSURL *)url {
    if(self.parser == nil) {
        NSData *htmlData = [NSData dataWithContentsOfURL:url];
        self.parser = [TFHpple hppleWithHTMLData:htmlData];
    }
}

#pragma MangaSite protocol

/*- (NSNumber *)getPagesNumberForChapter:(ChapterModel *)chapter;
- (NSArray *)getChaptersListWithURL:(NSURL *)url;
- (NSArray *)getPagesForChapters:(NSIndexSet *)indexSet withModels:(NSArray *)chapterModels;*/

- (NSNumber *)getPagesNumberForChapter:(ChapterModel *)chapter {

    return @(0);
}

- (NSArray *)getChaptersListWithURL:(NSURL *)url {
    NSData *htmlData = [NSData dataWithContentsOfURL:url];
    TFHpple *htmlParser = [TFHpple hppleWithHTMLData:htmlData];

    NSString *chaptersListQuery = @"//table[@id='listing']/tr/td/a";
    NSArray *chaptersNodes = [htmlParser searchWithXPathQuery:chaptersListQuery];

    NSMutableArray *chaptersList = [NSMutableArray array];
    for(TFHppleElement *element in chaptersNodes) {
        ChapterModel *chapter = [[ChapterModel alloc] init];
        chapter.url = [NSURL URLWithString:[[element attributes] objectForKey:@"href"]];
        chapter.title = [[element firstChild] content];
        chapter.host = self.host;
        [chaptersList addObject:chapter];
    }

    return chaptersList;
}

- (NSArray *)getImagesListForChapters:(NSIndexSet *)indexSet withModels:(NSArray *)chapterModels {
    NSMutableArray *imagesList = [NSMutableArray array];

    [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        ChapterModel *chapter = [chapterModels objectAtIndex:index];
        NSData *htmlData = [NSData dataWithContentsOfURL:chapter.url];
        TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];
        chapter.pagesNumber = [self getPagesNumberWithParser:parser];
        chapter.imagesURLs = [self getImagesURLsWithChapter:chapter andParser:parser];
    }];

    return imagesList;
}

- (NSArray *)getImagesURLsWithChapter:(ChapterModel *)chapter andParser:(TFHpple *)parser {

    return [NSArray array];
}

- (NSNumber *)getPagesNumberWithParser:(TFHpple *)parser {
    NSString *pagesNumberQuery = @"//select[@id='pageMenu']";
    NSArray *pagesNumberNodes = [parser searchWithXPathQuery:pagesNumberQuery];
    return @([[(TFHppleElement *)[pagesNumberNodes objectAtIndex:0] children] count]);
}

- (void)getPagesURLWithChapter:(ChapterModel *)chapter {
    NSData *htmlData = [NSData dataWithContentsOfURL:chapter.url];
    TFHpple *htmlParser = [TFHpple hppleWithHTMLData:htmlData];

    // Get number of pages
    NSString *pagesNumberQuery = @"//select[@id='pageMenu']";
    NSArray *pagesNumberNodes = [htmlParser searchWithXPathQuery:pagesNumberQuery];
    chapter.pagesNumber = @([[(TFHppleElement *)[pagesNumberNodes objectAtIndex:0] children] count]);

    // Get URL of pages
    NSString *pagesURLQuery = @"//select[@id='pageMenu']/option";
    NSArray *pagesURLNodes = [htmlParser searchWithXPathQuery:pagesURLQuery];
    NSMutableArray *pagesURLs = [NSMutableArray arrayWithCapacity:chapter.pagesNumber];
    for(TFHppleElement *element in pagesURLNodes) {
        [pagesURLs addObject:[[element attributes] objectForKey:@"value"]];
    }

    // Get URL of images
    NSMutableArray *imagesURL = [NSMutableArray arrayWithCapacity: chapter.pagesNumber];
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

@end
