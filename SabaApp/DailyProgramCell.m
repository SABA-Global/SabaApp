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

	self.timeLabel.text = program.time;
	self.programLabel.text = program.program;
	
	self.timeLabel.attributedText = [self getAttributedString:[self.program time] fontName:self.timeLabel.font.fontName fontSize:14];

	self.programLabel.attributedText = [self getAttributedString:[self.program program] fontName:self.programLabel.font.fontName fontSize:14];
}

-(NSAttributedString*) getAttributedString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size{
	string = [string stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;}</style>", name, size]];
	
	return [[NSAttributedString alloc]
			initWithData:[string dataUsingEncoding:NSUnicodeStringEncoding]
			options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
			documentAttributes:nil error:nil];
	
}

@end
