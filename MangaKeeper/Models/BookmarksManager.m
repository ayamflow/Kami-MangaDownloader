//
//  Bookmarks.m
//  MangaKeeper
//
//  Created by Florian Morel on 29/12/13.
//  Copyright (c) 2013 Florian Morel. All rights reserved.
//

#import "BookmarksManager.h"
#import "BookmarkModel.h"

#define kSavePath @"KamiBookmarks.plist"

@interface BookmarksManager ()

@property (strong, nonatomic) NSMutableArray *bookmarks;

@end

@implementation BookmarksManager

+ (id)sharedInstance {
    static BookmarksManager *sharedInstance = nil;
    @synchronized(self) {
        if (sharedInstance == nil)
            sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

- (id)init {
    if(self = [super init]) {
        [self load];
    }
    return self;
}

- (void)save {
    NSString *savePlist = [self getSavePlistPath];
    NSMutableArray *savedBookmarks = [NSMutableArray arrayWithCapacity:[self.bookmarks count]];
    for(BookmarkModel *bookmark in self.bookmarks) {
        NSData *bookmarkData = [NSKeyedArchiver archivedDataWithRootObject:bookmark];
        [savedBookmarks addObject:bookmarkData];
    }
    [savedBookmarks writeToFile:savePlist atomically:YES];
}

- (void)load {
    NSString *savePlist = [self getSavePlistPath];
    self.bookmarks = [NSMutableArray array];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:savePlist]) {
        [self save];
    }
    else {
        NSArray *loadedBookmarks = [NSArray arrayWithContentsOfFile:savePlist];
        for(NSData *bookmarkData in loadedBookmarks) {
            [self.bookmarks addObject:[NSKeyedUnarchiver unarchiveObjectWithData:bookmarkData]];
        }
    }
}

- (void)addBookmarkWithURL:(NSString *)url {
    if([url isEqualToString:@""]) return;
    BookmarkModel *bookmark = [[BookmarkModel alloc] initWithURL:url];
    if([self getBookmarkWithURL:url] != nil) return; // Prevent doubles
    [self.bookmarks addObject:bookmark];
    [self save];
}

- (void)removeBookMarkWithURL:(NSString *)url {
    BookmarkModel *bookmark = [self getBookmarkWithURL:url];
    if(bookmark == nil) return;
    [self.bookmarks removeObject:bookmark];
    [self save];
}

- (NSString *)getSavePlistPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    return [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"Kami"] stringByAppendingPathComponent:kSavePath];
}

- (void)deleteBookmarks {
    NSString *savePlist = [self getSavePlistPath];

    NSError *error;
    if(![[NSFileManager defaultManager] removeItemAtPath:savePlist error:&error])
    {
        NSLog(@"[Bookmarks] No plist to delete");
    }
}

- (BookmarkModel *)getBookmarkWithURL:(NSString *)url {
    for(BookmarkModel *bookmark in self.bookmarks) {
        if([bookmark.url isEqualToString:url]) {
            return bookmark;
        }
    }
    return nil;
}

- (NSArray *)getBookmarks {
    return self.bookmarks;
}

@end
