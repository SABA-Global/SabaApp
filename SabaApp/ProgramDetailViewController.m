//
//  ProgramDetailViewController.m
//  SabaApp
//
//  Created by Syed Naqvi on 5/3/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "ProgramDetailViewController.h"

#import "SabaClient.h"
#import "AppDelegate.h"

@interface ProgramDetailViewController ()
//http://stackoverflow.com/questions/10784207/uilabel-copywithzone-unrecognized-selector-sent-to-instance
// changed to programTitle.... title was causing the issue here....
@property (weak, nonatomic) IBOutlet UILabel *programTitle;
@property (weak, nonatomic) IBOutlet UITextView *programDescription;

@end

@implementation ProgramDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	self.programTitle.text = self.program.title;
	self.programDescription.text = self.program.programDescription;
	
	[self setupNavigationBar];

	self.programTitle.attributedText = [[SabaClient sharedInstance] getAttributedString:[self.program title] fontName:self.programTitle.font.fontName fontSize:self.programTitle.font.pointSize];

	self.programDescription.attributedText = [[SabaClient sharedInstance] getAttributedString:[self.program programDescription] fontName:self.programDescription.font.fontName fontSize:self.programDescription.font.pointSize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setupNavigationBar{
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"backArrowIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
	
	[[SabaClient sharedInstance] setupNavigationBarFor:self];
	self.navigationItem.title = @"Event Detail";
}

-(void) onBack{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void) setProgram:(Program *)program{
	_program = program;
}
@end
