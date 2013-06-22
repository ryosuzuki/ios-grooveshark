//
//  MasterViewController.m
//  Grooveshark
//
//  Created by Ryo Suzuki on 6/21/13.
//  Copyright (c) 2013 Ryo Suzuki. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

@interface MasterViewController () {
    NSMutableArray *songs;
    NSURLConnection *connectionForGetSongs;
    NSURLConnection *connectionForPlaySong;
    NSMutableData *data;
    NSInteger currentIndex;
    NSInteger nextIndex;
    AVAudioPlayer *currentAudioPlayer;
    AVAudioPlayer *nextAudioPlayer;

    LoadingView *loadingView;
}
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Ryo's Favorite";
    
    currentIndex = -1;
    nextIndex = -1;
    songs = [[NSMutableArray alloc] init];
    currentAudioPlayer = NULL;
    loadingView = [[LoadingView alloc] initWithFrame:self.view.frame];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(nowPlaying:) userInfo:nil repeats:YES ];
    [timer fire];
    
    NSString *apiUrl = @"https://rails-grooveshark-app.herokuapp.com/favorites";
    NSURL *url = [NSURL URLWithString: apiUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    connectionForGetSongs = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
    NSLog(@"Receive Response");
    data = [[NSMutableData alloc] initWithData:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)_data;
{
    NSLog(@"Receive Data");
	[data appendData:_data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)_connection;
{
    if (_connection == connectionForGetSongs) {
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUnicodeStringEncoding];
        songs = [NSJSONSerialization JSONObjectWithData:jsonData options: NSJSONReadingAllowFragments error:nil];
        [self.tableView reloadData];
    } else if (_connection == connectionForPlaySong) {
        NSLog(@"Finish Load Song");
        nextAudioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
        [nextAudioPlayer prepareToPlay];
        if (currentAudioPlayer == NULL) {
            [loadingView removeFromSuperview];
            self.tableView.scrollEnabled = YES;
            
            currentAudioPlayer = nextAudioPlayer;
            [currentAudioPlayer play];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return songs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDictionary *song = [[NSDictionary alloc] initWithDictionary:[songs objectAtIndex:indexPath.row]];
    cell.textLabel.text = [song valueForKey:@"songName"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == currentIndex) {
        if (currentAudioPlayer.playing == NO) {
            [currentAudioPlayer play];
        } else {
            [currentAudioPlayer pause];
        }
    } else {
        currentIndex = indexPath.row;
        if (currentAudioPlayer != NULL) {
            [currentAudioPlayer stop];
            currentAudioPlayer = NULL;
        }
        [self playSong:currentIndex];
        
        [self.tableView addSubview:loadingView];
        self.tableView.scrollEnabled = NO;
    }
}

- (void)playSong:(NSInteger)index
{
    NSDictionary *song = [[NSDictionary alloc] initWithDictionary:[songs objectAtIndex:index]];
    NSString *songID = [song valueForKey:@"songID"];
    //    NSString *songURL = [NSString stringWithFormat:@"https://rails-grooveshark-app.herokuapp.com/songs/%@", songID];
    NSString *songURL = [NSString stringWithFormat:@"https://rails-grooveshark-app.herokuapp.com/songs/%@", songID];
    songURL = [songURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", songURL);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:songURL]];
    connectionForPlaySong = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)nowPlaying:(NSTimer *)timer
{
    if (currentAudioPlayer.playing == YES) {
        NSInteger current = (int)currentAudioPlayer.currentTime;
        NSInteger remain = (int)(currentAudioPlayer.duration - currentAudioPlayer.currentTime);
        NSLog(@"Current: %i - Remain : %i", current, remain);
        if (remain < 60 & nextIndex != currentIndex + 1) {
            nextIndex = currentIndex + 1;
            [self playSong:nextIndex];
        }
        if (remain == 0) {
            [currentAudioPlayer stop];
            currentAudioPlayer = nextAudioPlayer;
            [currentAudioPlayer play];
        }
    } else {
        NSLog(@"Timer Running");
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *song = songs[indexPath.row];
        [[segue destinationViewController] setDetailItem:song];
    }
}
*/
 
@end
