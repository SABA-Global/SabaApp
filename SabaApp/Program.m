//
//  Program.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/25/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "Program.h"
#import "DailyProgram.h"

@implementation Program

-(id)initWithArray:(NSArray * )array{
	self = [super init];
	if(self){
		
	}
	
	return self;
}

-(id)initWithDictionary:(NSDictionary * )dictionary{
	self = [super init];
	if(self){
		
		//[dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"];
		
		self.lastUpated = [NSDateFormatter localizedStringFromDate:[NSDate date]
															  dateStyle:NSDateFormatterShortStyle
															  timeStyle:NSDateFormatterFullStyle];
		self.title				= dictionary[@"title"];
		self.programDescription = dictionary[@"description"];
		self.imageUrl			= dictionary[@"imageurl"];
		self.imageHeight		= [dictionary[@"imageheight"] intValue];
		self.imageWidth			= [dictionary[@"imagewidth"] intValue];
		//[self display];
	}
	
	return self;
}

// debug function...
-(void) display{
	NSLog(@"title: %@", self.title);
	NSLog(@"programDescription: %@", self.programDescription);
	NSLog(@"imageUrl: %@", self.imageUrl);
	NSLog(@"imageHeight: %lu", (long)self.imageHeight);
	NSLog(@"imageWidth: %lu", (long)self.imageWidth);
}

+(Program*) fromDictionary:(NSDictionary * )dictionary{
	
	return [[Program alloc] initWithDictionary:dictionary];
}

+(NSArray*) fromArray:(NSArray * )array{
	NSMutableArray *programs = [[NSMutableArray alloc]init];
	
//	for(Program *program in array){
//		NSLog(@"%@, %@, %@, %@, %@,", program.name, program.lastUpated, program.programDescription, program.title, program.imageUrl);
//	}
	
	
	for (NSDictionary* value in array) {
		Program *program = [[Program alloc] initWithDictionary:value];
		
		NSString *title = [program title];
		NSString *newLine = @"";
		
		// remove new line('\n') if it exists at first character.
		if ([title length] > 0){
			newLine = [title substringToIndex:1];
			if([newLine characterAtIndex:0] == '\n')
				title = [title substringFromIndex:1];
		}
		program.title = title;
		[programs addObject:program];
	}
	
	return programs;
}

+(NSArray*) fromWeeklyPrograms:(NSArray*)weeklyPrograms{
	NSMutableArray* programs = [NSMutableArray array];
	
	for (NSArray* dailyPrograms in weeklyPrograms) {
		if(dailyPrograms != nil && [dailyPrograms objectAtIndex:0] != nil){
			DailyProgram *dailyProgram = [dailyPrograms objectAtIndex:0];
			Program *program = [[Program alloc] init];
			NSMutableString* title = [NSMutableString string];
			[title appendString:[dailyProgram day]];
			[title appendString:@" "];
			[title appendString:[dailyProgram englishDate]];
			[title appendString:@" / "];
			[title appendString:[dailyProgram hijriDate]];
			
			program.title = title;
			
			NSMutableString* description = [NSMutableString string];
			for(DailyProgram* program in dailyPrograms){
				if(program != nil &&
				   program.time != nil &&
				   [program.time stringByTrimmingCharactersInSet:
					 [NSCharacterSet whitespaceCharacterSet] ].length != 0){
					
					[description appendString:program.time];
					[description appendString:@"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" ];
				}
				
				// improve this <br> business better.. improve the code. :(
				if([program.program hasPrefix:@"<br>"]){
					[description appendString:[program.program stringByReplacingOccurrencesOfString:@"<br>"
																						 withString:@"" ] ];
					[description appendString:@"<br>"];
				} else if([program.program length] != 0){
					[description appendString:program.program];
					[description appendString:@"<br>"];
				}
			}
			
			program.programDescription = description;
			program.lastUpated = [NSDateFormatter localizedStringFromDate:[NSDate date]
															  dateStyle:NSDateFormatterShortStyle
															  timeStyle:NSDateFormatterFullStyle];

			[programs addObject:program];

		}
	}
	
	return programs;
}
@end