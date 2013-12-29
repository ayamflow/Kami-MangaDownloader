//
//  BookmarkModel.m
//  MangaKeeper
//
//  Created by Florian Morel on 29/12/13.
//  Copyright (c) 2013 Florian Morel. All rights reserved.
//

#import "BookmarkModel.h"

@implementation BookmarkModel

- (id)initWithURL:(NSString *)url {
    if(self = [super init]) {
        self.url = url;
    }
    return self;
}

@end
