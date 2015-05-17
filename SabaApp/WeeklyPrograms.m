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

+(NSArray*) fromArray:(NSArray*)programsArray{
	NSMutableArray *weeklyPrograms = [NSMutableArray array]; // array of array of DailyProgram
	NSMutableArray *dailyPrograms = nil; // array of DailyProgram
	
	NSString *lastDay = [[NSString alloc] init];
	NSString *lastEnglishDate = [[NSString alloc] init];
	NSString *lastHijriDate = [[NSString alloc] init];
	
	for(NSDictionary* data in programsArray){
		// program is a slot of a day. Array of these program will become dailyPrograms
		DailyProgram *dailyProgram = [DailyProgram fromDictionary:data];

		// we don't want to show empty rows.
		// currently, time field contains the <br> which mean empty line. I am ignoring it for now.
		if([ [[dailyProgram time] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] caseInsensitiveCompare:@"<br>"] == NSOrderedSame){
			continue;
		}
		
		if(dailyProgram.time.length != 0
		   && [dailyProgram.time characterAtIndex:0] == '\'' ){
			dailyProgram.time = [dailyProgram.time substringFromIndex:1];
		}
		
		// Day comes for first program slot only and for next slots of the same day its empty.
		if([[dailyProgram.day stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] != 0){
			dailyPrograms = [NSMutableArray array]; // allocating array for daily Programs.
			[weeklyPrograms addObject:dailyPrograms]; // adding array of dailyPrograms in weeklyPrograms.
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
		
		[dailyPrograms addObject:dailyProgram]; // we are adding a dailyProgram in dailyPrograms array.
	}
	
	return weeklyPrograms;
}

@end