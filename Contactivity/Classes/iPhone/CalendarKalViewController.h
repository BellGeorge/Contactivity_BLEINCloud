//
//  CalendarKalViewController.h
//  Contactivity
//
//  Created by Erik Solis on 5/17/12.
//  Copyright (c) 2012 Tu Mundo App. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKitUI/EventKitUI.h>

@class KalViewController;

@interface CalendarKalViewController : UIViewController <UITableViewDelegate, EKEventViewDelegate> {

    KalViewController *kal;
    id dataSource;
}

@end
