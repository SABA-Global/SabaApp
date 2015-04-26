//
//  SabaClient.h
//  SabaApp
//
//  Created by Syed Naqvi on 4/25/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SabaClient : NSObject

+ (SabaClient *)sharedInstance;

-(void) getUpcomingPrograms:(void (^)(NSString* programName, NSArray *programs, NSError *error))completion;
-(void) getWeeklyPrograms:(void (^)(NSString* programName, NSArray *programs, NSError *error))completion;
-(void) getCommunityAnnouncements:(void (^)(NSString* programName, NSArray *programs, NSError *error))completion;
-(void) getGeneralAnnouncements:(void (^)(NSString* programName, NSArray *programs, NSError *error))completion;

@end
