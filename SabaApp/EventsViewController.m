//
//  EventsViewController.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/26/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "EventsViewController.h"

#import "Program.h"
#import "SabaClient.h"
#import "ProgramCell.h"


#import "ProgramDetailViewController.h"

// Third party libraries
#import <SVProgressHUD.h>

@interface EventsViewController ()<UITableViewDelegate,
								   UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *programs;
@end

@implementation EventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	// setting up UITableView
	self.tableView.delegate		= self;
	self.tableView.dataSource	= self;
	
	[self getUpcomingEvents];
	[self setupNavigationBar];
	
	self.tableView.estimatedRowHeight = 160.0; // very important...
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	//self.tableView.rowHeight = 200;
	
	// register cell for TableView
	[self.tableView registerNib:[UINib nibWithNibName:@"ProgramCell" bundle:nil] forCellReuseIdentifier:@"ProgramCell"];
	
	[self showSpinner:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
	
-(void) setupNavigationBar{
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"backArrowIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
	
	self.navigationItem.title = @"Events and Announcements";
}

-(void) onBack{
	NSLog(@"Back button clicked...");
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark get Events

-(void) getUpcomingEvents{
	[[SabaClient sharedInstance] getUpcomingPrograms:^(NSString* programName, NSArray *programs, NSError *error) {
		
		[self showSpinner:NO];
		
		if (error) {
			NSLog(@"Error getting WeeklyPrograms: %@", error);
		} else {
			self.programs = [Program fromArray: programs];
			[self.tableView reloadData];
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
