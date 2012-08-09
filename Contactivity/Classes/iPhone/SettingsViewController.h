//
//  SettingsViewController.h
//  Contactivity
//
//  Created by Erik Solis on 4/17/12.
//  Copyright (c) 2012 Tu Mundo App. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"
#import "MessageUI/MessageUI.h"
#import "Twitter/TWTweetComposeViewController.h"
#import "DisclaimerViewController.h"

@interface SettingsViewController : UIViewController <SFRestDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate> {

    UITextField *email;
    NSMutableArray *listaQuery;
    NSString *objeto;
    NSMutableArray *listaObjeto;
    UIAlertView *baseAlert;
    BOOL _reloadWithAlert;
    UIView *scrollSpaceView;
    UIScrollView *scrollView;
    UITextView *description;
    UISwitch *switchUploadEvent;
    UISwitch *switchAddCc;
    UISwitch *switchTipMessage;
    UISwitch *switchMulticurrency;
    UISwitch *switchContactsIOwn;
    UISwitch *switchLeadsIOwn;
    UISwitch *switchOpportunitiesIOwn;
    UIImageView *bgView1;
    UIImageView *bgView2;
    UIImageView *bgView3;
    UIImageView *bgView4;
    UIImageView *bgView5;
    UIImageView *bgView6;
    UIImageView *bgView7;
    UINavigationBar *navBar;
    UIToolbar *toolBar;
}

@property (nonatomic, retain) IBOutlet UITextField *email;
@property (nonatomic, retain) NSArray *listaQuery;
@property (nonatomic, retain) NSString *objeto;
@property (nonatomic, retain) NSArray *listaObjeto;
@property (nonatomic, retain) IBOutlet UIView *scrollSpaceView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UITextView *description;
@property (nonatomic, retain) IBOutlet UISwitch *switchUploadEvent;
@property (nonatomic, retain) IBOutlet UISwitch *switchAddCc;
@property (nonatomic, retain) IBOutlet UISwitch *switchTipMessage;
@property (nonatomic, retain) IBOutlet UISwitch *switchMulticurrency;
@property (nonatomic, retain) IBOutlet UISwitch *switchContactsIOwn;
@property (nonatomic, retain) IBOutlet UISwitch *switchLeadsIOwn;
@property (nonatomic, retain) IBOutlet UISwitch *switchOpportunitiesIOwn;
@property (nonatomic, retain) IBOutlet UIImageView *bgView1;
@property (nonatomic, retain) IBOutlet UIImageView *bgView2;
@property (nonatomic, retain) IBOutlet UIImageView *bgView3;
@property (nonatomic, retain) IBOutlet UIImageView *bgView4;
@property (nonatomic, retain) IBOutlet UIImageView *bgView5;
@property (nonatomic, retain) IBOutlet UIImageView *bgView6;
@property (nonatomic, retain) IBOutlet UIImageView *bgView7;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;

- (void)readFromSalesforce:(NSString*)Object;
- (IBAction)downloadEmail:(id)sender;
- (IBAction)deleteEmail:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)switchChanged:(id)sender;
- (IBAction)sendTweet:(id)sender;

@end
