//
//  MangaSite.h
//  MangaKeeper
//
//  Created by Florian on 30/12/13.
//  Copyright (c) 2013 Florian Morel. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MangaSite <NSObject>

@required

- (NSArray *)getChaptersList;
- (NSArray *)getImagesList;

@end
