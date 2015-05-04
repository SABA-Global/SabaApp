//
//  Program.h
//  SabaApp
//
//  Created by Syed Naqvi on 4/25/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

//Note: We might need to consider renaming this "Program" class to
// Event and then change the suitable name of the DailyProgram class. It might be
// a Daily - Bottom line, we need to rename these model classes which make sense like
// what they are doing exactly.
#import <Foundation/Foundation.h>

@interface Program : NSObject

@property (nonatomic, strong) NSString *lastUpated;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *programDescription;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, assign) NSInteger imageHeight;
@property (nonatomic, assign) NSInteger imageWidth;

-(id)initWithArray:(NSArray * )array;
-(id)initWithDictionary:(NSDictionary * )dictionary;

+(Program*) fromDictionary:(NSDictionary * )dictionary;

// retruns an array of Programs
+(NSArray*) fromArray:(NSArray * )array;

// caller passes Programs in weekly format which is two dimesional array of DailyProgram.
// NSArray of NSArray of DailyProgram.
// NSArray of DailyProgram represents all programs in a day.

+(NSArray*) fromWeeklyPrograms:(NSArray*)weeklyPrograms;
@end
