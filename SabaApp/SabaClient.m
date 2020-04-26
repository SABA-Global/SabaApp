//
//  SabaClient.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/25/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "SabaClient.h"

#import "Program.h"
#import "AppDelegate.h"

// Third party libraries.
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"

static NSString *SABA_BASE_URL              = @"http://www.saba-igc.org/mobileapp/datafeedproxy.php?sheetName=weekly&sheetId=";
//static NSString *PRAY_TIME_INFO_BASE_URL    = @"http://praytime.info/getprayertimes.php?school=0";
static NSString *HIJRI_DATE_URL             = @"http://www.saba-igc.org/prayerTimes/salatDataService/salatDataService.php";
static NSString *LIVE_STREAM_FEED_URL       = @"http://www.saba-igc.org/liveStream/liveStreamLinkApp.php";
static NSString *PRAY_TIME_FROM_SABA_URL    = @"http://www.saba-igc.org/prayerTimes/salatDataService/salatDataService.php";

@implementation SabaClient

+(SabaClient *) sharedInstance{
	static SabaClient *instance = nil;
	
	// grand centeral dispatch which makes sure it will execute once.
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if(instance == nil){
			instance = [[SabaClient alloc] init];
		}
	});
	
	return instance;
}

-(void) getUpcomingPrograms:(void (^)(NSString* programName, NSArray *programs, NSError *error))completion {
	// check the database, if lastUpdate was recent?
	
	// sheet # 2 is Upcoming programs
	NSURL *url = [NSURL URLWithString:[SABA_BASE_URL stringByAppendingString:@"2"]];
	[self sendNetworkRequest:@"Upcoming Programs" withUrl:url completion:completion];
}

-(void) getWeeklyPrograms:(void (^)(NSString* programName, NSArray *programs, NSError *error))completion {
	// sheet # 4 is Weekly Announcements
	NSURL *url = [NSURL URLWithString:[SABA_BASE_URL stringByAppendingString:@"4"]];
	[self sendNetworkRequest:@"Weekly Announcements" withUrl:url completion:completion];
}

-(void) getCommunityAnnouncements:(void (^)(NSString* programName, NSArray *programs, NSError *error))completion {
	// sheet # 5 is Community Announcements
	NSURL *url = [NSURL URLWithString:[SABA_BASE_URL stringByAppendingString:@"5"]];
	[self sendNetworkRequest:@"Community Announcements" withUrl:url completion:completion];
}

-(void) getGeneralAnnouncements:(void (^)(NSString* programName, NSArray *programs, NSError *error))completion {
	
	// sheet # 6 is General Announcements
	NSURL *url = [NSURL URLWithString:[SABA_BASE_URL stringByAppendingString:@"6"]];
	[self sendNetworkRequest:@"General Announcements" withUrl:url completion:completion];
}

