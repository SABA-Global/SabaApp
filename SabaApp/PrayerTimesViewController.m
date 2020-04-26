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
#import "AppDelegate.h"

// model
#import "PrayerTimes.h"

#import <MapKit/MapKit.h>  
#import <CoreLocation/CoreLocation.h>

#import <JavaScriptCore/JavaScriptCore.h>

#import "PrayTime.h"

// Thrd pary ibrary
@import Firebase;
//#import <Google/Analytics.h>

extern NSString *const kPrayerTimesView;
extern NSString *const kEventCategoryPrayerTimes;

// Event Labels
extern NSString *const kRefreshEventLabel;

//Event Actions
extern NSString *const kRefreshEventActionSwiped;
extern NSString *const kRefreshEventActionClicked;

// Errors
extern NSString *const kErrorNoNetwork;
extern NSString *const kErrorLocationUnknown;
extern NSString *const kPrayerTimesGetError;
extern NSString *const kErrorHijriDate;
extern NSString *const kErrorLocationRetrievalTimeout;
extern NSString *const kLocationTimer;

@interface PrayerTimesViewController () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *cityName;
@property (weak, nonatomic) IBOutlet UILabel *englishDate;
@property (weak, nonatomic) IBOutlet UILabel *hijriDate;

// time values
@property (weak, nonatomic) IBOutlet UILabel *imsaakTime;
@property (weak, nonatomic) IBOutlet UILabel *fajrTime;
@property (weak, nonatomic) IBOutlet UILabel *sunriseTime;
@property (weak, nonatomic) IBOutlet UILabel *zuhrTime;
@property (weak, nonatomic) IBOutlet UILabel *sunsetTime;
@property (weak, nonatomic) IBOutlet UILabel *maghribTime;
@property (weak, nonatomic) IBOutlet UILabel *midNightTime;

// prayerTime Labels
@property (weak, nonatomic) IBOutlet UILabel *imsaakLabel;
@property (weak, nonatomic) IBOutlet UILabel *fajrLabel;
@property (weak, nonatomic) IBOutlet UILabel *sunriseLabel;
@property (weak, nonatomic) IBOutlet UILabel *zuhrLabel;
@property (weak, nonatomic) IBOutlet UILabel *sunsetLabel;
@property (weak, nonatomic) IBOutlet UILabel *maghribLabel;
@property (weak, nonatomic) IBOutlet UILabel *midNightLabel;

@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation PrayerTimesViewController

int locationFetchCounter;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[SabaClient sharedInstance] showSpinner:YES];
	[self showPrayerTimes:NO]; // hiding the prayertimes
	[self startLocationManager];
	
	[self setupNavigationBar];
	[self showDates];
}

// This function is not used at this time. Will be used when we calculate the prayer times
// locally. Lets not remove it.
- (NSString *)loadJsFromFile
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"PrayTimes" ofType:@"js"];
    NSString *jsScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    JSContext *context = [[JSContext alloc] init];
    [context evaluateScript: jsScript];
    JSValue *function = context[@"getDailyPrayTimes"];
    
    //lon:-121.893028
    //NSString* lat = @"37.335480";
    JSValue* result = [function callWithArguments:nil];
    NSDictionary* dic = [result toDictionary]; // this disctionary returns the paryers times.
    
    return jsScript;
}

- (void)runJavaScript
{
    JSContext *context = [[JSContext alloc] init];
    //[context evaluateScript: self.javascriptText.text];
    JSValue *function = context[@"PrayTime"];
    JSValue* result = [function callWithArguments:nil];
}


- (void)viewWillAppear:(BOOL)animated{
	//Provide a name for the screen and execute tracking.
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker set:kGAIScreenName value:kPrayerTimesView];
//    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self clearTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
	if (![parent isEqual:self.parentViewController]) {
		[UIView  beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:NO];
		[UIView commitAnimations];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDelay:0.3];
		[UIView commitAnimations];
	}
}

-(void) setupNavigationBar{
	[self.navigationController setNavigationBarHidden:NO];
	[[SabaClient sharedInstance] setupNavigationBarFor:self];

	// Use standard refresh button.
	UIBarButtonItem *refreshBarButtonItem = [[UIBarButtonItem alloc]
											 initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
											 target:self
											 action:@selector(onRefresh)];
	self.navigationItem.rightBarButtonItem = refreshBarButtonItem;
	self.navigationItem.title = @"Prayer Times";
}

