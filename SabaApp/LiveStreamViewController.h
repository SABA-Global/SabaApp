//
//  LiveStreamViewController.h
//  SabaApp
//
//  Created by Syed Naqvi on 6/11/16.
//  Copyright © 2016 Naqvi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTPlayerView.h"

@interface LiveStreamViewController : UIViewController

@property (strong, nonatomic)   IBOutlet YTPlayerView *playerView;
@property (weak, nonatomic) NSString *hallName;
@property (weak, nonatomic) NSString *videoId;

@end
