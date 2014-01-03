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
#import "SearchModel.h"

@implementation MangaReader

@synthesize title;
@synthesize host;
@synthesize search;

- (id)initWithSearch:(SearchModel *)searchModel {
    if(self = [super init]) {
        self.title = @"MangaReader";
        self.host = searchModel.host;
        self.search = searchModel;
    }
    return self;
}

#pragma MangaSite protocol

- (NSArray *)getChaptersList {
    NSData *htmlData = [NSData dataWithContentsOfURL:self.search.url];
    TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];
    
    NSString *chaptersListQuery = @"//table[@id='listing']/tr";
    NSArray *chaptersNodes = [parser searchWithXPathQuery:chaptersListQuery];

    NSMutableArray *chaptersList = [NSMutableArray array];
    for(TFHppleElement *element in chaptersNodes) {
        NSArray *dataNodes = [element childrenWithTagName:@"td"];
        if([dataNodes count]) {
            ChapterModel *chapter = [[ChapterModel alloc] init];
            chapter.host = [NSString stringWithFormat:@"http://%@", self.host];
            chapter.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", chapter.host, [[[[dataNodes objectAtIndex:0] firstChildWithTagName:@"a"] attributes] objectForKey:@"href"]]];
            chapter.title = [[[dataNodes objectAtIndex:0] firstChildWithTagName:@"a"] text];
            chapter.mangaSite = self;
            chapter.date = [[[dataNodes objectAtIndex:1] firstChild] content];
            [chaptersList addObject:chapter];
        }
    }

    return chaptersList;
}

- (NSInteger)getPagesNumberForChapter:(ChapterModel *)chapter {
    NSData *htmlData = [NSData dataWithContentsOfURL:chapter.url];
    TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];
    NSString *pagesNumberQuery = @"//select[@id='pageMenu']";
    NSArray *pagesNumberNodes = [parser searchWithXPathQuery:pagesNumberQuery];
    
    return [[(TFHppleElement *)[pagesNumberNodes objectAtIndex:0] children] count];
}

- (NSArray *)getImagesURLsForChapter:(ChapterModel *)chapter {
    NSData *htmlData = [NSData dataWithContentsOfURL:chapter.url];
    TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];
    
    // Get URL of pages
    NSString *pagesURLQuery = @"//select[@id='pageMenu']/option";
    NSArray *pagesURLNodes = [parser searchWithXPathQuery:pagesURLQuery];
    NSMutableArray *pagesURLs = [NSMutableArray arrayWithCapacity:chapter.pagesNumber];


    for(TFHppleElement *element in pagesURLNodes) {
        [pagesURLs addObject:[[element attributes] objectForKey:@"value"]];
    }
    
    // Get URL of images
    NSMutableArray *imagesURL = [NSMutableArray arrayWithCapacity:chapter.pagesNumber];
    for(NSString *url in pagesURLs) {
        NSURL *pageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", chapter.host, url]];
        NSData *htmlData = [NSData dataWithContentsOfURL:pageURL];
        TFHpple *htmlParser = [TFHpple hppleWithHTMLData:htmlData];
        
        NSString *imageQuery = @"//img[@id='img']";
        NSArray *imageNodes = [htmlParser searchWithXPathQuery:imageQuery];
        NSString *imageURL = [[(TFHppleElement *)[imageNodes objectAtIndex:0] attributes] objectForKey:@"src"];
        [imagesURL addObject:imageURL];
    }
    
    return imagesURL;
}

@end
