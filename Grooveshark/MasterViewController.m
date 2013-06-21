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
    NSInteger musicNo;
    NSURLConnection *connectionForGetSongs;
    NSURLConnection *connectionForPlaySong;
    NSMutableData *data;
    AVAudioPlayer *audioPlayer;
    AVAudioPlayer *nextAudioPlayer;
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
    
    songs = [[NSMutableArray alloc] init];
    NSString *apiUrl = @"http://0.0.0.0:3000/favorites";
    NSURL *url = [NSURL URLWithString: apiUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    connectionForGetSongs = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
{
    data = [[NSMutableData alloc] initWithData:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)_data;
{
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
        nextAudioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
        [nextAudioPlayer prepareToPlay];
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
    if (indexPath.row == musicNo) {
        if (audioPlayer.playing == NO) {
            [audioPlayer play];
        } else {
            [audioPlayer pause];
        }
    } else {
        musicNo = indexPath.row;
        [self playSong:musicNo];
    }
}

- (void)playSong:(NSInteger)index
{
    NSDictionary *song = [[NSDictionary alloc] initWithDictionary:[songs objectAtIndex:index]];
    NSString *songID = [song valueForKey:@"songID"];
    //    NSString *songURL = [NSString stringWithFormat:@"https://rails-grooveshark-app.herokuapp.com/songs/%@", songID];
    NSString *songURL = [NSString stringWithFormat:@"http://0.0.0.0:3000/songs/%@", songID];
    songURL = [songURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:songURL]];
    connectionForPlaySong = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)dispatchTimer
{
    dispatch_queue_t queue = dispatch_queue_create("timerQueue", 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"%f", audioPlayer.currentTime);
//        if (audioPlayer.duration - audioPlayer.currentTime < 30.0) {
        if (audioPlayer.currentTime > 10.0) {
//            dispatch_source_cancel(timer);
            NSLog(@"musciNoを更新します %d >> %d", musicNo, musicNo + 1);
            musicNo = musicNo + 1;
            [self playSong:musicNo];
        }
        if (audioPlayer.currentTime > 30.0) {
            [audioPlayer stop];
        }
        if (audioPlayer.playing == NO) {
            dispatch_source_cancel(timer);
            NSLog(@"Timer Stop Now !!");
            audioPlayer = nextAudioPlayer;
            [audioPlayer play];
            [self dispatchTimer];
        }
        
    });
    
    dispatch_source_set_cancel_handler(timer, ^{
        printf("end\n");
    });
    
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 0);
    uint64_t interval = NSEC_PER_SEC; // 1 sec
    
    dispatch_source_set_timer(timer, start, interval, 0);
    
    printf("start\n");
    
    dispatch_resume(timer);
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