// LiveStreamFeeds - sends a URL and gets back a JSON which is a dictionary. (It might get an array - will update this accordingly.)
-(void) getLiveStreamFeeds:(void (^)(NSDictionary *jsonResponse, NSError *error))completion{
    NSURL *url = [NSURL URLWithString:[LIVE_STREAM_FEED_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [self sendNetworkRequest:url completion:completion];
}

-(void) getPrayTimesWithLatitude:(double)latitude andLongitude:(double)longitude : (void (^)(NSDictionary* prayerTimes, NSError *error))completion {
	
	NSDateComponents *components = [[NSCalendar currentCalendar]
									components:NSCalendarUnitDay | NSCalendarUnitMonth |
									NSCalendarUnitYear fromDate:[NSDate date]];
	
	NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
	double hoursFromGMT = [timeZone secondsFromGMT]/(60*60); // it will give me hours...
	NSLog(@"minutesFromGMT: %f", hoursFromGMT);

	NSString  *url = [NSString stringWithFormat:@"%@&gmt=%f&lat=%f&lon=%f&m=%ld&d=%ld&y=%ld", PRAY_TIME_FROM_SABA_URL, hoursFromGMT, latitude, longitude, (long)[components month], (long)[components day], (long)[components year]];
	
	[self sendNetworkRequest1:[NSURL URLWithString:url] completion:completion];
}

-(void) getPrayerTimeFromSaba:(void (^)(NSDictionary *jsonResponse, NSError *error))completion{
    NSURL *url = [NSURL URLWithString:[PRAY_TIME_FROM_SABA_URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [self sendNetworkRequest:url completion:completion];
}

-(void)getHijriDateFromWeb:(void (^)(NSDictionary *jsonResponse, NSError *error))completion{
	[self sendNetworkRequest1:[NSURL URLWithString:HIJRI_DATE_URL] completion:completion];
}

-(void) sendNetworkRequest1:(NSURL*) url completion:(void (^)(NSDictionary *jsonResponse, NSError *error))completion{
	
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	operation.responseSerializer = [AFJSONResponseSerializer serializer];
	operation.responseSerializer.acceptableContentTypes = [operation.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
	
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		
		if(responseObject == nil){
			return;
		}
		
		completion(responseObject, nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		completion(nil, error);
	}];
	
	// Start Operation
	[operation start];
}

-(void) sendNetworkRequest:(NSURL*) url completion:(void (^)(NSDictionary *jsonResponse, NSError *error))completion {
	
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	operation.responseSerializer = [AFJSONResponseSerializer serializer];
	operation.responseSerializer.acceptableContentTypes = [operation.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
	
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		
		if(responseObject == nil){
			return;
		}

		completion(responseObject, nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		completion(nil, error);
	}];
	
	// Start Operation
	[operation start];
}

-(void) sendNetworkRequest:(id)sender withUrl:(NSURL*) url completion:(void (^)(NSString* programName, NSArray *programs, NSError *error))completion {
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	operation.responseSerializer = [AFJSONResponseSerializer serializer];
	operation.responseSerializer.acceptableContentTypes = [operation.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
	
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		
		if(responseObject == nil){
			return;
		}
		
		NSLog(@"%@", sender);
		completion(sender, responseObject, nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		completion(@"name", nil, error);
	}];
	
	// Start Operation
	[operation start];
}


/// helper fuction - being used at many places. may find a good home for his function in future.
-(NSAttributedString*) getAttributedString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size withOpacity:(double)opacity{
	string = [string stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;color: rgba(255, 255, 255, %.2f);}</style>", name, size, opacity]];
	
	//NSLog(@"string: %@", string);
	return [[NSAttributedString alloc]
			initWithData:[string dataUsingEncoding:NSUnicodeStringEncoding]
			options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
			documentAttributes:nil error:nil];
	
}
// Progress spinner helper function
-(void) showSpinner:(bool)show{
	if(show == YES){
		[SVProgressHUD setRingThickness:2.0];
		[SVProgressHUD setForegroundColor:[UIColor whiteColor]];
		[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
		[SVProgressHUD setBackgroundColor:[UIColor clearColor]];
		//[SVProgressHUD setForegroundColor:[UIColor whiteColor]];
	}
	else
		[SVProgressHUD dismiss];
}

// helper function for setting up the NavigationBar
-(void) setupNavigationBarFor:(UIViewController*) viewController{	
	// Settings bars text color to white.
	[viewController.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
	
	// following two lines makes the navigationBar transparent.
	[viewController.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
	viewController.navigationController.navigationBar.shadowImage = [UIImage new];
}

#pragma mark NSUserDefaults helper functions.
// NSUserDefaults helper functions
-(void) storePreferencesKey:(NSString*) key withValue:(NSString*) value {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:value forKey:key];
	[defaults synchronize];
}

-(NSString*) getCachedPreferencesWithKey:(NSString*) key{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	return [defaults stringForKey:key];
}

-(NSString*) getCachedHijriDate{
	NSString* englishDate = [NSDateFormatter localizedStringFromDate:[NSDate date]
														   dateStyle:NSDateFormatterFullStyle
														   timeStyle:NSDateFormatterNoStyle];
	
	if( (englishDate != nil) && [englishDate isEqualToString:[self getCachedEnglishDate]]){
		return [self getCachedPreferencesWithKey:@"hijriDate"];
	}
	
	return @"";
}

-(void) storeHijriDate:(NSString*) hijriDate{
	[self storeEnglishDate];
	[self storePreferencesKey:@"hijriDate"  withValue:hijriDate];
}

-(NSString*) getCachedEnglishDate{
	return [self getCachedPreferencesWithKey:@"englishDate"];
}

-(void) storeEnglishDate{
	NSString* englishDate = [NSDateFormatter localizedStringFromDate:[NSDate date]
														   dateStyle:NSDateFormatterFullStyle
														   timeStyle:NSDateFormatterNoStyle];
	
	[self storePreferencesKey:@"englishDate" withValue:englishDate];
}

@end
