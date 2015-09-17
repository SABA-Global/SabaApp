//
//  WeeklyProgramsCell.m
//  SabaApp
//
//  Created by Syed Naqvi on 5/31/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "WeeklyProgramsCell.h"
#import "SabaClient.h"

@interface WeeklyProgramsCell()
@property (weak, nonatomic) IBOutlet UILabel *title;

@property (weak, nonatomic) IBOutlet UILabel *programDescription;

@property (weak, nonatomic) IBOutlet UIImageView *programImageView;
@end

@implementation WeeklyProgramsCell

- (void)awakeFromNib {
	// round image
//	self.programImageView.layer.cornerRadius = 8.0;
//	self.programImageView.clipsToBounds = YES;
	
	// Add a border
	//self.programImageview.layer.borderWidth = 1.0;
	//self.programImageview.layer.borderColor = [[UIColor yellowColor] CGColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	
	// Configure the view for the selected state
}

-(void) setProgram:(Program *)program{
	_program = program;
	NSString *day = [self getFirstWordFromString: self.program.title]; // This is the day in our case.
	[self setImageForDay:day];
	self.title.attributedText = [[SabaClient sharedInstance] getAttributedString:[self.program title] fontName:self.title.font.fontName fontSize:self.title.font.pointSize withOpacity:1.0];
	
	self.programDescription.attributedText = [[SabaClient sharedInstance] getAttributedString:[self.program programDescription] fontName:self.programDescription.font.fontName fontSize:self.programDescription.font.pointSize withOpacity:0.75];
}

-(NSString*) getFirstWordFromString:(NSString*)text{
	NSRange range = [text rangeOfString:@" "];
	if (range.location != NSNotFound) {
		return [text substringToIndex:range.location];
	}
	return nil;
}

-(void) setImageForDay:(NSString*) day{
	if(day == nil)
		return;
	
	// Currently, our icons are having the same name as of days so no need to map.
	// otherise we may need to have a dictionary to have a mapping from "Day" to Image.
	self.programImageView.image = [UIImage imageNamed:day];
}

@end
