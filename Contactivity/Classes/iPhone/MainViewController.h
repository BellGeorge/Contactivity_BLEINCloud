//
//  MainViewController.h
//  Contactivity
//
//  Created by Erik Solis on 4/10/12.
//  Copyright (c) 2012 Tu Mundo App. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalendarKalViewController.h"
#import "SalesforceViewController.h"
#import "SettingsViewController.h"

@interface MainViewController : UIViewController <UIApplicationDelegate, UITabBarControllerDelegate> {
    CalendarKalViewController *vc1;
    SalesforceViewController *vc2;
    SalesforceViewController *vc3;
    SalesforceViewController *vc4;
    SalesforceViewController *vc5;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) UINavigationBar *navBar;
@property (nonatomic, retain) CalendarKalViewController *vc1;
@property (nonatomic, retain) SalesforceViewController *vc2;
@property (nonatomic, retain) SalesforceViewController *vc3;
@property (nonatomic, retain) SalesforceViewController *vc4;
@property (nonatomic, retain) SalesforceViewController *vc5;

@end
