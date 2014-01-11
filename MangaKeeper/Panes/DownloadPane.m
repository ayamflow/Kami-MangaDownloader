//
//  DownloadPane.m
//  MangaKeeper
//
//  Created by Florian Morel on 11/01/14.
//  Copyright (c) 2014 Florian Morel. All rights reserved.
//

#import "DownloadPane.h"
#import "DownloadManager.h"

#define kResumeButtonText @"Resume queue"
#define kPauseButtonText @"Pause queue"

@interface DownloadPane ()

@property (assign, nonatomic) NSInteger connectionsNumber;

@end

@implementation DownloadPane

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.connectionsNumber = [[DownloadManager sharedInstance] connectionsNumber];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDownloadsList) name:@"downloadNeedsUpdate" object:nil];
    }
    return self;
}

- (void)updateDownloadsList {
    if(![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(updateDownloadsList) withObject:Nil waitUntilDone:YES];
    }
    [self.tableView reloadData];
}

#pragma Downloads management

- (IBAction)toggleDownloadQueueStatus:(id)sender { // Pause/Resume
    if([[DownloadManager sharedInstance] isPaused]) {
        [(DownloadManager *)[DownloadManager sharedInstance] resume];
        [(NSButton *)sender setTitle:kPauseButtonText];
    }
    else {
        [(DownloadManager *)[DownloadManager sharedInstance] pause];
        [(NSButton *)sender setTitle:kResumeButtonText];
    }
}

- (IBAction)stopDownloadQueue:(id)sender {
    [(DownloadManager *)[DownloadManager sharedInstance] stop];
}

- (IBAction)stopSelectedDownload:(id)sender {
    NSIndexSet *selectedDownloadsIndexes = [self.tableView selectedRowIndexes];
    [selectedDownloadsIndexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        ProgressDownloadQueue *queue = [[[DownloadManager sharedInstance] downloadQueues] objectAtIndex:index];
        [[DownloadManager sharedInstance] stopQueue:queue];
        [[DownloadManager sharedInstance] removeQueue:queue];
    }];
}

#pragma Connections number Management
- (IBAction)connectionsNumberUpdated:(id)sender {
    self.connectionsNumber = MAX(0, MIN(10, self.connectionsNumber));
}

- (void)setConnectionsNumber:(NSInteger)connectionsNumber {
    _connectionsNumber = connectionsNumber;
    [[DownloadManager sharedInstance] setConnectionsNumber:connectionsNumber];
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

#pragma PaneProtocol

- (void)dispose {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end