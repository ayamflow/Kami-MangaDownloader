//
//  ChapterParser.m
//  MangaKeeper
//
//  Created by Florian Morel on 27/12/13.
//  Copyright (c) 2013 Florian Morel. All rights reserved.
//

#import "ChapterParser.h"
#import "NSString+Common.h"

@interface ChapterParser ()

@end

@implementation ChapterParser

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (IBAction)parseURL:(id)sender {
    NSString *url = [self.urlInput stringValue];

    if([url contains:@"mangareader.net"]) {
        NSLog(@"mangareader");  
    }
}

@end