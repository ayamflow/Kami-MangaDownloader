//
//  MangaSite.h
//  MangaKeeper
//
//  Created by Florian on 30/12/13.
//  Copyright (c) 2013 Florian Morel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFHpple.h"
#import "SearchModel.h"

@class ChapterModel;

@protocol MangaSite <NSObject>

@required

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *host;
@property (strong, nonatomic) SearchModel *search;

- (id)initWithSearch:(SearchModel *)searchModel;
- (NSArray *)getChaptersList;
- (NSNumber *)getPagesNumberForChapter:(ChapterModel *)chapter;
- (NSArray *)getImagesURLsForChapter:(ChapterModel *)chapter;

@end