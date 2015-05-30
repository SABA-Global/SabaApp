//
//  SabaClient.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/25/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "SabaClient.h"

#import "Program.h"
#import "appDelegate.h"

// Third party libraries.
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"

static NSString *SABA_BASE_URL = @"http://www.saba-igc.org/mobileapp/datafeedproxy.php?sheetName=weekly&sheetId=";
static NSString *PRAY_TIME_INFO_BASE_URL = @"http://praytime.info/getprayertimes.php?school=0&gmt=-420";

//	private static String PRAY_TIME_INFO_URL = "http://praytime.info/getprayertimes.php?lat=34.024899&lon=-117.89730099999997&gmt=-480&m=11&d=31&y=2014&school=0";
//	private static String PRAY_TIME_INFO_BASE_URL = "http://praytime.info/getprayertimes.php?school=0&gmt=-480";
//

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

-(void) getPrayTimesWithLatitude:(double)latitude andLongitude:(double)longitude : (void (^)(NSDictionary* prayerTimes, NSError *error))completion {
	
	NSDateComponents *components = [[NSCalendar currentCalendar]
									components:NSCalendarUnitDay | NSCalendarUnitMonth |
									NSCalendarUnitYear fromDate:[NSDate date]];
	
	NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
	double minutesFromGMT = [timeZone secondsFromGMT]/60; // it will give me minutes...
	NSLog(@"minutesFromGMT: %f", minutesFromGMT);

	
	NSString  *url = [NSString stringWithFormat:@"%@&gmt=%f&lat=%f&lon=%f&m=%ld&d=%ld&y=%ld", PRAY_TIME_INFO_BASE_URL, minutesFromGMT, latitude, longitude, (long)[components month], (long)[components day], (long)[components year]];
	
	[self sendNetworkRequest1:[NSURL URLWithString:url] completion:completion];
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
-(NSAttributedString*) getAttributedString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size{
	string = [string stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;color:white;}</style>", name, size]];
	
	return [[NSAttributedString alloc]
			initWithData:[string dataUsingEncoding:NSUnicodeStringEncoding]
			options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
			documentAttributes:nil error:nil];
	
}
// Progress spinner helper function
-(void) showSpinner:(bool)show{
	if(show == YES){
		[SVProgressHUD setRingThickness:2.0];
		CAShapeLayer* layer = [[SVProgressHUD sharedView]backgroundRingLayer];
		layer.opacity = 0;
		layer.allowsGroupOpacity = YES;
		[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
		[SVProgressHUD setBackgroundColor:[UIColor clearColor]];
		[SVProgressHUD setForegroundColor:RGB(106, 172, 43)];
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
@end
