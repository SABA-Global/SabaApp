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

@interface AppDelegate ()

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

	// Following code is for Notfications and Alarms etc.
//	//http://stackoverflow.com/questions/24100313/ask-for-user-permission-to-receive-uilocalnotifications-in-ios-8/24161903#24161903
//	if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
//		[application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
	return UIInterfaceOrientationMaskPortrait;
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
@end
