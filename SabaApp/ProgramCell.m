//
//  ProgramCell.m
//  SabaApp
//
//  Created by Syed Naqvi on 4/29/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "ProgramCell.h"

// Third party libraries
#import "UIImageView+AFNetworking.h"

@interface ProgramCell()

@property (weak, nonatomic) IBOutlet UITextView *title;
@property (weak, nonatomic) IBOutlet UILabel *programDescription;
@property (weak, nonatomic) IBOutlet UIImageView *programImageview;
@end

@implementation ProgramCell

- (void)awakeFromNib {
	
	// round image
	self.programImageview.layer.cornerRadius = 8.0;
	self.programImageview.clipsToBounds = YES;

	// You can even add a border
	self.programImageview.layer.borderWidth = 1.0;
	self.programImageview.layer.borderColor = [[UIColor yellowColor] CGColor];
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setProgram:(Program *)program{
	
//	// rounded corners for profile images
//	CALayer *layer = [self.programImageview layer];
//	[layer setMasksToBounds:YES];
//	[layer setCornerRadius:8.0];
//	
//	// You can even add a border
//	[layer setBorderWidth:1.0];
//	[layer setBorderColor:[[UIColor yellowColor] CGColor]];
	
	
	_program = program;
	NSString *imageUrl = [program imageUrl];
	[self.programImageview setImageWithURLRequest:
	 [NSURLRequest requestWithURL:[NSURL URLWithString: imageUrl]] placeholderImage:nil
			  success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
				  [self.programImageview setImage:image];
			  }
			  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
				  NSLog(@"failed loading: %@", error);
			  }
	 
	 ];
	self.title.attributedText = [self getAttributedString:[self.program title] fontName:self.title.font.fontName fontSize:12];

	self.programDescription.attributedText = [self getAttributedString:[self.program programDescription] fontName:self.programDescription.font.fontName fontSize:12];
}

-(NSAttributedString*) getAttributedString:(NSString*)string fontName:(NSString*)name fontSize:(CGFloat)size{
	string = [string stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;}</style>", name, size]];
	
	return [[NSAttributedString alloc]
			initWithData:[string dataUsingEncoding:NSUnicodeStringEncoding]
			options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
			documentAttributes:nil error:nil];
	
}

-(void) setWeeklyProgram:(DailyProgram*) dailyProgram{
	//[Program fromWeeklyPrograms:
}

@end
