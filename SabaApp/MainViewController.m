//
//  MainViewController.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/23/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "MainViewController.h"
#import "SabaCell.h"

#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"
#import "SabaClient.h"


static NSString *SABA_BASE_URL = @"http://www.saba-igc.org/mobileapp/datafeedproxy.php?sheetName=weekly&sheetId=4";
//static NSString *SABA_BASE_URL = @"http://praytime.info/getprayertimes.php?school=0&gmt=-480";

@interface MainViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@property (nonatomic, strong) NSMutableArray *cellArray;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;
	
	self.cellArray = [[NSMutableArray alloc] init];
	
	[self.cellArray addObject:[SABA_BASE_URL stringByAppendingString:@"2"]]; // Upcoming programs
	[self.cellArray addObject:[SABA_BASE_URL stringByAppendingString:@"4"]]; // Weekly Programs
	[self.cellArray addObject:[SABA_BASE_URL stringByAppendingString:@"5"]]; // Community Announcements
	[self.cellArray addObject:[SABA_BASE_URL stringByAppendingString:@"6"]]; // General Announcements
	
	NSLog(@"count: %lu", (unsigned long)self.cellArray.count);
	
	[self.collectionView registerNib:[UINib nibWithNibName:@"SabaCell" bundle:nil] forCellWithReuseIdentifier:@"SabaCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma CollectionView

// number of items in section
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
	NSLog(@"count: %lu", (unsigned long)self.cellArray.count);
	return self.cellArray.count;
}

// sets the size of cell dynamically as per phone size.
- (CGSize)collectionView:(UICollectionView *)collectionView
				  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
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
			cell.title.text			= @"San Jose\nPrayer Times";
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
	
	NSLog(@"%ld", (long)indexPath.row);
	[[SabaClient sharedInstance] getUpcomingPrograms:^(NSString* programName, NSArray *programs, NSError *error) {
		
		if (error) {
			NSLog(@"Error getting more tweets: %@", error);
		} else {
			//NSLog(@"programs: %@", programs);
		}
	}];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
	[self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
	[cell setSelected:YES];

}

#pragma mark Launch selected ViewController
-(void) launchSelectedViewController:(int) index{
	
}

//-(void) launchSelectedViewController:(int) index{
//	
//}
@end
