//
//  MangaFox.m
//  MangaKeeper
//
//  Created by Florian Morel on 05/01/14.
//  Copyright (c) 2014 Florian Morel. All rights reserved.
//

#import "MangaFox.h"
#import "ChapterModel.h"

@implementation MangaFox

@synthesize title;
@synthesize host;
@synthesize search;

- (id)initWithSearch:(SearchModel *)searchModel {
    if(self = [super init]) {
        self.title = @"MangaFox";
        self.host = searchModel.host;
        self.search = searchModel;
    }
    return self;
}

#pragma MangaSite protocol

- (NSArray *)getChaptersList {
    NSData *htmlData = [NSData dataWithContentsOfURL:self.search.url];
    TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];

    NSString *chaptersListQuery = @"//ul[@class='chlist']/li/div";
    NSArray *chaptersNodes = [parser searchWithXPathQuery:chaptersListQuery];

    NSMutableArray *chaptersList = [NSMutableArray array];

    for(TFHppleElement *element in chaptersNodes) {
        ChapterModel *chapter = [[ChapterModel alloc] init];
        chapter.host = [NSString stringWithFormat:@"http://%@", self.host];
        chapter.url = [NSURL URLWithString:[[[[element firstChildWithTagName:@"h3"] firstChildWithTagName:@"a"] attributes] objectForKey:@"href"]];
        chapter.title = [[[element firstChildWithTagName:@"h3"] firstChildWithTagName:@"a"] text];
        if(chapter.title == nil) chapter.title = [[[element firstChildWithTagName:@"h4"] firstChildWithTagName:@"a"] text];
        chapter.mangaSite = self;
        chapter.date = [[element firstChildWithClassName:@"date"] text];
        [chaptersList addObject:chapter];
    }

    return chaptersList;
}

- (NSInteger)getPagesNumberForChapter:(ChapterModel *)chapter {
    NSData *htmlData = [NSData dataWithContentsOfURL:chapter.url];
    TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];
    NSString *pagesNumberQuery = @"//div[@class='l']/select";
    NSArray *pagesNumberNodes = [parser searchWithXPathQuery:pagesNumberQuery];

    return [[(TFHppleElement *)[pagesNumberNodes objectAtIndex:0] children] count] - 1;
}

- (NSArray *)getImagesURLsForChapter:(ChapterModel *)chapter {
    NSMutableArray *imagesURL = [NSMutableArray arrayWithCapacity:chapter.pagesNumber];
    NSData *htmlData = [NSData dataWithContentsOfURL:chapter.url];
    TFHpple *htmlParser = [TFHpple hppleWithHTMLData:htmlData];

    NSString *imageQuery = @"//div[@id='viewer']/a/img";
    NSArray *imageNodes = [htmlParser searchWithXPathQuery:imageQuery];
    NSString *baseImageURL = [[(TFHppleElement *)[imageNodes objectAtIndex:0] attributes] objectForKey:@"src"];

    for(int i = 0; i < chapter.pagesNumber; i++) {
        NSString *replacement = i >= 9 ? @"01.jpg" : @"1.jpg";
        NSString *imageURL = [baseImageURL stringByReplacingOccurrencesOfString:replacement withString:[NSString stringWithFormat:@"%i.jpg", i + 1]];
        [imagesURL addObject:imageURL];
    }

    return imagesURL;
}


@end
