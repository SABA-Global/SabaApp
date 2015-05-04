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

#import "SabaClient.h"

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
	self.title.attributedText = [[SabaClient sharedInstance] getAttributedString:[self.program title] fontName:self.title.font.fontName fontSize:12];

	self.programDescription.attributedText = [[SabaClient sharedInstance] getAttributedString:[self.program programDescription] fontName:self.programDescription.font.fontName fontSize:12];
}
@end
