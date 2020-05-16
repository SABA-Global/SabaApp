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
#import "CalendarHelper.h"
#import <EventKit/EventKit.h>

@import Firebase;
//#import <Google/Analytics.h>

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


@property (nonatomic) bool isAccessToEventStoreGranted;
// The database with calendar events and reminders
@property (strong, nonatomic) EKEventStore *eventStore;

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
    
    self.tabsViewBackgroundColor = [UIColor clearColor];
    [self setupNavigationBar];
    [self loadContent];
    
    [[SabaClient sharedInstance] showSpinner:YES];
    [self getWeeklyPrograms];
    
    //Create the Event Store
    self.eventStore = [[EKEventStore alloc]init];
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
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    
//    // Create events to track the selected image and selected name.
//    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kEventCategoryWeeklySchedule
//                                                          action:action
//                                                           label:label
//                                                           value:nil] build]];
}

// Debug code - ignore it...
////Check if iOS6 or later is installed on user's device *******************
//if([self.eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
//    
//    //Request the access to the Calendar
//    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted,NSError* error){
//        
//        //Access not granted-------------
//        if(!granted){
//            NSString *message = @"Hey! I Can't access your Calendar... check your privacy settings to let me in!";
//            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Warning"
//                                                               message:message
//                                                              delegate:self
//                                                     cancelButtonTitle:@"Ok"
//                                                     otherButtonTitles:nil,nil];
//            //Show an alert message!
//            //UIKit needs every change to be done in the main queue
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [alertView show];
//            }
//                           );
//            
//            //Access granted------------------
//        }else{
//            
//        }
//    }];
//}

////Device prior to iOS 6.0  *********************************************
//else{
//    NSLog(@"Prior to iOS 6");
//}

-(void)askPermissionForCalendarAccess {
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    /* iOS 6 requires the user grant your application access to the Event Stores */
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        /* iOS Settings > Privacy > Calendars > MY APP > ENABLE | DISABLE */
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            
            if (granted) {
                
                NSLog(@"granted");
                //This method checks to make sure the calendar I want exists, then move on from there...
                
            } else {
                
                //put error popup code here.
                NSLog(@"denied");
                ;
            }
        }];
    }
}



// 1
- (EKEventStore *)eventStore {
    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
    }
    return _eventStore;
}


- (void)updateAuthorizationStatusToAccessEventStore {
    // 2
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    
    switch (authorizationStatus) {
            // 3
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted: {
            self.isAccessToEventStoreGranted = NO;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Access Denied"
                                                                message:@"This app doesn't have access to your Reminders." delegate:nil
                                                      cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alertView show];
            break;
        }
            
            // 4
        case EKAuthorizationStatusAuthorized:
            self.isAccessToEventStoreGranted = YES;
            break;
            
            // 5
        case EKAuthorizationStatusNotDetermined: {
            __weak HostViewController *weakSelf = self;
            [self.eventStore requestAccessToEntityType:EKEntityTypeReminder
                                            completion:^(BOOL granted, NSError *error) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    weakSelf.isAccessToEventStoreGranted = granted;
                                                });
                                            }];
            break;
        }
    }
}

#pragma mark -
#pragma mark Access Calendar

// Check the authorization status of our application for Calendar
-(void)checkEventStoreAccessForCalendar
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (status)
    {
            // Update our UI if the user has granted access to their Calendar
        case EKAuthorizationStatusAuthorized: [self accessGrantedForCalendar];
            break;
            // Prompt the user for access to Calendar if there is no definitive answer
        case EKAuthorizationStatusNotDetermined: [self requestCalendarAccess];
            break;
            // Display a message if the user has denied or restricted access to Calendar
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Privacy Warning" message:@"Permission was not granted for Calendar"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}


// Prompt the user for access to their Calendar
-(void)requestCalendarAccess
{
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             HostViewController * __weak weakSelf = self;
             // Let's ensure that our code will be executed from the main queue
             dispatch_async(dispatch_get_main_queue(), ^{
                 // The user has granted access to their Calendar; let's populate our UI with all events occuring in the next 24 hours.
                 [weakSelf accessGrantedForCalendar];
             });
         }
     }];
}


// This method is called when the user has granted permission to Calendar
-(void)accessGrantedForCalendar
{
    NSLog(@"YAYEEEEEEEEEEEEEEEEE");
}

@end
