//
//  Bookmarks.h
//  MangaKeeper
//
//  Created by Florian Morel on 29/12/13.
//  Copyright (c) 2013 Florian Morel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookmarksManager : NSObject

+ (id)sharedInstance;
- (void)save;
- (void)load;
- (void)addBookmarkWithURL:(NSString *)url;
- (void)removeBookMarkWithURL:(NSString *)url;
- (void)deleteBookmarks;
- (NSArray *)getBookmarks;

@end
