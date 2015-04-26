//
//  SabaClient.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/25/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "SabaClient.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"

#import "Program.h"

static NSString *SABA_BASE_URL = @"http://www.saba-igc.org/mobileapp/datafeedproxy.php?sheetName=weekly&sheetId=";

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

-(void) sendNetworkRequest:(id)sender withUrl:(NSURL*) url completion:(void (^)(NSString* programName, NSArray *programs, NSError *error))completion {
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	operation.responseSerializer = [AFJSONResponseSerializer serializer];
	operation.responseSerializer.acceptableContentTypes = [operation.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
	
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		
		if(responseObject == nil){
			return;
		}
		NSLog(@"%@", responseObject);
		NSArray* programs = [Program fromArray:responseObject];
		NSLog(@"%@", programs);
		completion(@"name", programs, nil);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		completion(@"name", nil, error);
	}];
	
	// Start Operation
	[operation start];
}
@end
