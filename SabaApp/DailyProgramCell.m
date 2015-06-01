//
//  DailyProgramCell.m
//  SabaApp
//
//  Created by Syed Naqvi on 5/3/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "DailyProgramCell.h"
#import "SabaClient.h"

@interface DailyProgramCell()
@property (weak, nonatomic) IBOutlet UILabel *programLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation DailyProgramCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setProgram:(DailyProgram *)program{
	_program = program;

	if( ([program.time length] == 0) && ([program.program length] ==0) ){
		// formatting title as "Day Moth Day / Islamic Month day" e.g.
		// "Saturday May 23 / Shaban 4"
		NSString *title = program.day;
		title = [title stringByAppendingString:@" "];
		title = [title stringByAppendingString:program.englishDate];
		title = [title stringByAppendingString:@" / "];
		title = [title stringByAppendingString:program.hijriDate];
		
		// setting bold font
		[self.programLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
		[self.programLabel setAlpha:.75];
		[self.programLabel setTextColor:[UIColor whiteColor]];// first row in DailyProgramViewController
		self.programLabel.text = title;
		self.timeLabel.text = program.time;
		
		return;
	}
	
	self.timeLabel.text = program.time;
	self.programLabel.text = program.program;
	
	self.timeLabel.attributedText = [[SabaClient sharedInstance] getAttributedString:[self.program time] fontName:self.timeLabel.font.fontName fontSize:self.timeLabel.font.pointSize withOpacity:0.70];

	self.programLabel.attributedText = [[SabaClient sharedInstance] getAttributedString:[self.program program] fontName:self.programLabel.font.fontName fontSize:self.programLabel.font.pointSize withOpacity:0.50];
}

@end
