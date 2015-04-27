//
//  WeeklyScheduleViewController.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/26/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "WeeklyScheduleViewController.h"

@interface WeeklyScheduleViewController ()


@end

@implementation WeeklyScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
