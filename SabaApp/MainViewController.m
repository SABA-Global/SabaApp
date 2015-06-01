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

static NSString *SABA_BASE_URL = @"http://www.saba-igc.org/mobileapp/datafeedproxy.php?sheetName=weekly&sheetId=4";
//static NSString *SABA_BASE_URL = @"http://praytime.info/getprayertimes.php?school=0&gmt=-480";

@interface MainViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *englishDate;
@property (weak, nonatomic) IBOutlet UILabel *hijriDate;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;
	
	[self.collectionView registerNib:[UINib nibWithNibName:@"SabaCell" bundle:nil] forCellWithReuseIdentifier:@"SabaCell"];
	[self.navigationController setNavigationBarHidden:YES]; // shouldn't show NavigationBar on this controller.
	[self showDates];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
	[self showDates];
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
	
	cell.layer.borderWidth = 0.5f;
	cell.layer.borderColor = [UIColor colorWithRed:255.0f/255.0f
											 green:255.0f/255.0f
											  blue:255.0f/255.0f
											 alpha:1.0f].CGColor; // white
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
	transition.duration = 0.2;
	transition.type = kCATransitionPush;
	transition.subtype = kCATransitionFromRight;
	
	[self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
	[self.navigationController pushViewController:controller animated:NO];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
	[self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
	[cell setSelected:YES];
}

// we will add Hijri date here too, Currently, it adds english date.
-(void) showDates{
	
	NSString* date = [NSDateFormatter localizedStringFromDate:[NSDate date]
													dateStyle:NSDateFormatterFullStyle
													timeStyle:NSDateFormatterNoStyle];
	self.englishDate.text = date;
}

-(void) refreshMainViewController{
	[self showDates];
}
@end
