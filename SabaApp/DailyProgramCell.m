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

	NSLog(@"*********** time: %@", program.time);
	NSLog(@"===========program: %@", program.program);
	self.timeLabel.text = program.time;
	self.programLabel.text = program.program;
	
	self.timeLabel.attributedText = [[SabaClient sharedInstance] getAttributedString:[self.program time] fontName:self.timeLabel.font.fontName fontSize:14];

	self.programLabel.attributedText = [[SabaClient sharedInstance] getAttributedString:[self.program program] fontName:self.programLabel.font.fontName fontSize:14];
}

@end
