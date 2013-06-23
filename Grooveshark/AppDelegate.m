//
//  AppDelegate.m
//  Grooveshark
//
//  Created by Ryo Suzuki on 6/21/13.
//  Copyright (c) 2013 Ryo Suzuki. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.queueList = [[NSMutableArray alloc] initWithObjects:nil];
    self.currentIndex = -1;
    self.nowPlaying = NO;
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(nowPlaying:) userInfo:nil repeats:YES ];
    [timer fire];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    NSString *songName = [self.currentSong valueForKey:@"songName"];
    NSString *artistName = [self.currentSong valueForKey:@"artistName"];
    MPMediaItemArtwork *albumArtwork = [[MPMediaItemArtwork alloc] init];
/*
    NSArray *values = [[NSArray alloc] initWithObjects:songName, artistName, 42, albumArtwork, nil];
    NSArray *keys = [[NSArray alloc] initWithObjects:MPMediaItemPropertyTitle, MPMediaItemPropertyArtist, MPMediaItemPropertyPlaybackDuration, MPMediaItemPropertyArtwork, nil];
    NSDictionary *currentlyPlayingTrackInfo = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = currentlyPlayingTrackInfo;
*/
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{

}

- (void)addLoadingView
{
    self.loadingView = [[LoadingView alloc] initWithFrame:self.window.frame];
    [self.window addSubview:self.loadingView];
}

- (void)removeLoadingView
{
    [self.loadingView removeFromSuperview];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}


- (void)connection:(NSURLConnection *)_connection didReceiveResponse:(NSURLResponse *)_response;
{
    NSLog(@"Received Response");
    if (_connection == connectionForPlaySong) {
        dataForPlaySong = [[NSMutableData alloc] initWithData:0];
        [self removeLoadingView];
    }
}

- (void)connection:(NSURLConnection *)_connection didReceiveData:(NSData *)_data;
{
    if (_connection == connectionForPlaySong) {
        [dataForPlaySong appendData:_data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)_connection;
{
    NSLog(@"Finish Load Song");
    if (_connection == connectionForPlaySong) {
        duration = self.currentAudioPlayer.duration;
    }
}

- (void)addSongsToQueue:(NSArray *)songs
{
    NSMutableIndexSet* indexeSet = [[NSMutableIndexSet alloc] init];
    for (int i = self.currentIndex + 1; i < self.currentIndex + 1 + songs.count; i++) {
        [indexeSet addIndex:i];
    }
    [self.queueList insertObjects:songs atIndexes:indexeSet];
    [self playSelectedSong:self.currentIndex + 1];
}

- (void)playSelectedSong:(NSInteger)index
{
    if (index < self.queueList.count) {
        dataForPlaySong = [[NSMutableData alloc] initWithData:0];
        [connectionForPlaySong cancel];
        [self.currentAudioPlayer stop];
        self.currentAudioPlayer = [[AVAudioPlayer alloc] initWithData:dataForPlaySong error:nil];
        current = 0.0f;
        duration = 0.0f;
        self.currentIndex = index;
        self.nowPlaying = YES;

        NSDictionary *song = [[NSDictionary alloc] initWithDictionary:[self.queueList objectAtIndex:index]];
        self.currentSong = song;
        NSString *songID = [song valueForKey:@"songID"];
        NSString *songURL = [NSString stringWithFormat:@"https://rails-grooveshark-app.herokuapp.com/songs/%@", songID];
        songURL = [songURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"%@", songURL);

        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:songURL]];
        connectionForPlaySong = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

- (void)playAndPauseSong
{
    if (self.currentAudioPlayer.playing == YES) {
        [self.currentAudioPlayer pause];
        self.nowPlaying = NO;
    } else {
        [self.currentAudioPlayer play];
        self.nowPlaying = YES;
    }
}

- (void)playPrevSong
{
    if (self.currentAudioPlayer.currentTime > 10) {
        self.currentAudioPlayer.currentTime = 0;
    } else {
        [self playSelectedSong:self.currentIndex - 1];
    }
}

- (void)playNextSong
{
    [self playSelectedSong:self.currentIndex + 1];
}

- (void)nowPlaying:(NSTimer *)timer
{
    NSTimeInterval _current = self.currentAudioPlayer.currentTime;
    NSTimeInterval remain = self.currentAudioPlayer.duration - current;
    NSLog(@"Current: %f - Remain : %f", current, remain);

    if (current < _current) {
        current = _current;
    }
    
    if (self.currentAudioPlayer.playing == NO & self.nowPlaying == YES) {
        self.currentAudioPlayer = [[AVAudioPlayer alloc] initWithData:dataForPlaySong error:nil];
        [self.currentAudioPlayer prepareToPlay];
        self.currentAudioPlayer.currentTime = current;
        [self.currentAudioPlayer play];        
    }
    
    if ((int)current == (int)duration & duration > 0) {
        [self playSelectedSong:self.currentIndex + 1];
    }    
}

- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    NSLog(@"hge");
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self playAndPauseSong];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self playPrevSong];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [self playNextSong];
                break;
            default:
                break;
        }
    }
}


@end
