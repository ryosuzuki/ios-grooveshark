//
//  AppDelegate.h
//  Grooveshark
//
//  Created by Ryo Suzuki on 6/21/13.
//  Copyright (c) 2013 Ryo Suzuki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>

#import "LoadingView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, AVAudioPlayerDelegate, AVAudioSessionDelegate>
{
    NSInteger duration;
    
    NSURLConnection *connectionForPlaySong;
    NSMutableData *dataForPlaySong;

}


@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSString *domain;
@property (nonatomic, retain) AVAudioPlayer *currentAudioPlayer;
@property (nonatomic, retain) NSDictionary *currentSong;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, retain) NSMutableArray *queueList;
@property (nonatomic, retain) LoadingView *loadingView;

- (void)addLoadingView;
- (void)removeLoadingView;
- (void)addSongsToQueue:(NSArray *)songs;
- (void)playNextSong;
- (void)playSelectedSong:(NSInteger)index;

@end
