//
//  LiveStreamViewController.m
//  SabaApp
//
//  Created by Syed Naqvi on 6/11/16.
//  Copyright © 2016 Naqvi. All rights reserved.
//

#import "LiveStreamViewController.h"
#import "SabaClient.h"

// Third party libraries
//#import <Google/Analytics.h>

// Category
extern NSString *const kEventCategoryLiveStreamView;

// Error
extern NSString *const kErrorPlayingVideo;

// View
extern NSString *const kLiveStreamView;

//event
extern NSString *const kLiveStreamMajlisPlayed;
extern NSString *const kLiveStreamMajlisPaused;

@interface LiveStreamViewController ()<YTPlayerViewDelegate>

@end

@implementation LiveStreamViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.playerView.delegate = self;
   // self.background = [UIColor clearColor];
    [self.playerView loadWithVideoId:self.videoId];
    self.navigationItem.title = self.hallName;
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}

-(void) setupNavigationBar{
    [self.navigationController setNavigationBarHidden:NO];
    [[SabaClient sharedInstance] setupNavigationBarFor:self];
    
    self.navigationItem.title = @"Stream";
}

- (void)viewWillAppear:(BOOL)animated{
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    NSString *screenName = @"LiveStream Majlis in ";
    screenName =[screenName stringByAppendingString:self.hallName];
    
//    [tracker set:kGAIScreenName value:screenName];
//    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state {
    switch (state) {
        case kYTPlayerStatePlaying:
            NSLog(@"Started playback");
            [self trackEventAction:kLiveStreamMajlisPlayed withLabel:self.hallName];
            break;
            
        case kYTPlayerStatePaused:
            NSLog(@"Paused playback");
            [self trackEventAction:kLiveStreamMajlisPaused withLabel:self.hallName];
            break;
            
        default:
            break;
    }
}

#pragma mark YTPlayerViewDelegate
- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView{
    NSLog(@"playerViewDidBecomeReady: ");
}

- (void)playerView:(YTPlayerView *)playerView didChangeToQuality:(YTPlaybackQuality) quality{
    NSLog(@"playerView:didChangeToQuality");
}

- (void)playerView:(YTPlayerView *)playerView receivedError:(YTPlayerError)error{
    NSLog(@"playerView:receivedError");
    [self trackEventAction:kErrorPlayingVideo withLabel:[self getErrorDescription:error]];
}

// reference: https://developers.google.com/youtube/iframe_api_reference#Events
-(NSString*)getErrorDescription:(int)errorCode{
    switch(errorCode){
            //The request contains an invalid parameter value. For example, this error occurs if you specify a video ID that does not have 11 characters, or if the video ID contains invalid characters, such as exclamation points or asterisks.
        case kYTPlayerErrorInvalidParam:
            return @"Error Invalid Params.";
            
        //The requested content cannot be played in an HTML5 player or another error related to the HTML5 player has occurred.
        case kYTPlayerErrorHTML5Error:
            return @"Error HTML5 Error.";
        
        //The video requested was not found. This error occurs when a video has been removed (for any reason) or has been marked as private.
        case kYTPlayerErrorVideoNotFound:
             return @"Error Video Not Found.";
            
            //101 – The owner of the requested video does not allow it to be played in embedded players.
        case kYTPlayerErrorNotEmbeddable: // Functionally equivalent error codes 101 and
            return @"Error Not Embeddable.";
            
        case kYTPlayerErrorUnknown:
            return @"Error Unknown.";
            
        default:
            return @"Error not mapped yet.";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Analytics

-(void) sendTrackScreenLaunchEvent{
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker set:kGAIScreenName value:kLiveStreamView];
//    [tracker set:kGAITitle value:self.hallName];
//    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)trackEventAction:(NSString*) action withLabel:(NSString*) label{
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    
//    // Create events to track the selected image and selected name.
//    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kEventCategoryLiveStreamView
//                                                          action:action
//                                                           label:label
//                                                           value:nil] build]];
}

@end
