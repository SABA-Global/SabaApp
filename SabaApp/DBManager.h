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
- (void) prepareDatabase;
- (BOOL) saveSabaPrograms:(NSArray*) programs;
- (BOOL) saveWeeklyPrograms:(NSArray*) programs;

- (NSArray*) getSabaPrograms;
- (NSArray*) getWeeklyPrograms;
@end
