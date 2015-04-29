//
//  WeeklyPrograms.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/28/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "WeeklyPrograms.h"

#import "DailyProgram.h"

@implementation WeeklyPrograms

+(NSArray*) fromArray:(NSArray*)array{
	NSMutableArray *weeklyPrograms = [[NSMutableArray alloc]init];
	NSMutableArray *dailyPrograms = nil;
	
	NSString *lastDay = [[NSString alloc] init];
	NSString *lastEnglishDate = [[NSString alloc] init];;
	NSString *lastHijriDate = [[NSString alloc] init];;
	
	
	for(NSDictionary* data in array){
		DailyProgram *dailyProgram = [DailyProgram fromDictionary:data];

		// we don't want to show empty rows.
		// currently, time field contains the <br> which mean empty line. I am ignoring it for now.
		if([[dailyProgram time] compare:@"<br>"] == YES){
			continue;
		}
		
		if([dailyProgram.day compare:@""] == YES){
			dailyPrograms = [[NSMutableArray alloc]init];
			[weeklyPrograms addObject:dailyPrograms];
			lastDay = dailyProgram.day;
		} else {
			dailyProgram.day = lastDay;
		}
		
		if([dailyProgram.englishDate length] == 0){
			lastEnglishDate = dailyProgram.englishDate;
		} else {
			dailyProgram.englishDate = lastEnglishDate;
		}
			
		if([dailyProgram.hijriDate length] == 0){
			lastHijriDate = dailyProgram.hijriDate;
		} else {
			dailyProgram.hijriDate = lastHijriDate;
		}
		
		[dailyPrograms addObject:dailyProgram];
	}
	
	return weeklyPrograms;
}

@end