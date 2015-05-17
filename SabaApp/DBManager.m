//
//  DBManager.m
//  SabaApp
//
//  Created by Syed Naqvi on 5/7/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "DBManager.h"

// Models
#import "Program.h"
#import "DailyProgram.h"

static DBManager *sharedInstance = nil;
static NSString *databasePath;
static BOOL databaseReady = NO;

@implementation DBManager

+(DBManager*)sharedInstance{
	// grand centeral dispatch which makes sure it will execute once.
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if (!sharedInstance) {
			sharedInstance = [[super allocWithZone:NULL]init];
		}
	});

	return sharedInstance;
}

-(void) prepareDatabase{
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	databasePath = [documentsDir stringByAppendingPathComponent:@"Saba.sqlite"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// check if database exists in Documents folder, if not then copy it there from bundle.
	if ([fileManager fileExistsAtPath:databasePath]  == NO)
	{
		NSError *error = nil;
		// coping database in Documents from bundle.
		if([[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"Saba" ofType:@"db"]  toPath:databasePath error:&error]){
			NSLog(@"Database successfully copied");
		} else {
			NSLog(@"Error: description-%@ \n", [error localizedDescription]);
			NSLog(@"Error: reason-%@", [error localizedFailureReason]);
		}
	}
	
	if([fileManager fileExistsAtPath:databasePath] == YES) {
		NSLog(@"Database exists.");
		databaseReady = YES;
	} else {
		NSLog(@"Error: Database doesn't exist.");
	}
}

// Saving  - progrms are Events/Annoncements and Weekly Programs
- (BOOL) saveSabaPrograms:(NSArray*) programs :(NSString*)programName{
	if(databaseReady == NO){
		NSLog(@"Error: Database is NOT ready.");
		return NO;
	}
	
	int returnCode = 0;
	BOOL success = YES;
	sqlite3* database = NULL;

	returnCode = sqlite3_open_v2([databasePath UTF8String], &database, SQLITE_OPEN_READWRITE , NULL);
	long rowId = [self getNumberOfRowsInTable:@"SabaProgram" :database];
	
	if (SQLITE_OK != returnCode){
		success = NO;
		NSLog(@"Failed to open db connection, DB path %@", databasePath);
	} else {
		
		for (Program *program in programs) {
		
			NSString * query  = [NSString stringWithFormat:@"INSERT INTO SabaProgram (id, programName,lastUpdated, description,					 title,						 imageUrl, imageWidth, imageHeight) \
								 VALUES \
								 (%ld, \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", %lu, %lu)",
								 ++rowId,
								 programName,
								 [program lastUpated],
								 [[program programDescription] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
								 [[program title] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
								 [[program imageUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
								 (long)[program imageWidth],
								 (long)[program imageHeight] ];
			char * errMsg;
			returnCode = sqlite3_exec(database, [query UTF8String], NULL, NULL, &errMsg);
			if(SQLITE_OK != returnCode)
				NSLog(@"Failed to insert record - returnCode = %d, errorMessage = %s", returnCode, errMsg);
		}
	}
	sqlite3_close(database);
	
	return success;
}

- (BOOL) saveWeeklyPrograms:(NSArray*) programs{
	if(databaseReady == NO){
		NSLog(@"Error: Database is NOT ready.");
		return NO;
	}
	
	int returnCode = 0;
	BOOL success = YES;
	sqlite3* database = NULL;
	
	returnCode = sqlite3_open_v2([databasePath UTF8String], &database, SQLITE_OPEN_READWRITE , NULL);
	
	if (SQLITE_OK != returnCode){
		success = NO;
		NSLog(@"Failed to open db connection, DB path %@", databasePath);
	} else {
		int count = 0;
		for (NSArray *dailyPrograms in programs) {
			for (DailyProgram *dailyProgram in dailyPrograms) {
				NSString * query  = [NSString stringWithFormat:@"INSERT INTO DailyProgram (id, day, englishDate, hijriDate,	\
									 time, program, lastUpdated) VALUES \
									 (%d, \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
									 count++,
									 [[dailyProgram day] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
									 [dailyProgram englishDate],
									 [[dailyProgram hijriDate] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
									 [[dailyProgram time] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
									 [[dailyProgram program] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
									 [dailyProgram lastUpated]];
				char * errMsg;
				returnCode = sqlite3_exec(database, [query UTF8String], NULL, NULL, &errMsg);
				if(SQLITE_OK != returnCode)
					NSLog(@"Failed to insert record - returnCode = %d, errorMessage = %s", returnCode, errMsg);
			}
		}
	}
	sqlite3_close(database);
	
	return success;
}

// ----------------------------------------- getting Programs -----------------
// These progrms are Events and Annoncements and weeklyPrograms too.
- (NSArray*) getSabaPrograms:(NSString*) programName{
	if(databaseReady == NO){
		NSLog(@"Error: Database is NOT ready.");
		return nil;
	}
	
	int returnCode = 0;
	sqlite3* database = NULL;
	sqlite3_stmt* statement = NULL;
	
	NSMutableArray *programs = [NSMutableArray array]; // contains the programs.
	
	returnCode = sqlite3_open_v2([databasePath UTF8String], &database, SQLITE_OPEN_READONLY , NULL);
	if (SQLITE_OK != returnCode){
		NSLog(@"Failed to open db connection, DB path %@", databasePath);
	} else {
		NSString  * query = [NSString stringWithFormat:@"SELECT * FROM SabaProgram WHERE programName = \"%@\"", programName];
		returnCode = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL);
		if(returnCode != SQLITE_OK){
			NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
		} else {
			while (sqlite3_step(statement) == SQLITE_ROW) { //get each row in loop
				Program *program			= [[Program alloc] init];
				program.name				= [[NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 1)]
											   stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				program.lastUpated			= [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
				program.programDescription	= [[NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 3)]
											   stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				program.title				= [[NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 4)]
					                           stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

				// process further if its not "Weekly Programs"
				if([programName isEqualToString:@"Weekly Programs"] == NO){
					program.imageUrl			= [[NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 5)]
											   stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			
					program.imageHeight			= sqlite3_column_int(statement, 6);
					program.imageWidth			= sqlite3_column_int(statement, 7);
				}
				
				// adding program in an array.
				[programs addObject:program];
			}
			sqlite3_finalize(statement);
		}
	}
	
	sqlite3_close(database);
	
	return programs;
}

-(NSArray*) getDailyProgramsByDay:(NSString*) day{
	
	if(databaseReady == NO){
		NSLog(@"Error: Database is NOT ready.");
		return nil;
	}
	
	int returnCode = 0;
	sqlite3* database = NULL;
	sqlite3_stmt* statement = NULL;
	
	NSMutableArray *dailyPrograms = [NSMutableArray array]; // contains the programs.
	
	returnCode = sqlite3_open_v2([databasePath UTF8String], &database, SQLITE_OPEN_READONLY , NULL);
	if (SQLITE_OK != returnCode){
		NSLog(@"Failed to open db connection, DB path %@", databasePath);
	} else {
		NSString  * query = [NSString stringWithFormat:@"SELECT * FROM DailyProgram WHERE day = \"%@\"", day];
		returnCode = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL);
		if(returnCode != SQLITE_OK){
			NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
		} else {
			while (sqlite3_step(statement) == SQLITE_ROW) { //get each row in loop
				DailyProgram *dailyProgram = [[DailyProgram alloc] init];
				dailyProgram.day			= [[NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 1)]
											   stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				dailyProgram.englishDate	= [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
				dailyProgram.hijriDate		= [[NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 3)]
											   stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				dailyProgram.time			= [[NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 4)]
											   stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				dailyProgram.program		= [[NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 5)]
											   stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				dailyProgram.lastUpated		= [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 6)];
				
				// adding program in an array.
				[dailyPrograms addObject:dailyProgram];
				
			}
			sqlite3_finalize(statement);
		}
	}
	
	sqlite3_close(database);

	return dailyPrograms;
}

- (NSArray*) getWeeklyPrograms{
	
	if(databaseReady == NO){
		NSLog(@"Error: Database is NOT ready.");
		return nil;
	}
	
	int returnCode = 0;
	sqlite3* database = NULL;
	sqlite3_stmt* statement = NULL;
	
	NSMutableArray *programs = [NSMutableArray array]; // contains weekly programs.
	
	returnCode = sqlite3_open_v2([databasePath UTF8String], &database, SQLITE_OPEN_READONLY , NULL);
	if (SQLITE_OK != returnCode){
		NSLog(@"Failed to open db connection, DB path %@", databasePath);
	} else {
		NSString  * query = @"SELECT * FROM DailyProgram";
		returnCode = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL);
		if(returnCode != SQLITE_OK){
			NSLog(@"Database returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
		} else {
			
			while (sqlite3_step(statement) == SQLITE_ROW) { //get each row in loop
				DailyProgram *program			= [[DailyProgram alloc] init];
				program.day				= [[NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 1)]
											   stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				program.englishDate			= [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
				program.hijriDate	= [[NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 3)]
											   stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				program.time				= [[NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 4)]
											   stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				program.program			= [[NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 5)]
											   stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				program.lastUpated			= [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 6)];
				
				// adding program in an array.
				[programs addObject:program];
			}
			sqlite3_finalize(statement);
		}
	}
	
	sqlite3_close(database);
		
	return programs;
}

#pragma mark helper functions
-(int) getNumberOfRowsInTable:(NSString*)tableName :(sqlite3*)database{
	NSString *query = [NSString stringWithFormat:@"select count(*) from \"%@\"", tableName];
	
	int numberOfRows = 0;
	sqlite3_stmt *selectStatement;
	int returnCode = sqlite3_prepare_v2(database, [query UTF8String], -1, &selectStatement, NULL);
	if (returnCode != SQLITE_OK){
		NSLog(@"sqlite3_prepare_v2 returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
	}
	else{
		if(sqlite3_step(selectStatement) == SQLITE_ROW)
			numberOfRows = sqlite3_column_int(selectStatement, 0);
		else
			NSLog(@"sqlite3_step returned error %d: %s", sqlite3_errcode(database), sqlite3_errmsg(database));
	}
	
	sqlite3_finalize(selectStatement);
	
	return numberOfRows;
}

#pragma mark debug functions.
-(void) displayProgram:(Program*)program{
	NSLog(@"Program: %@, \n%@, \n%@, \n%@, \n%@. ", program.name, program.lastUpated, program.programDescription, program.title, program.imageUrl);
}

-(void) displayPrograms:(NSArray*)programs{
	for(Program *program in programs){
		[self displayProgram:program];
	}
}

#pragma mark "Prayer Times" table access
// Get todays time. date format should be MM-DD only. we don't care about year here..
-(NSArray*) getPrayerTimes:(NSString*) city :(NSString*) date{
	
	return nil;
}
@end
