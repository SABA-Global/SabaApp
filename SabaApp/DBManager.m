//
//  DBManager.m
//  SabaApp
//
//  Created by Syed Naqvi on 5/7/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "DBManager.h"

// Model
#import "Program.h"

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

- (BOOL) saveSabaPrograms:(NSArray*) programs{
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
		for (Program *program in programs) {
		
			NSString * query  = [NSString stringWithFormat:@"INSERT INTO SabaProgram (id, programName,lastUpdated, description,					 title, imageUrl, imageWidth, imageHeight) \
								 VALUES \
								 (%d, \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", %lu, %lu)",
								 count++,
								 [[program name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
								 [program lastUpated],
								 [[program programDescription] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
								 [[program title] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
								 [[program imageUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
								 [program imageWidth],
								 [program imageHeight] ];
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
	
	return YES;
}

- (NSArray*) getSabaPrograms{
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
		NSString  * query = @"SELECT * FROM SabaProgram";
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
				program.imageUrl			= [[NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 5)]
											   stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
				program.imageHeight			= sqlite3_column_int(statement, 6);
				program.imageWidth			= sqlite3_column_int(statement, 7);
				
				// debug
				//[self displayProgram:program];
				
				// adding program in an array.
				[programs addObject:program];
			}
			sqlite3_finalize(statement);
		}
	}
	
	sqlite3_close(database);
	
	// debug
	//[self displayPrograms:programs];
	
	return programs;
}

- (NSArray*) getWeeklyPrograms{
	return nil;
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


//sqlite3* db = NULL;
//sqlite3_stmt* stmt =NULL;
//int rc=0;
//rc = sqlite3_open_v2(dbFilePath, &db, SQLITE_OPEN_READONLY , NULL);
//if (SQLITE_OK != rc)
//{
//	sqlite3_close(db);
//	NSLog(@"Failed to open db connection");
//}
//else
//{
//	NSString  * query = @"SELECT * from PrayerTimes";
//	
//	
//	rc =sqlite3_prepare_v2(db, [query UTF8String], -1, &stmt, NULL);
//	
//	NSLog(@"Database returned error %d: %s", sqlite3_errcode(db), sqlite3_errmsg(db));
//	
//	
//	if(rc == SQLITE_OK)
//	{
//		while (sqlite3_step(stmt) == SQLITE_ROW) //get each row in loop
//		{
//			
//			NSString * name =[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];
//			NSInteger age =  sqlite3_column_int(stmt, 2);
//			NSInteger marks =  sqlite3_column_int(stmt, 3);
//			
//			
//			
//			NSLog(@"name: %@, age=%ld , marks =%ld",name,(long)age,(long)marks);
//			
//		}
//		NSLog(@"Done");
//		sqlite3_finalize(stmt);
//	}
//	else
//	{
//		NSLog(@"Failed to prepare statement with rc:%d",rc);
//	}
//	sqlite3_close(db);
//}

@end
