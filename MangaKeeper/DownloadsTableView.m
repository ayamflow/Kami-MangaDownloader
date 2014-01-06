//
//  DownloadsTableView.m
//  MangaKeeper
//
//  Created by Florian Morel on 02/01/14.
//  Copyright (c) 2014 Florian Morel. All rights reserved.
//

#import "DownloadsTableView.h"
#import "DownloadManager.h"

@implementation DownloadsTableView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDownloadsList) name:@"downloadNeedsUpdate" object:nil];
    }
    return self;
}

- (void)updateDownloadsList {
    if(![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(updateDownloadsList) withObject:Nil waitUntilDone:YES];
    }
    [self reloadData];
}

#pragma Datasource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[[DownloadManager sharedInstance] downloadQueues] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if([[[DownloadManager sharedInstance] downloadQueues] count] == 0) return nil;
        
    if([tableColumn.identifier isEqualToString:@"titleColumn"]) {
        return [[[[DownloadManager sharedInstance] downloadQueues] objectAtIndex:row] title];
    }
    else if([tableColumn.identifier isEqualToString:@"progressColumn"]) {
        CGFloat progress = [[[[DownloadManager sharedInstance] downloadQueues] objectAtIndex:row] progress];
        return [NSString stringWithFormat:@"%.1f%%", progress * 100];
    }
    else if([tableColumn.identifier isEqualToString:@"statusColumn"]) {
        return [[[[[DownloadManager sharedInstance] downloadQueues] objectAtIndex:row] chapter] status];
    }
    return nil;
}

#pragma delegate

// Show a progressbar (NSProgressIndicator) instead of a NSString percentage
/*- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if([tableColumn.identifier isEqualToString:@"progressCell"]) {
        CGFloat progress = [[[[DownloadManager sharedInstance] downloadQueues] objectAtIndex:row] progress];
        NSProgressIndicator *indicator = [[NSProgressIndicator alloc] initWithFrame:[cell bounds]];
        [indicator setIndeterminate:NO];
        [indicator setUsesThreadedAnimation:NO];
        [indicator setMinValue:0.0];
        [indicator setMaxValue:1.0];
        [indicator setDoubleValue:progress];
        [cell addSubview:indicator];
    }
}*/

@end