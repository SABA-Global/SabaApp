//
//  ProgramDetailViewController.m
//  SabaApp
//
//  Created by Syed Naqvi on 5/3/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "DailyProgramViewController.h"


// Third party imports
@import Firebase;
//#import <Google/Analytics.h>

#import "DailyProgram.h"
#import "DailyProgramCell.h"
#import "DBManager.h"
#import "AppDelegate.h"
#import "SabaClient.h"

extern NSString *const kDailyProgramDetailsView;

@interface DailyProgramViewController ()<UITableViewDelegate,
											UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DailyProgramViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Do any additional setup after loading the view from its nib.
	self.programs = [[DBManager sharedInstance] getDailyProgramsByDay:self.day];
	//[self setupNavigationBar];
	[self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated{
//	//Provide a name for the screen and execute tracking.
//	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//	[tracker set:kGAIScreenName value:kDailyProgramDetailsView];
//	[tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void) setupTableView{
	// tableView delegate and source
	self.tableView.delegate = self;
	self.tableView.dataSource = self;

	self.tableView.estimatedRowHeight = 160.0; // Very important: when we come back from detailViewController (after dismiss) - layout of this viewController messed up. If we add this line estimatedRowHeight, its hels to keep the height and UITextView doesn't vanish.
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	
	// register cell for TableView
	[self.tableView registerNib:[UINib nibWithNibName:@"DailyProgramCell" bundle:nil] forCellReuseIdentifier:@"DailyProgramCell"];
	
	self.tableView.tableFooterView = [[UIView alloc] init];
}

-(void)setDay:(NSString *)day{
	_day = day;
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

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(void) setupNavigationBar{
	[self.navigationController setNavigationBarHidden:NO];
	[[SabaClient sharedInstance] setupNavigationBarFor:self];
	self.navigationItem.title = @"Program Details";
}

-(void) onBack{
	[self dismissViewControllerAnimated:YES completion:nil];
	//[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark TableView

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	DailyProgramCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"DailyProgramCell" forIndexPath:indexPath];
	[cell setProgram:self.programs[indexPath.row]];
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return self.programs.count;
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

@end
