//
//  AddressAnnotation.m
//  SabaApp
//
//  Created by Syed Naqvi on 5/28/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import "CustomAnnotation.h"


@implementation CustomAnnotation

- (id) initWithTitle: (NSString*)newTitle Location:(CLLocationCoordinate2D)coord {
	self = [super init];
	if (self) {
		_coordinate = coord;
		_title = newTitle;
		_subtitle = @"4415 Fortran Ct. San Jose, CA 95134";
	}
	
	return self;
}

-(MKAnnotationView*) annotationView{
	MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"MyCustomAnnotation"];
	
	annotationView.enabled = YES;
	annotationView.canShowCallout = YES;
	annotationView.image = [UIImage imageNamed:@"green-pin"];
	
	[annotationView.layer setShadowColor:[UIColor blackColor].CGColor];
	[annotationView.layer setShadowOpacity:1.0f];
	[annotationView.layer setShadowRadius:5.0f];
	[annotationView.layer setShadowOffset:CGSizeMake(0, 0)];
//	[annotationView setBackgroundColor:[UIColor whiteColor]];
//	UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"saba_image"]]; // use saba icon
//	annotationView.leftCalloutAccessoryView = iconView;
	
//	// Add an image to the left callout.
//	UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pizza_slice_32.png"]]; // use saba icon here... or anyother prayers icon
//	annotationView.leftCalloutAccessoryView = iconView;
	
	return annotationView;
}
@end
