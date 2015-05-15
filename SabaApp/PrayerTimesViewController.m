//
//  PrayerTimesViewController.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/26/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "PrayerTimesViewController.h"

@interface PrayerTimesViewController ()
@property (weak, nonatomic) IBOutlet UILabel *englishDate;
@property (weak, nonatomic) IBOutlet UILabel *hijriDate;
@property (weak, nonatomic) IBOutlet UILabel *imsaakTime;
@property (weak, nonatomic) IBOutlet UILabel *fajrTime;
@property (weak, nonatomic) IBOutlet UILabel *sunriseTime;
@property (weak, nonatomic) IBOutlet UILabel *zuhrTime;
@property (weak, nonatomic) IBOutlet UILabel *sunsetTime;
@property (weak, nonatomic) IBOutlet UILabel *maghribTime;
@property (weak, nonatomic) IBOutlet UILabel *midNightTime;
@end

@implementation PrayerTimesViewController

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
	
	self.navigationItem.title = @"Prayer Times";
}

-(void) onBack{
	NSLog(@"Back button clicked...");
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
