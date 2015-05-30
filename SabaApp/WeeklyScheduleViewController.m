//
//  WeeklyScheduleViewController.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/26/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "WeeklyScheduleViewController.h"

// Third party imports
#import <SVProgressHUD.h>

#import "SabaClient.h"
#import "DailyProgram.h"
#import "WeeklyPrograms.h"
#import "ProgramCell.h"
#import "DBManager.h"
#import "AppDelegate.h"

#import "DailyProgramViewController.h"

@interface WeeklyScheduleViewController ()<UITableViewDelegate,
											UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *programs;
@property (strong, nonatomic) NSArray *dailyPrograms;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation WeeklyScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	// tableView delegate and source
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.separatorColor = [UIColor clearColor];
	
	[[SabaClient sharedInstance] showSpinner:YES];
	
	[self getWeeklyPrograms];
	[self setupNavigationBar];
	
	self.tableView.estimatedRowHeight = 160.0; // Very important: when we come back from detailViewController (after dismiss) - layout of this viewController messed up. If we add this line estimatedRowHeight, its hels to keep the height and UITextView doesn't vanish.
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	
	// register cell for TableView
	[self.tableView registerNib:[UINib nibWithNibName:@"ProgramCell" bundle:nil] forCellReuseIdentifier:@"ProgramCell"];
	
	self.tableView.tableFooterView = [[UIView alloc] init];
	
	// refresh Programs
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.tableView addSubview:self.refreshControl];
	[self.refreshControl addTarget:self action:@selector(onPullToRefresh) forControlEvents:UIControlEventValueChanged];
	
	// setting background image
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"weeklyPrograms.png"]];
	[imageView setFrame:self.tableView.frame];
	
	self.tableView.backgroundView = imageView;
}

//- (void)viewDidLayoutSubviews
//{
//	[super viewDidLayoutSubviews];
//
//	CGRect navigationBarRect = self.navigationController.navigationBar.frame;
//	float navigationBarHeight = navigationBarRect.size.height;
//	self.tableView.contentInset = UIEdgeInsetsMake(navigationBarHeight+navigationBarRect.origin.y ,0,0,0);
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setupNavigationBar{
	// Settings bars text color to white.
	[self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];

	// following two lines makes the navigationBar transparent.
	[self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
	self.navigationController.navigationBar.shadowImage = [UIImage new];

	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"backArrowIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"arrow-refresh"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onRefresh)];
	self.navigationItem.title = @"Weekly Schedule";
}

-(void) onBack{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void) refresh{
	// remove the data from database.
	[[DBManager sharedInstance] deleteSabaPrograms:@"Weekly Programs"];
	[[DBManager sharedInstance] deleteDailyPrograms];
	
	//	// remove all the cached programs
	self.programs = nil;
	self.dailyPrograms = nil;

	// refresh the data so it can show the empty tableview and spinner.
	[self.tableView reloadData];
	
	// request for latest weekly programs.
	[self getWeeklyPrograms];
}

-(void) onRefresh{
	[[SabaClient sharedInstance] showSpinner:YES];
	[self refresh];
}

-(void) onPullToRefresh{
	[self refresh];
}

- (void)viewDidAppear:(BOOL)animated {
	//[self onRefresh];
}

#pragma mark get Events

-(void) getWeeklyPrograms{
	
	// get the program from the local database. If records are there then no need to make a network call.
	NSArray* programs = [[DBManager sharedInstance ] getSabaPrograms:@"Weekly Programs"];
	if(programs != nil && programs.count > 0){
//		Program *program = [programs objectAtIndex:0];
//		NSLog(@"%@", [program title]);
		self.programs = programs;
		[self.tableView reloadData];
		[[SabaClient sharedInstance] showSpinner:NO];
		[self.refreshControl endRefreshing];
		return;
	}
	
	[[SabaClient sharedInstance] getWeeklyPrograms:^(NSString* programName, NSArray *programs, NSError *error) {
		[[SabaClient sharedInstance] showSpinner:NO];
		[self.refreshControl endRefreshing];
		
		if (error) {
			NSLog(@"Error getting WeeklyPrograms: %@", error);
		} else {
			self.programs = [Program fromWeeklyPrograms:[WeeklyPrograms fromArray: programs]];
//			for(Program* dp in self.programs){
//				//for(Program *dp in dpArray){
//					NSLog(@"%@", [dp programDescription]);
//					NSLog(@"%@", [dp title]);
//					NSLog(@"%@", [dp imageUrl]);
//				//}
//			}
			NSLog(@"program size: %lu", (unsigned long)self.programs.count);
			[self.tableView reloadData];
			self.dailyPrograms = [WeeklyPrograms fromArray:programs];
//			NSLog(@"program size: %lu", (unsigned long)self.dailyPrograms.count);
//			for(NSArray* dpArray in self.dailyPrograms){
//				for(DailyProgram *dp in dpArray){
//					NSLog(@"%@", [dp day]);
//					NSLog(@"%@", [dp time]);
//					NSLog(@"%@", [dp englishDate]);
//					NSLog(@"%@", [dp hijriDate]);
//				}
//			}
			
			[[DBManager sharedInstance] saveSabaPrograms:self.programs :@"Weekly Programs"];
			[[DBManager sharedInstance] saveWeeklyPrograms:self.dailyPrograms];
		}
	}];
}

#pragma mark TableView

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	ProgramCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"ProgramCell" forIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[cell setProgram:self.programs[indexPath.row]];	
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	DailyProgramViewController* dpvc = [[DailyProgramViewController alloc]init];

	// extracting day from title and passing to DailyProgramViewController - Try to use delegate pattern here.
	dpvc.day = [[[self.programs[indexPath.row] title] componentsSeparatedByString:@" "] objectAtIndex:0];
	//[self.navigationController pushViewController:dsvc animated:YES]; its not working properly
	
	// very important to set the NavigationController correctly.
	UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:dpvc];
	nvc.navigationBar.translucent = YES; // so it does not hide details views
	
	[self presentViewController:nvc animated:YES completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return self.programs.count;
}

@end
