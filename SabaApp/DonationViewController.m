//
//  DonationViewController.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/27/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "DonationViewController.h"

@interface DonationViewController ()

@end

@implementation DonationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"< === Back" style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
	self.navigationItem.leftBarButtonItem = leftButton;
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
