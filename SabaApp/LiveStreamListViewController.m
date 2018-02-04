//
//  LiveStreamListViewController.m
//  SabaApp
//
//  Created by Syed Naqvi on 6/11/16.
//  Copyright © 2016 Naqvi. All rights reserved.
//

#import "LiveStreamListViewController.h"
#import "LiveStreamOptionViewCell.h"
#import "LiveStreamViewController.h"
#import "SabaClient.h"

// Third party libraries
@import Firebase;
//#import <Google/Analytics.h>

// Category
extern NSString *const kEventCategoryLiveStreamFeeds;

// Event Labels
extern NSString *const kLiveStreamFeedsLabel;

// Error
extern NSString *const kErrorLiveStreamFeeds;

// View
extern NSString *const kLiveStreamListView;

@interface LiveStreamListViewController ()<UICollectionViewDataSource,
                                                UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *liveStreamFeeds;

@end

@implementation LiveStreamListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"LiveStreamOptionViewCell" bundle:nil] forCellWithReuseIdentifier:@"LiveStreamOptionViewCell"];
    //[self.navigationController setNavigationBarHidden:YES]; // shouldn't show NavigationBar on this controller.
    
    [self setupNavigationBar];
    [[SabaClient sharedInstance] showSpinner:YES];
    [self getLiveStreamFeeds];
}

- (void)viewWillAppear:(BOOL)animated{
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker set:kGAIScreenName value:kLiveStreamListView];
//    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma LiveStreamFeed Request.
-(void) getLiveStreamFeeds{
    [[SabaClient sharedInstance] getLiveStreamFeeds:^(NSDictionary *feeds, NSError *error) {
        if (error) {
            NSLog(@"Error getting liveStreamFeeds: %@", error);
            [self sendTrackLiveStreamViewEventAction:kErrorLiveStreamFeeds withLabel:kLiveStreamFeedsLabel];
            
        } else {
            self.liveStreamFeeds = [LiveStreamFeed fromDictionary:feeds];
            [self.collectionView reloadData];
        }
        [[SabaClient sharedInstance] showSpinner:NO];
    }];
}

#pragma CollectionView
// number of items in section
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.liveStreamFeeds.count;
}

//// sets the size of cell dynamically as per phone size.
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size;
    
    size.height = self.collectionView.frame.size.height/2;
    size.width = self.collectionView.frame.size.width/2;
    
    return size;
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    LiveStreamOptionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LiveStreamOptionViewCell" forIndexPath:indexPath];
    
    // This is how you change the background color when we click on the tile. We might find a better sol.
    UIView *bgSelectedColorView = [[UIView alloc] init];
    bgSelectedColorView.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:.10];
    [cell setSelectedBackgroundView:bgSelectedColorView];
    
    //	UIView *bgColorView = [[UIView alloc] init];
    //	bgColorView.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0];
    //	[cell setBackgroundView:bgColorView];
    
    LiveStreamFeed *feed = [self.liveStreamFeeds objectAtIndex:indexPath.row];
    if(feed != nil)
        cell.liveStreamTitle.text = feed.hallName;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    LiveStreamViewController *controller = [[LiveStreamViewController alloc]init];
    LiveStreamFeed *feed = [self.liveStreamFeeds objectAtIndex:indexPath.row];
    if(feed != nil){
        controller.hallName = feed.hallName;
        controller.videoId = feed.videoId;
    }
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.25;
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromRight;
    
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:controller animated:NO];
}

-(void) setupNavigationBar{
    [self.navigationController setNavigationBarHidden:NO];
    [[SabaClient sharedInstance] setupNavigationBarFor:self];
    
    self.navigationItem.title = @"Streaming";
}

-(void) onRefresh{

}

#pragma mark - Analytics

- (void) sendTrackLiveStreamViewEventAction:(NSString*) action withLabel:(NSString*) label{
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//
//    // Create events to track the selected image and selected name.
//    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kEventCategoryLiveStreamFeeds
//                                                          action:action
//                                                           label:label
//                                                           value:nil] build]];
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

@end

@implementation LiveStreamFeed

-(id)init{
    self = [super init];
    return self;
}

+(NSArray*) fromDictionary:(NSDictionary * )dictionary{
    NSMutableArray *feeds = [NSMutableArray array];
    for (NSString *key in [dictionary allKeys]){
        LiveStreamFeed *feed = [[LiveStreamFeed alloc]init];
        feed.hallName = key;
        feed.videoId = [[dictionary objectForKey:key] objectForKey:@"path"];
        [feeds addObject:feed];
    }
    
    return feeds;
}
    
@end
