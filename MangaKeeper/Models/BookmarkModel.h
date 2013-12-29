//
//  BookmarkModel.h
//  MangaKeeper
//
//  Created by Florian Morel on 29/12/13.
//  Copyright (c) 2013 Florian Morel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookmarkModel : NSObject

@property (strong, nonatomic) NSString *url;

- (id)initWithURL:(NSString *)url;

@end
