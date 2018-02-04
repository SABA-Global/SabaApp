//
//  AppDelegate.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/23/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "AppDelegate.h"

#import "DBManager.h"
#import	"SabaClient.h"
#import "MainViewController.h"
#import "WeeklyScheduleViewController.h"
#import "SplashScreenViewController.h"
#import "Constants.h"

@import Firebase;

NSString *const kApplicationLaunched		= @"App Launched";

// Dispatch interval for automatic dispatching of hits to Google Analytics.
// Values 0.0 or less will disable periodic dispatching. The default dispatch interval is 120 secs.
static NSTimeInterval const kSabaDispatchInterval = 120.0;

//// Set log level to have the Google Analytics SDK report debug information only in DEBUG mode.
//#if DEBUG
//static GAILogLevel const kSabaLogLevel = kGAILogLevelVerbose;
//#else
//static GAILogLevel const kSabaLogLevel = kGAILogLevelWarning;
//#endif

@interface AppDelegate ()

//@property(nonatomic, copy) void (^dispatchHandler)(GAIDispatchResult result);

- (void)initializeGoogleAnalytics;
- (void)sendHitsInBackground;

@end

@implementation AppDelegate

SplashScreenViewController *ssvc = nil;
MainViewController *mainvc = nil;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	
	// Initialize databaseManager
	DBManager *databaseManager = [[DBManager sharedInstance] init];
	[databaseManager prepareDatabase];
	
	// get HijriDate.
	[self getHijriDate];
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	ssvc = [[SplashScreenViewController alloc] init];
	mainvc = [[MainViewController alloc] init];
	
	// very important to set the NavigationController correctly. Later on we can push another controller on it.
	UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:mainvc];
	
	[mainvc.navigationController pushViewController:ssvc animated:NO];
	
	self.window.rootViewController = nvc;
	self.window.backgroundColor = [UIColor whiteColor];
	[self.window makeKeyAndVisible];
	
	// setting the color of status bar.
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	
	// tint color for navigation bar
	[[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

	
	//[self initializeGoogleAnalytics];
	// Following code is for Notfications and Alarms etc.
//	//http://stackoverflow.com/questions/24100313/ask-for-user-permission-to-receive-uilocalnotifications-in-ios-8/24161903#24161903
//	if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
//		[application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    [FIRApp configure];
//	}
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	
	//[self sendHitsInBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	
	// Restore the dispatch interval since dispatchWithCompletionHandler:
	// disables automatic dispatching.
	//[GAI sharedInstance].dispatchInterval = kSabaDispatchInterval;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
#else
- (UIInterfaceOrientationMask)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
#endif
{
    // iPhone doesn't support upside down by default, while the iPad does.  Override to allow all orientations always, and let the root view controller decide what's allowed (the supported orientations mask gets intersected).
    NSUInteger supportedInterfaceOrientations = (1 << UIInterfaceOrientationPortrait);
    
    //| (1 << UIInterfaceOrientationLandscapeLeft) | (1 << UIInterfaceOrientationLandscapeRight) | (1 << UIInterfaceOrientationPortraitUpsideDown);
    
    return supportedInterfaceOrientations;
}


-(void) getHijriDate{
	[[SabaClient sharedInstance] getHijriDateFromWeb:^(NSDictionary *jsonResponse, NSError *error) {
		if(error){
			NSLog(@"Error getting HijriDate: %@", error.localizedDescription);
		} else {
			NSLog(@"HijriDate: %@", jsonResponse[@"hijridate"]);
			[[SabaClient sharedInstance] storeHijriDate:jsonResponse[@"hijridate"]];
		}
	}];
}

//-(void) setupGoogleAnalytics{
//    // Configure tracker from GoogleService-Info.plist.
//    NSError *configureError;
//    [[GGLContext sharedInstance] configureWithError:&configureError];
//    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
//    
//    // Optional: configure GAI options.
//    GAI *gai = [GAI sharedInstance];
//    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
//    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
//}
//
//- (void)initializeGoogleAnalytics {
//    // Configure tracker from GoogleService-Info.plist.
//    NSError *configureError;
//    [[GGLContext sharedInstance] configureWithError:&configureError];
//    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
//    
//    // Optional: configure GAI options.
//    // Automatically send uncaught exceptions to Google Analytics.
//    [GAI sharedInstance].trackUncaughtExceptions = YES;
//    
//    // Set the dispatch interval for automatic dispatching.
//    [GAI sharedInstance].dispatchInterval = kSabaDispatchInterval;
//    
//    // Set the appropriate log level for the default logger.
//    [GAI sharedInstance].logger.logLevel = kSabaLogLevel;
//    
//    //Provide a name for the screen and execute tracking.
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//
//    // Create events to track the selected image and selected name.
//    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kApplicationLaunched
//                                                          action:kApplicationLaunched
//                                                           label:@"Cold Start"
//                                                           value:nil] build]];
//}

// This method sends any queued hits when the app enters the background.
//- (void)sendHitsInBackground {
//    __block BOOL taskExpired = NO;
//    
//    __block UIBackgroundTaskIdentifier taskId =
//    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
//        taskExpired = YES;
//    }];
//    
//    if (taskId == UIBackgroundTaskInvalid) {
//        return;
//    }
//    
//    __weak AppDelegate *weakSelf = self;
//    self.dispatchHandler = ^(GAIDispatchResult result) {
//        // Dispatch hits until we have none left, we run into a dispatch error,
//        // or the background task expires.
//        if (result == kGAIDispatchGood && !taskExpired) {
//            [[GAI sharedInstance] dispatchWithCompletionHandler:weakSelf.dispatchHandler];
//        } else {
//            [[UIApplication sharedApplication] endBackgroundTask:taskId];
//        }
//    };
//    
//    [[GAI sharedInstance] dispatchWithCompletionHandler:self.dispatchHandler];
//}

@end
