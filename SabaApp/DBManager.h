//
//  DBManager.h
//  SabaApp
//
//  Created by Syed Naqvi on 5/7/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBManager : NSObject
{
	NSString *databasePath;
}

+(DBManager*)sharedInstance;
- (void) prepareDatabase; // Initialize database, like copy in document folder
						  // and make sure that it exists.

// saveSabaPrograms in database - SabaProgram Table.
- (BOOL) saveSabaPrograms:(NSArray*) programs :(NSString*)programName;

// saveWeeklyPrograms in database - DailyPrograms Table.
- (BOOL) saveWeeklyPrograms:(NSArray*) programs;

// getSabaPrograms by given name - currently, we have Events/Anouncements
// and Weekly/daily programs stored in SabaProgram table
- (NSArray*) getSabaPrograms:(NSString*)programName;

// confirm this function is being used.
- (NSArray*) getWeeklyPrograms;

// returns daily programs for a given day.
- (NSArray*) getDailyProgramsByDay:(NSString*) day;

// returns prayerTimes for given city and date
-(NSArray*) getPrayerTimes:(NSString*) city :(NSString*) date;
@end