-(void) onRefresh{
	[self trackEventAction:kRefreshEventActionClicked withLabel:kRefreshEventLabel];
	
	[[SabaClient sharedInstance] showSpinner:YES];
	self.cityName.text = @"Loading...";
	[self showPrayerTimes:NO];
	[self showDates];
	[self startLocationManager];
}

-(void) getPrayerTimesWithPlacemark:(CLPlacemark*)placemark
						withLatitude:(double)latitude
						withLongitude:(double)longitude{

    // After having the detailed discussion with Saba board, speciay Muzaafar bhai. We should display San Jose times
    // for following Cities.
    
    [self setCityNameWithPlacemark:placemark];
    if([placemark.locality  isEqual: @"San Jose"]    || [placemark.locality  isEqual: @"Milpitas"]      ||
       [placemark.locality  isEqual: @"Sunnyvale"]   || [placemark.locality  isEqual: @"Gilroy"]        ||
       [placemark.locality  isEqual: @"Morgan Hill"] || [placemark.locality  isEqual: @"Mountain View"] ||
       [placemark.locality  isEqual: @"Fremont"]     || [placemark.locality  isEqual: @"Santa Clara"]   ||
       [placemark.locality  isEqual: @"Campbell"]    || [placemark.locality  isEqual: @"Los Gatos"]     ||
       [placemark.locality  isEqual: @"Cupertino"]   || [placemark.locality  isEqual: @"Saratoga"]      ||
       [placemark.locality  isEqual: @"Alum Rock"]   || [placemark.locality  isEqual: @"Evergreen"]     ||
       [placemark.locality  isEqual: @"Newark"]){
        // call Salat Service on Saba Service for San Jose times.
        
        // San Jose, CA -  lat and lon
        double sanJoseLatitude  = 37.335480;
        double sanJoseLongitude = -121.893028;
        
        [self getPrayerTimeFromSabaWithLatitude:sanJoseLatitude withLongitude:sanJoseLongitude];
    } else {
        // Getting prayerTimes from Saba for specific lat and lon.
        [self getPrayerTimeFromSabaWithLatitude:latitude withLongitude:longitude];
    }
 
    
    // We have stored prayer times for 10 cities of bay area in SQLite Database. These times sometimes are invalid for Daylight savings. Following code is not being used.
    //Just keeing it here.
//    NSDateComponents *components = [[NSCalendar currentCalendar]
//                                    components:NSCalendarUnitDay | NSCalendarUnitMonth |
//                                    NSCalendarUnitYear| NSCalendarUnitHour| NSCalendarUnitMinute
//                                    fromDate:[NSDate date]];
//    NSInteger day = [components day];
//    NSInteger month = [components month];
//    
//    // This date contain "monthNumber-day" format. E,g, "11-6" means December 6th.
//    // Months are zero based in database.
//    NSString *currDate = [NSString stringWithFormat:@"%ld-%ld", (long)month-1, (long)day];
//	PrayerTimes* prayerTimes = [[DBManager sharedInstance] getPrayerTimesByCity:placemark.locality forDate:currDate];
// 	if(prayerTimes == nil){ // Most likely, the city we passed in it not available in the database for prayer times.
//		// go ahead and fetch the programs via network call.
//		[self getPrayerTimeFromWebWithLatitude:latitude withLongitude:longitude];
//	} else {
//		self.fajrTime.text		= prayerTimes.fajr;
//		self.imsaakTime.text	= prayerTimes.imsaak;
//		self.sunriseTime.text	= prayerTimes.sunrise;
//		self.zuhrTime.text		= prayerTimes.zuhr;
//		self.sunsetTime.text	= prayerTimes.sunset;
//		self.maghribTime.text	= prayerTimes.maghrib;
//		self.midNightTime.text	= prayerTimes.midnight;
//		
//		[[SabaClient sharedInstance] showSpinner:NO];
//		[self showPrayerTimes:YES]; // show the prayertimes
//	}
}

-(void) getPrayerTimeFromSabaWithLatitude:(double)latitude withLongitude:(double)longitude{
	[[SabaClient sharedInstance] getPrayTimesWithLatitude:latitude andLongitude:longitude :^(NSDictionary *prayerTimes, NSError *error) {
		if (error) {
			NSLog(@"Error getting getPrayTimes: %@", error);
            [self trackEventAction:kPrayerTimesGetError withLabel:error.localizedDescription];
		} else {
			[self updatePrayerTimesOnUI:prayerTimes];
            [self showPrayerTimes:YES]; // show the prayertimes
		}
		[[SabaClient sharedInstance] showSpinner:NO];
	}];
}

