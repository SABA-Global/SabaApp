//
//  ContactViewController.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/26/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "ContactViewController.h"
#import "AppDelegate.h"

#import <MapKit/MapKit.h>

@interface ContactViewController ()
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end

@implementation ContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	[self setupNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
	
-(void) setupNavigationBar{
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"backArrowIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
	
	// Settings bars text color to white.
	[self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
	//set bar color
	self.navigationController.navigationBar.barTintColor = RGB(106, 172, 43);
	
	self.navigationItem.title = @"Contact and Directions";
}

-(void) onBack{
	NSLog(@"Back button clicked...");
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
