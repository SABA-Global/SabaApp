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
@property (weak, nonatomic) IBOutlet UILabel *hijriDate;
@property (weak, nonatomic) IBOutlet UILabel *englishDate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSArray *programs;
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

-(void) setupTableView{
	// tableView delegate and source
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	
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
	[self.navigationController setNavigationBarHidden:NO];
	[[SabaClient sharedInstance] setupNavigationBarFor:self];
	[self replaceTitleViewInNavigationBar];
	[self setHeaderTitle:@"ANNOUNCEMENTS" andSubtitle:[self getEnglishDate]];
}

-(void) replaceTitleViewInNavigationBar{
//	http://stackoverflow.com/questions/2817181/iphone-title-and-subtitle-in-navigation-bar
	// Replace titleView
	CGRect headerTitleSubtitleFrame = CGRectMake(0, 0, 200, 44);
	UIView* _headerTitleSubtitleView = [[UILabel alloc] initWithFrame:headerTitleSubtitleFrame];
	_headerTitleSubtitleView.backgroundColor = [UIColor clearColor];
	_headerTitleSubtitleView.autoresizesSubviews = YES;
	
	CGRect titleFrame = CGRectMake(0, 2, 200, 24);
	UILabel *titleView = [[UILabel alloc] initWithFrame:titleFrame];
	titleView.backgroundColor = [UIColor clearColor];
	[titleView setAlpha:.95f];
	titleView.font = [UIFont boldSystemFontOfSize:16];
	titleView.font = [UIFont boldSystemFontOfSize:16];
	titleView.textAlignment = NSTextAlignmentCenter;
	titleView.textColor = [UIColor whiteColor];
	titleView.shadowColor = [UIColor darkGrayColor];
	titleView.shadowOffset = CGSizeMake(0, -1);
	titleView.text = @"";
	titleView.adjustsFontSizeToFitWidth = YES;
	[_headerTitleSubtitleView addSubview:titleView];
	
	CGRect englishDateRect = CGRectMake(0, 24, 200, 44-24);
	UILabel *englishDateView = [[UILabel alloc] initWithFrame:englishDateRect];
	englishDateView.backgroundColor = [UIColor clearColor];
	[englishDateView setAlpha:.55f];
	englishDateView.font = [UIFont systemFontOfSize:13];
	englishDateView.textAlignment = NSTextAlignmentCenter;
	englishDateView.textColor = [UIColor whiteColor];
	englishDateView.shadowColor = [UIColor darkGrayColor];
	englishDateView.shadowOffset = CGSizeMake(0, -1);
	englishDateView.text = @"";
	englishDateView.adjustsFontSizeToFitWidth = YES;
	[_headerTitleSubtitleView addSubview:englishDateView];
	
	_headerTitleSubtitleView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
												 UIViewAutoresizingFlexibleRightMargin |
												 UIViewAutoresizingFlexibleTopMargin |
												 UIViewAutoresizingFlexibleBottomMargin);
	
	self.navigationItem.titleView = _headerTitleSubtitleView;
}

-(void) setHeaderTitle:(NSString*)headerTitle andSubtitle:(NSString*)headerSubtitle {
	assert(self.navigationItem.titleView != nil);
	UIView* headerTitleSubtitleView = self.navigationItem.titleView;
	UILabel* titleView = [headerTitleSubtitleView.subviews objectAtIndex:0];
	UILabel* subtitleView = [headerTitleSubtitleView.subviews objectAtIndex:1];
	assert((titleView != nil) && (subtitleView != nil) && ([titleView isKindOfClass:[UILabel class]]) && ([subtitleView isKindOfClass:[UILabel class]]));
	titleView.text = headerTitle;
	subtitleView.text = headerSubtitle;
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
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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

-(NSString*) getEnglishDate{
	
	return [NSDateFormatter localizedStringFromDate:[NSDate date]
													dateStyle:NSDateFormatterFullStyle
											        timeStyle:NSDateFormatterNoStyle];
}

@end
