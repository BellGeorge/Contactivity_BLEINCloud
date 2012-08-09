//
//  DropPin.m
//  Advierteme
//
//  Created by SoleesMac on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DropPin.h"

@implementation DropPin
@synthesize coordinate, titleString, subTitleString, image;

- (id) initWithCoordinate: (CLLocationCoordinate2D)myCoordinate andTitle:(NSString *) myTitle andSubTitle:(NSString *)mySubTitle {
	//Copy the init values to the title and coordinate properties. 
	self = [super init];
	if (self != nil) {
		coordinate = myCoordinate;
		titleString = myTitle;
		subTitleString = mySubTitle;
	}
	return self;
}
//Title getter - returns the title string
- (NSString *) title {
	return titleString;
}
//Subtitle getter - returns a string with the annotation's coordinates
- (NSString *) subtitle; {
	//return [NSString stringWithFormat:@"%.4f, %.4f", coordinate.latitude, coordinate.longitude];
	//return [NSString stringWithFormat:@"Vasconcelos 1567 Pte. Col.Mirasierra"];
	return subTitleString;
}

- (void)dealloc {
    [image release];
    [super dealloc];
}

@end
