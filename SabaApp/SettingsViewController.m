//
//  SettingsViewController.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/27/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	 self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"backArrowIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
	
	
//	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"< === Back" style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
//	self.navigationItem.leftBarButtonItem = leftButton;
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
