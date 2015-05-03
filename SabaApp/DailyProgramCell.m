//
//  DailyProgramCell.m
//  SabaApp
//
//  Created by Syed Naqvi on 5/3/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "DailyProgramCell.h"


@interface DailyProgramCell()
@property (weak, nonatomic) IBOutlet UILabel *programLabel;

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
	
	NSMutableString* text = [program.time mutableCopy];
	[text appendString: @" "];
	[text appendString:[program program]];
	
	 self.programLabel.text = text;
	
//	self.programDescription.attributedText = [self getAttributedString:[self.program programDescription] fontName:self.programDescription.font.fontName fontSize:12];
}


@end