-(void) updatePrayerTimesOnUI:(NSDictionary*)prayerTimes{
    NSLog(@"PrayTime: %@", prayerTimes);
    // from Saba: We get ISHA time as mid night time.
    self.fajrTime.text        = prayerTimes[@"fajar"];
    self.imsaakTime.text    = prayerTimes[@"imsak"];
    self.sunriseTime.text    = prayerTimes[@"sunrise"];
    self.zuhrTime.text        = prayerTimes[@"zuhur"];
    self.sunsetTime.text    = prayerTimes[@"sunset"];
    self.maghribTime.text    = prayerTimes[@"maghrib"];
    self.midNightTime.text  = prayerTimes[@"midnight"]; // showing Isha time in midnight label. Saba also getting time from web.
    [self showPrayerTimes:YES]; // show the prayertimes
}

// This function sets the cityname, state in the label.
-(void) setCityNameWithPlacemark:(CLPlacemark *)placemark{
    //    self.cityName.text = [NSString stringWithFormat:@"%@, %@", placemark.locality!=nil?placemark.locality:placemark.administrativeArea,
    //								placemark.administrativeArea] ; // setting city name, State in title.
    
    NSMutableString *cityName = [[NSMutableString alloc] init];
    BOOL bAddComma = NO;
    
    self.cityName.text = @"";
    if(placemark.locality != nil){
        [cityName appendString:placemark.locality];
        bAddComma = YES;
    }
    
    if(placemark.administrativeArea != nil){
        if(bAddComma)
            [cityName appendString:@", "];
        
        [cityName appendString:placemark.administrativeArea];
    }
    
    self.cityName.text  = cityName;
}

-(void) startLocationManager{
	locationFetchCounter = 0;
	
	if ([CLLocationManager locationServicesEnabled]){
		// this creates the CCLocationManager that will find your current location
		self.locationManager = [[CLLocationManager alloc] init];
		self.geoCoder = [[CLGeocoder alloc] init];
		
		self.locationManager.delegate = self;
		self.locationManager.distanceFilter = kCLDistanceFilterNone;
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;

		// for iOS 8.0 and above
		if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
			[self.locationManager requestWhenInUseAuthorization];
		
		[self.locationManager startMonitoringSignificantLocationChanges];
		[self.locationManager startUpdatingLocation];
		
		[self clearTimer];
		self.timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
	}
}

-(void) onTimer{
	[[SabaClient sharedInstance] showSpinner:NO];
	self.cityName.text = @" ";
	[self showAlert:@"Turn Off Airplane Mode or Use Wi-Fi to Access Data" withMessage:@""];
	
	[self clearTimer];
    [self trackEventAction:kErrorLocationRetrievalTimeout withLabel:kLocationTimer];
}

-(void) clearTimer{
	if(self.timer){
		[self.timer invalidate];
		self.timer = nil;
	}
}

-(void)showAlert:(NSString*)title withMessage:(NSString*)message{
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:title
						  message:message
						  delegate:self  // set self if you want the Okay button callback
						  cancelButtonTitle:@"Cancel"
						  otherButtonTitles:@"Settings", nil];
	
	[alert show];
}

// OK button callback
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:
	(NSInteger)buttonIndex {
	
	if (buttonIndex != 0) {
		[self launchSettings];
	}
}

- (void)launchSettings
{
	if ([UIApplicationOpenSettingsURLString length] > 0) {
		NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
		[[UIApplication sharedApplication] openURL:url];
	}
}

#pragma mark CLLocationManager delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	
	// this delegate method is constantly invoked every some miliseconds.
	// we only need to receive the first response, so we skip the others.
	if (locationFetchCounter > 0){
	// stopping locationManager from fetching again.
		[self.locationManager stopUpdatingLocation];
		return;
	}
	
	locationFetchCounter++;
	CLLocation *lastlocation = (CLLocation*)[locations lastObject];

	// after we have current coordinates, we use this method to fetch the information data of fetched coordinate
	[self.geoCoder reverseGeocodeLocation:lastlocation completionHandler:^(NSArray *placemarks, NSError *error) {
		CLPlacemark *placemark = [placemarks lastObject];
		
		if(placemark != nil){
			[self clearTimer];
			[self getPrayerTimesWithPlacemark:placemark withLatitude:lastlocation.coordinate.latitude withLongitude:lastlocation.coordinate.longitude];
		}
		
		// stopping locationManager from fetching again.
		[self.locationManager stopUpdatingLocation];
	}];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	
	[[SabaClient sharedInstance] showSpinner:NO];
	self.cityName.text = @" ";

	switch(error.code){
		case kCLErrorLocationUnknown:
			[self showAlert:@"Turn Off Airplane Mode or Use Wi-Fi to Access Data" withMessage:@""];
			
			[self clearTimer]; // cancel the timer here.... we already showed an Alert here...
			// stopping locationManager from fetching again.
			[self.locationManager stopUpdatingLocation];
            [self trackEventAction:kErrorLocationUnknown withLabel:kErrorLocationUnknown];
            
			break;
			
		case kCLErrorNetwork:
			[self showAlert:@"Make sure you are conected to internet." withMessage:@""];
			[self clearTimer]; // cancel the timer here.... we already showed an Alert here...
			[self trackEventAction:kErrorNoNetwork withLabel:kErrorNoNetwork];
			break;
			
		default:
			NSLog(@"Error: didFailWithError: %@", error);
	}
}

