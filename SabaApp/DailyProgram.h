//
//  DailyProgram.h
//  SabaApp
//
//  Created by Syed Naqvi on 4/28/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DailyProgram : NSObject

@property (nonatomic, strong) NSString *day;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *program;
@property (nonatomic, strong) NSString *hijriDate;
@property (nonatomic, strong) NSString *lastUpated;
@property (nonatomic, strong) NSString *englishDate;


//-(id)initWithArray:(NSArray * )array;

-(id)initWithDictionary:(NSDictionary * )dictionary;

// returns DailyProgram from dictionary (JSON)
+(DailyProgram*) fromDictionary:(NSDictionary * )dictionary;

// retruns an array of DailyPrograms
+(NSArray*) fromArray:(NSArray * )array;


@end
