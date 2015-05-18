//
//  PrayerTimes.h
//  SabaApp
//
//  Created by Syed Naqvi on 5/17/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrayerTimes : NSObject

@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *imsaak;
@property (nonatomic, strong) NSString *fajr;
@property (nonatomic, strong) NSString *sunrise;
@property (nonatomic, strong) NSString *zuhr;
@property (nonatomic, strong) NSString *sunset;
@property (nonatomic, strong) NSString *maghrib;
@property (nonatomic, strong) NSString *midnight;

@end
