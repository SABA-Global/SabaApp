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
	NSString *lastEnglishDate = [[NSString alloc] init];
	NSString *lastHijriDate = [[NSString alloc] init];
	
	
	for(NSDictionary* data in array){
		DailyProgram *dailyProgram = [DailyProgram fromDictionary:data];

		// we don't want to show empty rows.
		// currently, time field contains the <br> which mean empty line. I am ignoring it for now.
		if([[dailyProgram time] compare:@"<br>"] == YES){
			continue;
		}
		
		if(dailyProgram.time.length != 0 && [dailyProgram.time characterAtIndex:0] == '\'' ){
			dailyProgram.time = [dailyProgram.time substringFromIndex:1];
		}
		
		if([dailyProgram.day compare:@""] == YES){
			dailyPrograms = [[NSMutableArray alloc]init];
			[weeklyPrograms addObject:dailyPrograms];
			lastDay = dailyProgram.day;
		} else {
			dailyProgram.day = lastDay;
		}
		
		if([dailyProgram.englishDate length] != 0){
			// english date is coming in this format,we need to remove all "'" :(
			// "englishdate": "'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''December 9"
			// Date comes after 178th character.
			NSRange rangeToSearch = NSMakeRange(0, [dailyProgram.englishDate length] - 1);
			NSRange rangeOfSingleQuote = [dailyProgram.englishDate rangeOfString:@"'" options:NSBackwardsSearch range:rangeToSearch];
			dailyProgram.englishDate = [dailyProgram.englishDate substringFromIndex:rangeOfSingleQuote.location+1];
			lastEnglishDate = dailyProgram.englishDate;
		} else {
			dailyProgram.englishDate = lastEnglishDate;
		}
		
		if([dailyProgram.hijriDate length] != 0){
			lastHijriDate = dailyProgram.hijriDate;
		} else {
			dailyProgram.hijriDate = lastHijriDate;
		}
		
		[dailyPrograms addObject:dailyProgram];
	}
	
	return weeklyPrograms;
}

@end