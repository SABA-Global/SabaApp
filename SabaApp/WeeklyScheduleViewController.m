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
#import "WeeklyProgramsCell.h"
#import "DBManager.h"
#import "AppDelegate.h"

#import "DailyProgramViewController.h"

#import <Google/Analytics.h>

NSString *const kWeeklySchedule		= @"Weekly Schedule";
NSString *const kRefreshButton		= @"Refresh Clicked";
NSString *const kPullToRefresh		= @"Pull to Refresh";

@interface WeeklyScheduleViewController ()<UITableViewDelegate,
											UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *programs;
@property (strong, nonatomic) NSArray *dailyPrograms;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property bool isRefreshInProgress; // keeps track that if refresh is in Progress. Another refresh should not kick in at the sametime.

@end

@implementation WeeklyScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	[[SabaClient sharedInstance] showSpinner:YES];
	[self getWeeklyPrograms];
	[self setupNavigationBar];
	[self setupTableView];
	[self setupRefreshControl];
	self.isRefreshInProgress=false;
}

- (void)viewWillAppear:(BOOL)animated{
	//Provide a name for the screen and execute tracking.
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	[tracker set:kGAIScreenName value:kWeeklySchedule];
	[tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void)viewDidLayoutSubviews
{
	// helps to show the full width line separators in tableView.
	//http://stackoverflow.com/questions/26519248/how-to-set-the-full-width-of-separator-in-uitableview
	if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
		[self.tableView setSeparatorInset:UIEdgeInsetsZero];
	}
	
	if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
		[self.tableView setLayoutMargins:UIEdgeInsetsZero];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setupTableView{
	// tableView delegate and source
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	
	self.tableView.estimatedRowHeight = 120.0; // Very important: when we come back from detailViewController (after dismiss) - layout of this viewController messed up. If we add this line estimatedRowHeight, its hels to keep the height and UITextView doesn't vanish.
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	
	// register cell for TableView
	[self.tableView registerNib:[UINib nibWithNibName:@"WeeklyProgramsCell" bundle:nil] forCellReuseIdentifier:@"WeeklyProgramsCell"];
	
	self.tableView.tableFooterView = [[UIView alloc] init];	
}

-(void) setupRefreshControl{
	// refresh Programs
	self.refreshControl = [[UIRefreshControl alloc] init];
	self.refreshControl.tintColor = [UIColor whiteColor];
	[self.tableView addSubview:self.refreshControl];
	[self.refreshControl addTarget:self action:@selector(onPullToRefresh) forControlEvents:UIControlEventValueChanged];
}

-(void) setupNavigationBar{
	[self.navigationController setNavigationBarHidden:NO];
	[[SabaClient sharedInstance] setupNavigationBarFor:self];
	
	// Use standard refresh button.
	UIBarButtonItem *refreshBarButtonItem = [[UIBarButtonItem alloc]
											 initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
											 target:self
											 action:@selector(onRefresh)];
	self.navigationItem.rightBarButtonItem = refreshBarButtonItem;
	
	self.navigationItem.title = @"Weekly Schedule";
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
	if (![parent isEqual:self.parentViewController]) {
		[UIView  beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:NO];
		[UIView commitAnimations];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDelay:0.3];
		[UIView commitAnimations];	}
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
	if(self.isRefreshInProgress)
		return;
	
	[self trackRefreshWithRefreshType:kRefreshButton];
	self.isRefreshInProgress = true;
	[[SabaClient sharedInstance] showSpinner:YES];
	[self refresh];
}

-(void) onPullToRefresh{
	[self trackRefreshWithRefreshType:kPullToRefresh];
	self.isRefreshInProgress = true;
	[self refresh];
}

- (void)viewDidAppear:(BOOL)animated {
	self.navigationController.navigationBar.topItem.title = @"Weekly Schedule"; // sets empty on "<" button.
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
		self.isRefreshInProgress=false;
		
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
	
	WeeklyProgramsCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"WeeklyProgramsCell" forIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	// This is how you change the background color. We might have better sol.
	UIView *bgColorView = [[UIView alloc] init];
	bgColorView.backgroundColor = [UIColor grayColor];
	[cell setSelectedBackgroundView:bgColorView];
	
	[cell setProgram:self.programs[indexPath.row]];	
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	DailyProgramViewController* dpvc = [[DailyProgramViewController alloc]init];

	// extracting day from title and passing to DailyProgramViewController - Try to use delegate pattern here.
	dpvc.day = [[[self.programs[indexPath.row] title] componentsSeparatedByString:@" "] objectAtIndex:0];

	
	CATransition *transition = [CATransition animation];
	transition.duration = 0.2;
	transition.type = kCATransitionPush;
	transition.subtype = kCATransitionFromRight;
	
	self.navigationController.navigationBar.topItem.title = @""; // sets empty on "<" button.
	[self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
	[self.navigationController pushViewController:dpvc animated:NO];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return self.programs.count;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	//http://stackoverflow.com/questions/26519248/how-to-set-the-full-width-of-separator-in-uitableview
	// helps to show the full width line separators in tableView.
	if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
		[cell setSeparatorInset:UIEdgeInsetsZero];
	}
	
	if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
		[cell setLayoutMargins:UIEdgeInsetsZero];
	}
}

#pragma mark - Analytics

// we might add pull to refresh later on.
- (void)trackRefreshWithRefreshType:(NSString*) refrehType{
	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
	
	// Create events to track the selected image and selected name.
	[tracker send:[[GAIDictionaryBuilder createEventWithCategory:kWeeklySchedule
														  action:refrehType
														   label:refrehType
														   value:nil] build]];
}

@end
