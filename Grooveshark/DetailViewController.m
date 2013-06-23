//
//  DetailViewController.m
//  Grooveshark
//
//  Created by Ryo Suzuki on 6/21/13.
//  Copyright (c) 2013 Ryo Suzuki. All rights reserved.
//

#import "DetailViewController.h"

#import "AppDelegate.h"
#import "MasterViewController.h"

@interface DetailViewController ()
{
    AppDelegate *appDelegate;
}
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.detailItem) {
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(nowPlaying:) userInfo:nil repeats:YES ];
    [timer fire];
    
    [self.pauseButton addTarget:self action:@selector(pauseButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.prevButton addTarget:self action:@selector(prevButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.nextButton addTarget:self action:@selector(nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
}


- (void)pauseButtonTapped:(id)sender
{
    [appDelegate playAndPauseSong];
    if (appDelegate.nowPlaying == YES) {
        [self.pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    } else {
        [self.pauseButton setTitle:@"Play" forState:UIControlStateNormal];
    }
}

- (void)prevButtonTapped:(id)sender
{
    [appDelegate playPrevSong];
}

- (void)nextButtonTapped:(id)sender
{
    [appDelegate playNextSong];
}

- (void)nowPlaying:(NSTimer *)timer
{
    NSInteger current = (int)appDelegate.currentAudioPlayer.currentTime;
    NSInteger duration = (int)appDelegate.currentAudioPlayer.duration;
    self.current.text = [NSString stringWithFormat:@"Current: %i / Duration: %i", current, duration];

    NSDictionary *song = appDelegate.currentSong;
    self.songName.text = [song valueForKey:@"songName"];
    self.artistName.text = [song valueForKey:@"artistName"];
    self.albumName.text = [song valueForKey:@"albumName"];
    
    [self.queueButton setTitle:[NSString stringWithFormat:@"Queue %i Songs", appDelegate.queueList.count] forState:UIControlStateNormal];

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
