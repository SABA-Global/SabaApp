//
//  AddressAnnotation.h
//  SabaApp
//
//  Created by Syed Naqvi on 5/28/15.
//  Copyright (c) 2015 Naqvi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CustomAnnotation : NSObject<MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;

- (id) initWithTitle: (NSString*)newTitle Location:(CLLocationCoordinate2D)coord;  //<-- add this
-(MKAnnotationView*) annotationView;
@end
