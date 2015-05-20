//
//  PrayerTimesViewController.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/26/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "PrayerTimesViewController.h"

#import "DBManager.h"
#import "SabaClient.h"

// model
#import "PrayerTimes.h"

#import <MapKit/MapKit.h>  
#import <CoreLocation/CoreLocation.h>

// Thrd pary ibrary
#import <SVProgressHUD.h>

@interface PrayerTimesViewController () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *englishDate;
@property (weak, nonatomic) IBOutlet UILabel *hijriDate;
@property (weak, nonatomic) IBOutlet UILabel *imsaakTime;
@property (weak, nonatomic) IBOutlet UILabel *fajrTime;
@property (weak, nonatomic) IBOutlet UILabel *sunriseTime;
@property (weak, nonatomic) IBOutlet UILabel *zuhrTime;
@property (weak, nonatomic) IBOutlet UILabel *sunsetTime;
@property (weak, nonatomic) IBOutlet UILabel *maghribTime;
@property (weak, nonatomic) IBOutlet UILabel *midNightTime;

// Labels
@property (weak, nonatomic) IBOutlet UILabel *imsaakLabel;
@property (weak, nonatomic) IBOutlet UILabel *fajrLabel;
@property (weak, nonatomic) IBOutlet UILabel *sunriseLabel;
@property (weak, nonatomic) IBOutlet UILabel *zuhrLabel;
@property (weak, nonatomic) IBOutlet UILabel *sunsetLabel;
@property (weak, nonatomic) IBOutlet UILabel *maghribLabel;
@property (weak, nonatomic) IBOutlet UILabel *midNightLabel;

@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation PrayerTimesViewController

int locationFetchCounter;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	[self showPrayerTimes:NO]; // hiding the prayertimes
	[self startLocationManager];
	
	
	
	NSString* date = [NSDateFormatter localizedStringFromDate:[NSDate date]
								   dateStyle:NSDateFormatterShortStyle
								   timeStyle:NSDateFormatterFullStyle];
	
	NSLog(@"date: %@", date);
	[self setupNavigationBar];
	[self showSpinner:YES];
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
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void) getPrayerTimesForCity:(NSString*)city withLatitude:(double)latitude withLongitude:(double)longitude{
	NSDateComponents *components = [[NSCalendar currentCalendar]
									components:NSCalendarUnitDay | NSCalendarUnitMonth |
									NSCalendarUnitYear fromDate:[NSDate date]];
	
	NSInteger day = [components day];
	NSInteger month = [components month];

	// This date contain "monthNumber-day" format. E,g, "11-6" means December 6th.
	// Months are zero based in database.
	NSString *date = [NSString stringWithFormat:@"%ld-%ld", (long)month-1, (long)day];
	
	PrayerTimes* prayerTimes = [[DBManager sharedInstance] getPrayerTimesByCity:city forDate:date];
	
	if(prayerTimes == nil){ // Most likely, the city we passed in it not available in the database for prayer times.
		// go ahead and fetch the programs via network call.
		[self getPrayerTimeFromWebWithLatitude:latitude withLongitude:longitude];
	} else {
		self.fajrTime.text		= prayerTimes.fajr;
		self.imsaakTime.text	= prayerTimes.imsaak;
		self.sunriseTime.text	= prayerTimes.sunrise;
		self.zuhrTime.text		= prayerTimes.zuhr;
		self.sunsetTime.text	= prayerTimes.sunset;
		self.maghribTime.text	= prayerTimes.maghrib;
		self.midNightTime.text	= prayerTimes.midnight;
		
		[self showSpinner:NO];
		[self showPrayerTimes:YES]; // show the prayertimes
	}
}

