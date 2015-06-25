//
//  MainViewController.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/23/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "MainViewController.h"

// Third party imports
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

// CollectionView Cell
#import "SabaCell.h"

// Client
#import "SabaClient.h"

// ViewControllers
#import "EventsViewController.h"
#import "ContactViewController.h"
#import "DonationViewController.h"
#import "SettingsViewController.h"
#import "PrayerTimesViewController.h"
#import "WeeklyScheduleViewController.h"

@interface MainViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *englishDate;
@property (weak, nonatomic) IBOutlet UILabel *hijriDate;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	[[SabaClient sharedInstance] showSpinner:YES];
	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;
	
	[self.collectionView registerNib:[UINib nibWithNibName:@"SabaCell" bundle:nil] forCellWithReuseIdentifier:@"SabaCell"];
	[self.navigationController setNavigationBarHidden:YES]; // shouldn't show NavigationBar on this controller.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
	[self showDates];
	[[SabaClient sharedInstance] showSpinner:NO];
}

#pragma CollectionView

// number of items in section
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
	return 4;
}

// sets the size of cell dynamically as per phone size.
- (CGSize)collectionView:(UICollectionView *)collectionView
				  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
	CGSize size;
	
	size.height = self.collectionView.frame.size.height/2-2;
	size.width = self.collectionView.frame.size.width/2-1;
	
	return size;
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
	SabaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SabaCell" forIndexPath:indexPath];
	
	// This is how you change the background color when we click on the tile. We might find a better sol.
	UIView *bgSelectedColorView = [[UIView alloc] init];
	bgSelectedColorView.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:.10];
	[cell setSelectedBackgroundView:bgSelectedColorView];
	
//	UIView *bgColorView = [[UIView alloc] init];
//	bgColorView.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0];
//	[cell setBackgroundView:bgColorView];

	
	cell.layer.borderWidth = 0.5f;
	cell.layer.borderColor = [UIColor colorWithRed:255.0f/255.0f
											 green:255.0f/255.0f
											  blue:255.0f/255.0f
											 alpha:.5].CGColor; // white
	switch(indexPath.row){
		case 0:
			cell.title.text			= @"Weekly \nSchedule";
			cell.imageView.image	= [UIImage imageNamed:@"calendar.png"];
			break;
		case 1:
			cell.title.text			= @"Events & \nAnnouncements";
			cell.imageView.image	= [UIImage imageNamed:@"megaphone.png"];
			break;
		case 2:
			cell.title.text			= @"Prayer Times";
			cell.imageView.image	= [UIImage imageNamed:@"pray.png"];
			break;
		case 3:
			cell.title.text			= @"Contact &\nDirections";
			cell.imageView.image	= [UIImage imageNamed:@"location.png"];
			break;
			
		default:
			break;
	}
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
	[self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
	
	UIViewController *controller = nil;
	switch(indexPath.row){
		case 0:
			controller = [[WeeklyScheduleViewController alloc]init];
			break;
		case 1:
			controller = [[EventsViewController alloc]init];
			break;
		case 2:
			controller = [[PrayerTimesViewController alloc]init];
			break;
		case 3:
			controller = [[ContactViewController alloc]init];
			break;
			
		default:
			break;
	}
	
	CATransition *transition = [CATransition animation];
	transition.duration = 0.25;
	transition.type = kCATransitionFade;
	transition.subtype = kCATransitionFromRight;
	
	[self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
	[self.navigationController pushViewController:controller animated:NO];
}

// we will add Hijri date here too, Currently, it adds english date.
-(void) showDates{
	
	NSString* date = [NSDateFormatter localizedStringFromDate:[NSDate date]
													dateStyle:NSDateFormatterFullStyle
													timeStyle:NSDateFormatterNoStyle];
	self.englishDate.text = date;
	
	NSString *hijriDate = [[SabaClient sharedInstance] getCachedHijriDate];
	if(hijriDate==nil || hijriDate.length==0){
		[[SabaClient sharedInstance] getHijriDateFromWeb:^(NSDictionary *jsonResponse, NSError *error) {
			if(error){
				NSLog(@"Error getting HijriDate: %@", error.localizedDescription);
			} else {
				[[SabaClient sharedInstance] storeHijriDate:jsonResponse[@"hijridate"]];
				self.hijriDate.text = jsonResponse[@"hijridate"];
			}
		}];
	} else {
		self.hijriDate.text = hijriDate;
	}
}

//-(void) setAlarm{
//	UILocalNotification *local = [[UILocalNotification alloc] init];
//	
//	// create date/time information
//	local.fireDate = [NSDate dateWithTimeIntervalSinceNow:60]; //time in seconds
//	local.timeZone = [NSTimeZone defaultTimeZone];
//	
//	// set notification details
//	local.alertBody = @"Alarm!";
//	local.alertAction = @"Okay!";
//	
//	
//	local.soundName = [NSString stringWithFormat:@"Typewriters.caf"];
//	
//	// Gather any custom data you need to save with the notification
//	NSDictionary *customInfo =
//	[NSDictionary dictionaryWithObject:@"Prayer Time" forKey:@"Isha"];
//	local.userInfo = customInfo;
//	
//	// Schedule it!
//	[[UIApplication sharedApplication] scheduleLocalNotification:local];
//}
//
//- (void)addLocalNotification:(int)year
//							:(int)month
//							:(int)day
//							:(int)hours
//							:(int)minutes
//							:(int)seconds
//							:(NSString*)alertSoundName
//							:(NSString*)alertBody
//							:(NSString*)actionButtonTitle
//							:(NSString*)notificationID {
//	
//	NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
//	
//	//set the notification date/time
//	NSDateComponents *dateComps = [[NSDateComponents alloc] init];
//	[dateComps setDay:day];
//	
//	[dateComps setMonth:month];
//	
//	[dateComps setYear:year];
//	[dateComps setHour:hours];
//	
//	[dateComps setMinute:minutes];
//	[dateComps setSecond:seconds];
//	
//	NSDate *notificationDate = [calendar dateFromComponents:dateComps];
//	
//	UILocalNotification *localNotif = [[UILocalNotification alloc] init];
//	if (localNotif == nil)
//		return;
//	localNotif.fireDate = notificationDate;
//	localNotif.timeZone = [NSTimeZone defaultTimeZone];
//	
//	// Set notification message
//	localNotif.alertBody = alertBody;
//	// Title for the action button
//	localNotif.alertAction = actionButtonTitle;
//	
//	localNotif.soundName = (alertSoundName == nil) ? UILocalNotificationDefaultSoundName : alertSoundName;
//	
//	//use custom sound name or default one - look here to find out more: http://developer.apple.com/library/ios/#documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/IPhoneOSClientImp/IPhoneOSClientImp.html%23//apple_ref/doc/uid/TP40008194-CH103-SW13
//	
//	localNotif.applicationIconBadgeNumber += 1; //increases the icon badge number
//	
//	// Custom data - we're using them to identify the notification. comes in handy, in case we want to delete a specific one later
//	NSDictionary *infoDict = [NSDictionary dictionaryWithObject:notificationID forKey:notificationID];
//	localNotif.userInfo = infoDict;
//	
//	// Schedule the notification
//	[[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
//}


@end
