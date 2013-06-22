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

@interface MasterViewController () {
    NSMutableArray *songs;

    NSURLConnection *connectionForGetSongs;
    NSURLConnection *connectionForPlaySong;
    NSMutableData *dataForGetSongs;
    NSMutableData *dataForPlaySong;
    
    NSInteger currentIndex;
    NSInteger duration;
    
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
    
    currentIndex = -1;
    songs = [[NSMutableArray alloc] init];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(nowPlaying:) userInfo:nil repeats:YES ];
    [timer fire];
    
    NSString *apiUrl = @"https://rails-grooveshark-app.herokuapp.com/favorites";
    NSURL *url = [NSURL URLWithString: apiUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    connectionForGetSongs = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)_connection didReceiveResponse:(NSURLResponse *)_response;
{
    NSLog(@"Received Response");
    if (_connection == connectionForGetSongs) {
        dataForGetSongs = [[NSMutableData alloc] initWithData:0];
    } else if (_connection == connectionForPlaySong) {
        dataForPlaySong = [[NSMutableData alloc] initWithData:0];
        [appDelegate removeLoadingView];
    }
}

- (void)connection:(NSURLConnection *)_connection didReceiveData:(NSData *)_data;
{
    if (_connection == connectionForGetSongs) {
        [dataForGetSongs appendData:_data];
    } else if (_connection == connectionForPlaySong) {
        [dataForPlaySong appendData:_data];
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
    } else if (_connection == connectionForPlaySong) {
        duration = (int)appDelegate.currentAudioPlayer.duration;
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
    currentIndex = indexPath.row;
    [self selectSong:currentIndex];
    [appDelegate addLoadingView];
}

- (void)selectSong:(NSInteger)index
{
    dataForPlaySong = [[NSMutableData alloc] initWithData:0];
    [connectionForPlaySong cancel];
    [appDelegate.currentAudioPlayer stop];
    appDelegate.currentAudioPlayer = [[AVAudioPlayer alloc] initWithData:dataForPlaySong error:nil];
        
    NSDictionary *song = [[NSDictionary alloc] initWithDictionary:[songs objectAtIndex:index]];
    appDelegate.currentSong = song;
    NSString *songID = [song valueForKey:@"songID"];
    NSString *songURL = [NSString stringWithFormat:@"https://rails-grooveshark-app.herokuapp.com/songs/%@", songID];
    songURL = [songURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", songURL);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:songURL]];
    connectionForPlaySong = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

- (void)nextSong
{
    currentIndex = currentIndex + 1;
    [self selectSong:currentIndex];
}

- (void)nowPlaying:(NSTimer *)timer
{
    NSInteger current = (int)appDelegate.currentAudioPlayer.currentTime;
    NSInteger remain = (int)(appDelegate.currentAudioPlayer.duration - appDelegate.currentAudioPlayer.currentTime);
    NSLog(@"Current: %i - Remain : %i", current, remain);
    if (duration > 0 & current == duration) {
        [self nextSong];
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
