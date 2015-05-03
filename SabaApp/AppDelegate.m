//
//  AppDelegate.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/23/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "WeeklyScheduleViewController.h"

// Third party includes..
#import <PayPalMobile.h>

//PayPal Keys
NSString *kPayPalClientId = @"AYIrAAhanrQ2f5I5oE1ks213YFi4Y5YVxXLZE8VwBN94idvUZ3NfIQeRv2z75ilRdLiRFXCK6V39z9XC";
NSString *kPayPalSecretId = @"EL5ZgD8cf34aiM3rQX4EH0g_xpAR-HaBr7B5W9nVl73zfMLVRJDT1wiX_RWzjJRxgjcUXLU4qEhiMslG";
NSString *kPayPalProductionClientId = @"AXd22k12t_s4V9k7K-07Dgdo60mdat9uib7Zi9id3tkoFoF2XzUwqUsZ7gIRv4OQHFYjdYicSiiMt__B";
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	
	[PayPalMobile initializeWithClientIdsForEnvironments:@{
														   PayPalEnvironmentSandbox : kPayPalClientId,
														   PayPalEnvironmentProduction : kPayPalProductionClientId}];
	
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	MainViewController *mvc = [[MainViewController alloc] init];
	
	// very important to set the NavigationController correctly. Later on we can push another controller on it.
	UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:mvc];
	nvc.navigationBar.translucent = NO; // so it does not hide details views
	
	self.window.rootViewController = nvc;
	self.window.backgroundColor = [UIColor whiteColor];
	[self.window makeKeyAndVisible];
	
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

@end
