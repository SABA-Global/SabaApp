//
//  SplashScreenViewController.m
//  SabaApp
//
//  Created by Syed Naqvi on 7/9/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "SplashScreenViewController.h"

#import "Program.h"
#import "DBManager.h"
#import "SabaClient.h"
#import "WeeklyPrograms.h"
#import "MainViewController.h"

@interface SplashScreenViewController ()

@end

@implementation SplashScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self getWeeklyPrograms];
	[self.navigationController setNavigationBarHidden:YES]; // shouldn't show NavigationBar on this controller.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) getWeeklyPrograms{
	[[SabaClient sharedInstance] getWeeklyPrograms:^(NSString* programName, NSArray *programs, NSError *error) {
		if (error) {
			NSLog(@"Error getting WeeklyPrograms: %@", error);
		} else {
			
			[[DBManager sharedInstance ] deleteSabaPrograms:@"Weekly Programs"];
			[[DBManager sharedInstance ] deleteDailyPrograms];

			NSArray* latestWeeklyPrograms = [Program fromWeeklyPrograms:[WeeklyPrograms fromArray: programs]];
			NSArray* latestDailyPrograms = [WeeklyPrograms fromArray:programs];
			
			[[DBManager sharedInstance] saveSabaPrograms:latestWeeklyPrograms :@"Weekly Programs"];
			[[DBManager sharedInstance] saveWeeklyPrograms:latestDailyPrograms];
		}
		
		// removing the splash screen here...
		[self.navigationController popViewControllerAnimated:NO];
	}];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
	if (![parent isEqual:self.parentViewController]) {
		[UIView  beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[UIView setAnimationDuration:0.0];
		[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.navigationController.view cache:NO];
		[UIView commitAnimations];
	}
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
