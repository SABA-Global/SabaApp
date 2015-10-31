//
//  HostViewController.m
//  SabaApp
//
//  Created by Syed Naqvi on 10/27/15.
//  Copyright © 2015 Naqvi. All rights reserved.
//

#import "HostViewController.h"
#import "ContentViewController.h"
#import "SabaClient.h"
#import "DailyProgramViewController.h"
#import "DBManager.h"
#import "Program.h"
#import "WeeklyPrograms.h"

#import <Google/Analytics.h>

extern NSString *const kWeeklyScheduleView;
extern NSString *const kEventCategoryWeeklySchedule;

// Event Labels
extern NSString *const kRefreshEventLabel;

//Event Actions
extern NSString *const kRefreshEventActionSwiped;
extern NSString *const kRefreshEventActionClicked;


@interface HostViewController ()<ViewPagerDataSource, ViewPagerDelegate>
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property bool isRefreshInProgress; // keeps track that if refresh is in Progress. Another refresh should not kick in at the sametime.

@property (nonatomic) NSUInteger numberOfTabs;
@property (nonatomic, strong) NSArray *arrayDays;
@property (nonatomic, strong) NSString *today;
@property (nonatomic) BOOL isTodayAvailable;
@property (nonatomic) long todayIndex;
@end

@implementation HostViewController

-(void) setupNavigationBar{
    [self.navigationController setNavigationBarHidden:NO];
    [[SabaClient sharedInstance] setupNavigationBarFor:self];
    // Use standard refresh button.
    UIBarButtonItem *refreshBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                             target:self
                                             action:@selector(onRefresh)];
    self.navigationItem.rightBarButtonItem = refreshBarButtonItem;

    self.navigationItem.title = @"Weekly Schedule";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate = self;
    self.arrayDays = [[DBManager sharedInstance] getUniqueDays];
    
    self.isTodayAvailable = [self isTodayAvailableInSchedule];
    [self setupNavigationBar];
    [self loadContent];
    
    [[SabaClient sharedInstance] showSpinner:YES];
    [self getWeeklyPrograms];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self performSelector:@selector(loadContent) withObject:nil afterDelay:0.0];
    [self selectTabAtIndex:self.todayIndex-1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) isTodayAvailableInSchedule{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    self.today = [dateFormatter stringFromDate:[NSDate date]];
    
    BOOL found = NO;
    self.todayIndex = 0;
    for (NSString *day in self.arrayDays) {
        self.todayIndex++;
        if ([day isEqualToString:self.today]) {
            found = YES;
            break;
        }
    }
    return found;
}

#pragma mark - Setters
- (void)setNumberOfTabs:(NSUInteger)numberOfTabs {
    
    // Set numberOfTabs
    _numberOfTabs = numberOfTabs;
    
    // Reload data
    [self reloadData];
    
}

#pragma mark - Helpers
- (void)loadContent {
    self.numberOfTabs = [self.arrayDays count];
}

#pragma mark - Interface Orientation Changes
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    // Update changes after screen rotates
    [self performSelector:@selector(setNeedsReloadOptions) withObject:nil afterDelay:duration];
}

#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    return self.numberOfTabs;
}
- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index {
    
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    
    label.font = [UIFont boldSystemFontOfSize:16.0];
    label.text = [self.arrayDays objectAtIndex:index];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];

    return label;
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    DailyProgramViewController *dailyProgramVC = [[DailyProgramViewController alloc] init];
    dailyProgramVC.day = [self.arrayDays objectAtIndex:index];
    return dailyProgramVC;
}

#pragma mark - ViewPagerDelegate
- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value {

switch (option) {
        case ViewPagerOptionStartFromSecondTab:
            return 0.0;
        case ViewPagerOptionCenterCurrentTab:
            return 1.0;
        case ViewPagerOptionTabLocation:
            return 0.0;
        case ViewPagerOptionTabHeight:
            return 49.0;
        case ViewPagerOptionTabOffset:
            return 36.0;
        case ViewPagerOptionTabWidth:
            //return UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 128.0 : 96.0;
            return value;
        case ViewPagerOptionFixFormerTabsPositions:
            return 1.0;
        case ViewPagerOptionFixLatterTabsPositions:
            return 1.0;
        default:
            return value;
    }
}
- (UIColor *)viewPager:(ViewPagerController *)viewPager colorForComponent:(ViewPagerComponent)component withDefault:(UIColor *)color {
    
    switch (component) {
        case ViewPagerIndicator:
            return [[UIColor redColor] colorWithAlphaComponent:0.64];
        case ViewPagerTabsView:
            return [[UIColor lightGrayColor] colorWithAlphaComponent:0.32];
        case ViewPagerContent:
            return [[UIColor darkGrayColor] colorWithAlphaComponent:0.32];
        default:
            return color;
    }
}

-(void) getWeeklyPrograms{
    
    // get the program from the local database. If records are there then no need to make a network call.
    NSArray* programs = [[DBManager sharedInstance ] getSabaPrograms:@"Weekly Programs"];
    
    if(programs != nil && programs.count > 0){
        [[SabaClient sharedInstance] showSpinner:NO];
        return;
    }
    
    [[SabaClient sharedInstance] getWeeklyPrograms:^(NSString* programName, NSArray *programs, NSError *error) {
        [[SabaClient sharedInstance] showSpinner:NO];
        [self.refreshControl endRefreshing];
        self.isRefreshInProgress=false;
        
        if (error) {
            NSLog(@"Error getting WeeklyPrograms: %@", error);
        } else {
            NSArray *weeklyPrograms = [Program fromWeeklyPrograms:[WeeklyPrograms fromArray: programs]];
            [[DBManager sharedInstance] saveSabaPrograms:weeklyPrograms :@"Weekly Programs"];
            NSArray *dailyPrograms = [WeeklyPrograms fromArray:programs];
            [[DBManager sharedInstance] saveWeeklyPrograms:dailyPrograms];

            if(self.numberOfTabs == 0){
                self.arrayDays = [[DBManager sharedInstance] getUniqueDays];
                self.isTodayAvailable = [self isTodayAvailableInSchedule];
                
                [self loadContent];
            }
            [self selectTabAtIndex:self.todayIndex-1];
        }
    }];
}

-(void) refresh{
    // remove the data from database.
    [[DBManager sharedInstance] deleteSabaPrograms:@"Weekly Programs"];
    [[DBManager sharedInstance] deleteDailyPrograms];
    
    // request for latest weekly programs.
    [self getWeeklyPrograms];
}

-(void) onRefresh{
    if(self.isRefreshInProgress)
        return;
    
    [self trackRefreshEventAction:kRefreshEventActionClicked withLabel:kRefreshEventLabel];
    self.isRefreshInProgress = true;
    [[SabaClient sharedInstance] showSpinner:YES];
    [self refresh];
}
#pragma mark - Analytics

- (void)trackRefreshEventAction:(NSString*) action withLabel:(NSString*) label{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // Create events to track the selected image and selected name.
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kEventCategoryWeeklySchedule
                                                          action:action
                                                           label:label
                                                           value:nil] build]];
}

@end
