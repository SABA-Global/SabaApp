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


#import "DailyProgramViewController.H"

@interface WeeklyScheduleViewController ()<UITableViewDelegate,
											UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *programs;
@property (strong, nonatomic) NSArray *dailyPrograms;

@end

@implementation WeeklyScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	// tableView delegate and source
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	
	[self getWeeklyPrograms];
	[self setupNavigationBar];
	
	self.tableView.estimatedRowHeight = 160.0; // Very important: when we come back from detailViewController (after dismiss) - layout of this viewController messed up. If we add this line estimatedRowHeight, its hels to keep the height and UITextView doesn't vanish.
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	
	// register cell for TableView
	[self.tableView registerNib:[UINib nibWithNibName:@"ProgramCell" bundle:nil] forCellReuseIdentifier:@"ProgramCell"];
	
	[self showSpinner:YES];
	
	self.tableView.tableFooterView = [[UIView alloc] init];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setupNavigationBar{
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"backArrowIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
	
	self.navigationItem.title = @"Weekly Schedule";
}

-(void) onBack{
	NSLog(@"Back button clicked...");
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	//[self.tableView reloadData];
	[self.view layoutIfNeeded];
}

#pragma mark get Events

-(void) getWeeklyPrograms{
	[[SabaClient sharedInstance] getWeeklyPrograms:^(NSString* programName, NSArray *programs, NSError *error) {
		[self showSpinner:NO];
		if (error) {
			NSLog(@"Error getting WeeklyPrograms: %@", error);
		} else {
			self.programs = [Program fromWeeklyPrograms:[WeeklyPrograms fromArray: programs]];
			[self.tableView reloadData];
			self.dailyPrograms = [WeeklyPrograms fromArray:programs];
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
	dpvc.programs = self.dailyPrograms[indexPath.row];
	//[self.navigationController pushViewController:dsvc animated:YES]; its not working properly
	
	// very important to set the NavigationController correctly.
	UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:dpvc];
	nvc.navigationBar.translucent = NO; // so it does not hide details views
	
	[self presentViewController:nvc animated:YES completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return self.programs.count;
}

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
