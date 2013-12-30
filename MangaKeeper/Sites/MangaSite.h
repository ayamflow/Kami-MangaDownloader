//
//  MangaSite.h
//  MangaKeeper
//
//  Created by Florian on 30/12/13.
//  Copyright (c) 2013 Florian Morel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChapterModel.h"
#import "TFHpple.h"

@protocol MangaSite <NSObject>

@required

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *host;
@property (strong, nonatomic) TFHpple *parser;

- (NSNumber *)getPagesNumberForChapter:(ChapterModel *)chapter;
- (NSArray *)getChaptersListWithURL:(NSURL *)url;
- (NSArray *)getPagesForChapters:(NSIndexSet *)indexSet withModels:(NSArray *)chapterModels;

@end
