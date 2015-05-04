//
//  ProgramDetailViewController.m
//  SabaApp
//
//  Created by Syed Naqvi on 5/3/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "ProgramDetailViewController.h"

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

	self.programTitle.attributedText = [self getAttributedString:[self.program title] fontName:self.programTitle.font.fontName fontSize:14];

	self.programDescription.attributedText = [self getAttributedString:[self.program programDescription] fontName:self.programDescription.font.fontName fontSize:14];
}

-(NSAttributedString*) getAttributedString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size{
	string = [string stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;}</style>", name, size]];
	
	return [[NSAttributedString alloc]
			initWithData:[string dataUsingEncoding:NSUnicodeStringEncoding]
			options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
			documentAttributes:nil error:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setupNavigationBar{
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"backArrowIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
	
	self.navigationItem.title = @"Event Detail";
}

-(void) onBack{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


-(void) setProgram:(Program *)program{
	_program = program;
}

@end
