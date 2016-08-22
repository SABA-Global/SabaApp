//
//  LiveStreamListViewController.h
//  SabaApp
//
//  Created by Syed Naqvi on 6/11/16.
//  Copyright © 2016 Naqvi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveStreamListViewController : UIViewController
@end

@interface LiveStreamFeed : NSObject
@property (nonatomic, strong) NSString *hallName;
@property (nonatomic, strong) NSString *videoId; // this is Youtube Video Id -  code.

+(NSArray*) fromDictionary:(NSDictionary *)dictionary;
@end