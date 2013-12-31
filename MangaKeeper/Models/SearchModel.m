//
//  SearchModel.m
//  MangaKeeper
//
//  Created by Florian on 31/12/13.
//  Copyright (c) 2013 Florian Morel. All rights reserved.
//

#import "SearchModel.h"

@implementation SearchModel

- (void)setUrl:(NSURL *)url {
    _url = url;
    _host = [url host];
}

@end
