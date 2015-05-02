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
	NSLog(@"imageHeight: %ld", self.imageHeight);
	NSLog(@"imageWidth: %ld", self.imageWidth);
}

+(Program*) fromDictionary:(NSDictionary * )dictionary{
	
	return [[Program alloc] initWithDictionary:dictionary];
}

+(NSArray*) fromArray:(NSArray * )array{
	NSMutableArray *programs = [[NSMutableArray alloc]init];
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
			Program *program1 = [[Program alloc] init];
			NSMutableString* title = [NSMutableString string];
			[title appendString:[dailyProgram day]];
			[title appendString:@"/"];
			[title appendString:[dailyProgram englishDate]];
			[title appendString:@"/"];
			[title appendString:[dailyProgram hijriDate]];
			
			program1.title = title;
			
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
			
			program1.programDescription = description;
			program1.lastUpated = [NSDateFormatter localizedStringFromDate:[NSDate date]
															  dateStyle:NSDateFormatterShortStyle
															  timeStyle:NSDateFormatterFullStyle];

			[programs addObject:program1];//(sabaProgram);

		}
	}
	
	return programs;
}

//public static ArrayList<SabaProgram> fromWeeklyPrograms(String programName, List<List<DailyProgram>> weeklyPrograms){
//	ArrayList<SabaProgram> programs = new ArrayList<SabaProgram>();
//	//ArrayList<WeeklyProgram> weeklyPrograms = WeeklyProgram.fromJSONArray(programName, weeklyPrograms);
//	
//	int length = weeklyPrograms.size();
//	// Weekly programs are coming in in different way as compare to other programs. Every day we may have different sub-programs
//	// like time based. e.g. at 6:30 PM - Maghrib prayers, 7:00 PM Dua e kumael etc... and everday we might have different number
//	//	of programs. e.g. on Ashora day, we have all day programs. on 21st Ramadan, all night programs from iftaar to sehri etc.
//	
//	// Outer loop is navigating for one whole day program. It might have many sub-programs
//	for(int index=0; index < length; index++){
//		SabaProgram sabaProgram = new SabaProgram();
//		sabaProgram.setProgramName(programName);
//		List<DailyProgram> dailyPrograms = weeklyPrograms.get(index);
//		if(dailyPrograms != null && dailyPrograms.get(0)!=null){
//			StringBuilder sb = new StringBuilder();
//			//Log.d("SabaProgram: ", );
//			sb.append(dailyPrograms.get(0).getDay());
//			
//			sb.append("/");
//			sb.append(dailyPrograms.get(0).getEnglishDate());
//			sb.append("/");
//			sb.append(dailyPrograms.get(0).getHijriDate());
//			sabaProgram.mTitle = sb.toString();
//			
//			// Inner loop is navigating through sub-programs.
//			// Formatting note: we can get the max number of lines from TextView and combined those lines
//			// and make a block. we should ignore other lines..
//			
//			//int maxLinesToShow = 0;  // currently, we are displaying ... after two lines. we can modify here
//			// if we want to display after 3 lines.
//			StringBuilder description = new StringBuilder();
//			for(final DailyProgram program : dailyPrograms){
//				if(program != null && !program.getTime().trim().isEmpty() ){
//					description.append(program.getTime());
//					description.append("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
//				}
//				
//				// make this <br> business better.. improve the code. :(
//				if(program.getProgram().startsWith("<br>")){
//					description.append(program.getProgram().replace("<br>", ""));
//					description.append("<br>");
//				} else if(!program.getProgram().isEmpty()){
//					description.append(program.getProgram());
//					description.append("<br>");
//				}
//				//maxLinesToShow++;
//			}
//			
//			sabaProgram.mDescription = description.toString();
//			sabaProgram.setLastUpdated(new Date().toString());
//			Log.d("Weekly - Program: ", sabaProgram.mDescription);
//			programs.add(sabaProgram);
//		}
//	}
//	return programs;
//}
@end