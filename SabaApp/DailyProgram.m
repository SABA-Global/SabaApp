//
//  DailyProgram.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/28/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "DailyProgram.h"

// Incoming JSON data
//{
//    "day": "Tuesday",
//    "englishdate": "'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''December 9",
//    "hijridate": "Safar 16",
//    "time": "",
//    "program": ""
//},
//{
//    "day": "",
//    "englishdate": "",
//    "hijridate": "",
//    "time": " ",
//    "program": "Maghrib Prayer"
//}



@implementation DailyProgram
//-(id)initWithArray:(NSArray * )array{
//	self = [super init];
//	if(self){
//		
//	}
//	
//	return self;
//}

-(id)initWithDictionary:(NSDictionary * )dictionary{
	self = [super init];
	if(self){
		// lastUpdated is not part of the dictionary, we will use this to keep
		// track of cache.
		//[dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"];
		self.lastUpated = [NSDateFormatter localizedStringFromDate:[NSDate date]
														 dateStyle:NSDateFormatterShortStyle
														 timeStyle:NSDateFormatterFullStyle];
		self.day		 = dictionary[@"day"];
		self.time		 = dictionary[@"time"];
		self.program	 = dictionary[@"program"];
		self.hijriDate	 = dictionary[@"hijridate"];
		self.englishDate = dictionary[@"englishdate"];
		//[self display];
	}
	
	return self;
}

// debug function...
-(void) display{
	NSLog(@"Day: %@", self.day);
	NSLog(@"Time: %@", self.time);
	NSLog(@"Program: %@", self.program);
	NSLog(@"HijriDate: %@", self.hijriDate);
	NSLog(@"EnglishDate: %@", self.englishDate);
}

+(DailyProgram*) fromDictionary:(NSDictionary * )dictionary{
	return [[DailyProgram alloc] initWithDictionary:dictionary];
}

+(NSArray*) fromArray:(NSArray * )array{
	NSMutableArray *dailyPrograms = [[NSMutableArray alloc]init];
	for (NSDictionary* value in array) {
		DailyProgram *dailyProgram = [[DailyProgram alloc] initWithDictionary:value];
		[dailyPrograms addObject:dailyProgram];
		//NSLog(@"title: %@", program.title);
	}
	
	return dailyPrograms;
}

@end