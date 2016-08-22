//
//  CalendarHelper.h
//  SabaApp
//
//  Created by Syed Naqvi on 11/9/15.
//  Copyright © 2015 Naqvi. All rights reserved.
//

#ifndef CalendarHelper_h
#define CalendarHelper_h

#import <Foundation/Foundation.h>

@interface CalendarHelper : NSObject

+ (void)requestAccess:(void (^)(BOOL granted, NSError *error))success;
+ (BOOL)addEventAt:(NSDate*)eventDate withTitle:(NSString*)title inLocation:(NSString*)location;

@end

#endif /* CalendarHelper_h */
