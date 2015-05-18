//
//  PrayerTimesViewController.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/26/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "PrayerTimesViewController.h"

#import "DBManager.h"

// model
#import "PrayerTimes.h"

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
	[self getPrayerTimes];
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

-(void) getPrayerTimes{
	NSDateComponents *components = [[NSCalendar currentCalendar]
									components:NSCalendarUnitDay | NSCalendarUnitMonth |
									NSCalendarUnitYear fromDate:[NSDate date]];
	
	NSInteger day = [components day];
	NSInteger month = [components month];

	// This date contain "monthNumber-day" format. E,g, "11-6" means december 6th.
	// Months are zero based in database.
	NSString *date = [NSString stringWithFormat:@"%ld-%ld", (long)month-1, (long)day];
	
	PrayerTimes* prayerTimes = [[DBManager sharedInstance] getPrayerTimesByCity:@"San Jose" forDate:date];
	
	if( prayerTimes != nil){
		self.fajrTime.text = prayerTimes.fajr;
		self.imsaakTime.text = prayerTimes.imsaak;
		self.sunriseTime.text = prayerTimes.sunrise;
		self.zuhrTime.text = prayerTimes.zuhr;
		self.sunsetTime.text = prayerTimes.sunset;
		self.maghribTime.text = prayerTimes.maghrib;
		self.midNightTime.text = prayerTimes.midnight;
	}
}

@end
