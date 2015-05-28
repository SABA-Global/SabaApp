//
//  EventsViewController.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/26/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "EventsViewController.h"

#import "ProgramDetailViewController.h"


#import "Program.h"
#import "SabaClient.h"
#import "ProgramCell.h"

#import "DBManager.h"

// Third party libraries
#import <SVProgressHUD.h>

@interface EventsViewController ()<UITableViewDelegate,
								   UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *programs;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation EventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	// setting up UITableView
	self.tableView.delegate		= self;
	self.tableView.dataSource	= self;
	self.tableView.separatorColor = [UIColor clearColor];
	
	[self showSpinner:YES];
	
	[self getUpcomingEvents];
	[self setupNavigationBar];
	
	self.tableView.estimatedRowHeight = 160.0; // very important...
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	//self.tableView.rowHeight = 200;
	
	// register cell for TableView
	[self.tableView registerNib:[UINib nibWithNibName:@"ProgramCell" bundle:nil] forCellReuseIdentifier:@"ProgramCell"];

	self.tableView.tableFooterView = [[UIView alloc] init];
	
	// refresh Programs
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.tableView addSubview:self.refreshControl];
	[self.refreshControl addTarget:self action:@selector(onPullToRefresh) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
	
-(void) setupNavigationBar{
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"backArrowIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"arrow-refresh"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onRefresh)];
	
	// Settings bars text color to white.
	[self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
	//set bar color
	self.navigationController.navigationBar.barTintColor = [UIColor darkGrayColor];
	
	self.navigationItem.title = @"Events and Announcements";
}

-(void) onBack{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void) refresh{
	
	// remove the data from database.
	[[DBManager sharedInstance] deleteSabaPrograms:@"Program"];
	
//	// remove all the cached programs
	self.programs = nil;
	
	// refresh the data so it can show the empty tableview and spinner.
	[self.tableView reloadData];
	[self showSpinner:YES];
	
	// request for latest upcoming events/programs.
	[self getUpcomingEvents];
}

-(void) onRefresh{
	[self showSpinner:YES];
	[self refresh];
}

-(void) onPullToRefresh{
	[self refresh];
}


#pragma mark get Events

-(void) getUpcomingEvents{
	// get the program from the local database. If records are there then no need to make a network call.
	NSArray* programs = [[DBManager sharedInstance ] getSabaPrograms:@"Program"];
	if(programs != nil && programs.count > 0){
		self.programs = programs;
		[self.tableView reloadData];
		[self showSpinner:NO];
		return;
	}
	
	// go ahead and fetch the programs via network call.
	[[SabaClient sharedInstance] getUpcomingPrograms:^(NSString* programName, NSArray *programs, NSError *error) {
		[self showSpinner:NO];
		[self.refreshControl endRefreshing];
		
		if (error) {
			NSLog(@"Error getting WeeklyPrograms: %@", error);
		} else {
			self.programs = [Program fromArray: programs];
			[self.tableView reloadData];
			
			[[DBManager sharedInstance] saveSabaPrograms:self.programs :@"Program"];
		}
	}];
}

#pragma mark TableView

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	ProgramCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"ProgramCell" forIndexPath:indexPath];
	[cell setProgram:self.programs[indexPath.row]];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	ProgramDetailViewController* pdvc = [[ProgramDetailViewController alloc]init];
	pdvc.program = self.programs[indexPath.row];
	
	// very important to set the NavigationController correctly.
	UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:pdvc];
	nvc.navigationBar.translucent = NO; // so it does not hide details views
	[self presentViewController:nvc animated:YES completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return self.programs.count;
}

#pragma mark spinner

-(void) showSpinner:(bool)show{
	if(show == YES){
		[SVProgressHUD setRingThickness:1.0];
		CAShapeLayer* layer = [[SVProgressHUD sharedView]backgroundRingLayer];
		layer.opacity = 0;
		layer.allowsGroupOpacity = YES;
		[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
	}
	else
		[SVProgressHUD dismiss];
}
@end