-(void) getPrayerTimeFromWebWithLatitude:(double)latitude withLongitude:(double)longitude{
	[[SabaClient sharedInstance] getPrayTimes:latitude :longitude :^(NSDictionary *prayerTimes, NSError *error) {
		if (error) {
			NSLog(@"Error getting getPrayTimes: %@", error);
		} else {
			// from web: we don't get midnight time but get Isha time.
			NSLog(@" Prayer Times: %@", prayerTimes);
			self.fajrTime.text		= prayerTimes[@"Fajr"];
			self.imsaakTime.text	= prayerTimes[@"Imsaak"];
			self.sunriseTime.text	= prayerTimes[@"Sunrise"];
			self.zuhrTime.text		= prayerTimes[@"Dhuhr"];
			self.sunsetTime.text	= prayerTimes[@"Sunset"];
			self.maghribTime.text	= prayerTimes[@"Maghrib"];
			self.midNightTime.text	= prayerTimes[@"Isha"]; // showing Isha time in midnight label.
			self.midNightLabel.text = @"Isha";
		}
		[self showSpinner:NO];
		[self showPrayerTimes:YES]; // show the prayertimes
	}];
}

-(void) startLocationManager{
	locationFetchCounter = 0;
	if ([CLLocationManager locationServicesEnabled])
	{
		// this creates the CCLocationManager that will find your current location
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self;
		self.locationManager.distanceFilter = kCLDistanceFilterNone;
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		
		// for iOS 8.0 and above
		if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
			[self.locationManager requestWhenInUseAuthorization];
		
		[self.locationManager startMonitoringSignificantLocationChanges];
		[self.locationManager startUpdatingLocation];
	}
	
	self.geoCoder = [[CLGeocoder alloc] init];
}

#pragma mark CLLocationManager delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	// this delegate method is constantly invoked every some miliseconds.
	// we only need to receive the first response, so we skip the others.
	if (locationFetchCounter > 0)
		return;
	
	locationFetchCounter++;
	
	// after we have current coordinates, we use this method to fetch the information data of fetched coordinate
	[self.geoCoder reverseGeocodeLocation:[locations lastObject] completionHandler:^(NSArray *placemarks, NSError *error) {
		CLPlacemark *placemark = [placemarks lastObject];
		NSLog(@"Current city: %@", placemark.locality);

		CLLocation *location = (CLLocation*)[locations lastObject];
		NSLog(@"lattitude: %f", location.coordinate.latitude);
		NSLog(@"longitude: %f", location.coordinate.longitude);
		
		[self getPrayerTimesForCity:placemark.locality withLatitude:location.coordinate.latitude withLongitude:location.coordinate.longitude];
		
		// stopping locationManager from fetching again.
		[self.locationManager stopUpdatingLocation];
	}];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"Error: Failed to fetch current location : %@", error);
}

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
	if(status == kCLAuthorizationStatusAuthorizedAlways)
		NSLog(@"Got the authorization to access the location: kCLAuthorizationStatusAuthorizedAlways");
	else
		NSLog(@"Error: didn't get the authorization to access the location: %d", status);
}

#pragma mark spinner
-(void) showSpinner:(bool)show{
	if(show == YES){
		[SVProgressHUD setRingThickness:1.0];
		CAShapeLayer* layer = [[SVProgressHUD sharedView]backgroundRingLayer];
		layer.opacity = 0;
		layer.allowsGroupOpacity = YES;
		[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
	}
	else
		[SVProgressHUD dismiss];
}

-(void) showPrayerTimes:(BOOL)show{
	
	// All Labels
	self.fajrLabel.hidden		= !show;
	self.imsaakLabel.hidden		= !show;
	self.sunriseLabel.hidden	= !show;
	self.zuhrLabel.hidden		= !show;
	self.sunsetLabel.hidden		= !show;
	self.maghribLabel.hidden	= !show;
	self.midNightLabel.hidden	= !show;
	
	// Values
	self.fajrTime.hidden		= !show;
	self.imsaakTime.hidden		= !show;
	self.sunriseTime.hidden		= !show;
	self.zuhrTime.hidden		= !show;
	self.sunsetTime.hidden		= !show;
	self.maghribTime.hidden		= !show;
	self.midNightTime.hidden	= !show;
}

@end
