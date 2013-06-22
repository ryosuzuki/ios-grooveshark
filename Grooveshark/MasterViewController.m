//
//  MasterViewController.m
//  Grooveshark
//
//  Created by Ryo Suzuki on 6/21/13.
//  Copyright (c) 2013 Ryo Suzuki. All rights reserved.
//

#import "MasterViewController.h"
#import "AppDelegate.h"
#import "DetailViewController.h"

@interface MasterViewController()
{
    NSMutableArray *songs;
    
    NSURLConnection *connectionForGetSongs;
    NSMutableData *dataForGetSongs;
    
    AppDelegate *appDelegate;
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
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
    songs = [[NSMutableArray alloc] init];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    self.playAllButton.target = self;
    self.playAllButton.action = @selector(addQueue);

    
    NSString *apiUrl = @"https://rails-grooveshark-app.herokuapp.com/favorites";
    apiUrl = @"https://rails-grooveshark-app.herokuapp.com/songs";
    NSURL *url = [NSURL URLWithString: apiUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    connectionForGetSongs = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (void)connection:(NSURLConnection *)_connection didReceiveResponse:(NSURLResponse *)_response;
{
    NSLog(@"Received Response");
    if (_connection == connectionForGetSongs) {
        dataForGetSongs = [[NSMutableData alloc] initWithData:0];
    }
}

- (void)connection:(NSURLConnection *)_connection didReceiveData:(NSData *)_data;
{
    if (_connection == connectionForGetSongs) {
        [dataForGetSongs appendData:_data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)_connection;
{
    NSLog(@"Finish Load Song");
    if (_connection == connectionForGetSongs) {
        NSString *jsonString = [[NSString alloc] initWithData:dataForGetSongs encoding:NSUTF8StringEncoding];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUnicodeStringEncoding];
        songs = [NSJSONSerialization JSONObjectWithData:jsonData options: NSJSONReadingAllowFragments error:nil];
        [self.tableView reloadData];
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
    NSDictionary *song = songs[indexPath.row];
    [appDelegate addSongsToQueue:[NSArray arrayWithObjects:song, nil]];
    [appDelegate addLoadingView];
}

- (void)addQueue
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    DetailViewController *detailViewController = (DetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [appDelegate addLoadingView];
    [appDelegate addSongsToQueue:songs];

}

/*
- (void)playSelectedSong:(NSInteger)index
{
    NSDictionary *song = [[NSDictionary alloc] initWithDictionary:[songs objectAtIndex:index]];
    NSString *songID = [song valueForKey:@"songID"];
    NSString *songURL = [NSString stringWithFormat:@"https://rails-grooveshark-app.herokuapp.com/songs/%@", songID];
    songURL = [songURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", songURL);

    if (songID != NULL) {
        dataForPlaySong = [[NSMutableData alloc] initWithData:0];
        [connectionForPlaySong cancel];
        [appDelegate.currentAudioPlayer stop];
        appDelegate.currentAudioPlayer = [[AVAudioPlayer alloc] initWithData:dataForPlaySong error:nil];
        appDelegate.currentSong = song;
        currentIndex = index;
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:songURL]];
        connectionForPlaySong = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}


- (void)nowPlaying:(NSTimer *)timer
{
    NSInteger current = (int)appDelegate.currentAudioPlayer.currentTime;
    NSInteger remain = (int)(appDelegate.currentAudioPlayer.duration - appDelegate.currentAudioPlayer.currentTime);
    NSLog(@"Current: %i - Remain : %i", current, remain);
    if (duration > 0 & current == duration) {
//    if (current == 30) {
        [self playSelectedSong:self.currentIndex + 1];
    }
    if (current == 0 & appDelegate.currentAudioPlayer.playing == NO) {
        appDelegate.currentAudioPlayer = [[AVAudioPlayer alloc] initWithData:dataForPlaySong error:nil];
        [appDelegate.currentAudioPlayer prepareToPlay];
        [appDelegate.currentAudioPlayer play];
    }
}

- (void)controllSong:(UIBarButtonItem *)buttonItem
{
    if (appDelegate.currentAudioPlayer.playing == YES) {
        [appDelegate.currentAudioPlayer pause];
    } else {
        [appDelegate.currentAudioPlayer play];
    }
    
}
*/

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
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *song = songs[currentIndex];
        NSLog(@"%@", song);
        [[segue destinationViewController] setDetailItem:song];
    }
}
*/ 
 
@end
