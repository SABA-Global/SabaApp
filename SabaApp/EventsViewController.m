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
#import "AppDelegate.h"
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
	
	[[SabaClient sharedInstance] showSpinner:YES];
	[self getUpcomingEvents];
	[self setupNavigationBar];
	[self setupTableView];
	[self setupRefreshControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setupTableView{
	// tableView delegate and source
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.separatorColor = [UIColor clearColor];
	
	self.tableView.estimatedRowHeight = 160.0; // Very important: when we come back from detailViewController (after dismiss) - layout of this viewController messed up. If we add this line estimatedRowHeight, its hels to keep the height and UITextView doesn't vanish.
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	
	// register cell for TableView
	[self.tableView registerNib:[UINib nibWithNibName:@"ProgramCell" bundle:nil] forCellReuseIdentifier:@"ProgramCell"];
	
	self.tableView.tableFooterView = [[UIView alloc] init];
	
	// setting background image
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"weeklyPrograms.png"]];
	[imageView setFrame:self.tableView.frame];
	
	self.tableView.backgroundView = imageView;
}

-(void) setupRefreshControl{
	// refresh Programs
	self.refreshControl = [[UIRefreshControl alloc] init];
	self.refreshControl.tintColor = RGB(106, 172, 43);
	[self.tableView addSubview:self.refreshControl];
	[self.refreshControl addTarget:self action:@selector(onPullToRefresh) forControlEvents:UIControlEventValueChanged];
}

-(void) setupNavigationBar{
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"backArrowIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
	[[SabaClient sharedInstance] setupNavigationBarFor:self];
	
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
	
	// request for latest upcoming events/programs.
	[self getUpcomingEvents];
}

-(void) onRefresh{
	[[SabaClient sharedInstance] showSpinner:YES];
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
		[[SabaClient sharedInstance] showSpinner:NO];
		return;
	}
	
	// go ahead and fetch the programs via network call.
	[[SabaClient sharedInstance] getUpcomingPrograms:^(NSString* programName, NSArray *programs, NSError *error) {
		[[SabaClient sharedInstance] showSpinner:NO];
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
	nvc.navigationBar.translucent = YES;
	[self presentViewController:nvc animated:YES completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return self.programs.count;
}
@end