- (void)locationManager:(CLLocationManager *)manager
						didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
	
	switch(status){
		case kCLAuthorizationStatusDenied:
			NSLog(@"Error: didn't get the authorization to access the location: %d", status);
			[self showAlert:@"Allow \"Saba\" to access your location to get Prayer Times" withMessage:@""];
			[self clearTimer]; // cancel the timer here.... we already showed an Alert here...
			break;
			
		case kCLAuthorizationStatusNotDetermined:
		case kCLAuthorizationStatusRestricted:
			break;
			
		case kCLAuthorizationStatusAuthorizedAlways:
		case kCLAuthorizationStatusAuthorizedWhenInUse:
			NSLog(@"Got the authorization to access the location: %d", status);
			break;
	}
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

-(void) showDates{
	
	NSString* date = [NSDateFormatter localizedStringFromDate:[NSDate date]
													dateStyle:NSDateFormatterFullStyle
													timeStyle:NSDateFormatterNoStyle];
	self.englishDate.text = date;
	NSString *hijriDate = [[SabaClient sharedInstance] getCachedHijriDate];
	if(hijriDate==nil || hijriDate.length==0){
		[[SabaClient sharedInstance] getHijriDateFromWeb:^(NSDictionary *jsonResponse, NSError *error) {
			if(error){
				NSLog(@"Error getting HijriDate: %@", error.localizedDescription);
                [self trackEventAction:kErrorHijriDate withLabel:error.localizedDescription];
			} else {
				[[SabaClient sharedInstance] storeHijriDate:jsonResponse[@"hijridate"]];
				self.hijriDate.text = jsonResponse[@"hijridate"];
			}
		}];
	} else {
		self.hijriDate.text = hijriDate;
	}
}

-(void) comingPrayerTime{
//	while(true){
//		NSString time = self.fajrTime.text ran
//		NSString *timeWithSeconds = [NSString stringWithFormat:@"%@:00", time];
//		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//		[dateFormatter setDateFormat:@"HH:mm:ss"];
//		
//		NSDate *date = [dateFormatter dateFromString:timeWithSeconds];
//		
//		
//		if ([date1 compare:date2] == NSOrderedDescending) {
//			NSLog(@"date1 is later than date2");
//		} else if ([date1 compare:date2] == NSOrderedAscending) {
//			NSLog(@"date1 is earlier than date2");
//		} else {
//			NSLog(@"dates are the same");
//		}
//	}
}
// this function expects time in "HH:MM" format and appends ":00" to it to make it
// like "HH:MM:SS" other wise NSDateFormatter doesn't like it. Please make sure
// this function takes "HH:MM". No validation is added at this point.

-(NSString*) getAMPMTime:(NSString*) time{
	NSString *timeWithSeconds = [NSString stringWithFormat:@"%@:00", time];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setDateFormat:@"HH:mm:ss"];
	
	NSDate *date = [dateFormatter dateFromString:timeWithSeconds];
	NSDateFormatter *formatterAMPM = [[NSDateFormatter alloc] init];
	[formatterAMPM setDateFormat:@"hh:mm a"];
	
	NSString *returnedDate = [formatterAMPM stringFromDate:date];
	if(returnedDate == nil) // for some cities, Imsaac value is "-----" and we ended up having a nil here.
		return @" "; // returning @" " - a space so all the lables will get aligned.
	
	return returnedDate;
}

#pragma mark - Analytics

// we might add swipe to refresh later on.
- (void)trackEventAction:(NSString*) action withLabel:(NSString*) label{
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    
//    // Create events to track the selected image and selected name.
//    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kEventCategoryPrayerTimes
//                                                          action:action
//                                                           label:label
//                                                           value:nil] build]];
}

@end
