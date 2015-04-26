//
//  Program.h
//  SabaApp
//
//  Created by Syed Naqvi on 4/25/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

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

@end
