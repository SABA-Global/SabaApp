//
//  PrayerTimesViewController.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/26/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "PrayerTimesViewController.h"

@interface PrayerTimesViewController ()

@end

@implementation PrayerTimesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	 self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"backArrowIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) onBack{
	NSLog(@"Back button clicked...");
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
