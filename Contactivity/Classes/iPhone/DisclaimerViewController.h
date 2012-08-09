//
//  DisclaimerViewController.h
//  Contactivity
//
//  Created by Erik Solis on 6/21/12.
//  Copyright (c) 2012 Tu Mundo App. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageUI/MessageUI.h"

@interface DisclaimerViewController : UIViewController <MFMailComposeViewControllerDelegate> {
    UINavigationBar *navBar;
    UIImageView *imageView;
    UIScrollView *scrollView;
}

@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@end
