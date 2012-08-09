//
//  DropPin.h
//  Advierteme
//
//  Created by SoleesMac on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mapkit/Mapkit.h>

@interface DropPin : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString *titleString;
	NSString *subTitleString;
    UIImage *image;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *titleString;
@property (nonatomic, retain) NSString *subTitleString;
@property (nonatomic, retain) UIImage *image;

- (id) initWithCoordinate: (CLLocationCoordinate2D)coordinate andTitle:(NSString *)myTitle andSubTitle:(NSString *)mySubTitle;

- (NSString *) title;
- (NSString *) subtitle;
		   
@end
