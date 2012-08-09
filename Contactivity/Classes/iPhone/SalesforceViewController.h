//
//  SalesforceViewController.h
//  Contactivity
//
//  Created by Erik Solis on 4/10/12.
//  Copyright (c) 2012 Tu Mundo App. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFRestAPI.h"
#import "EGORefreshTableHeaderView.h"
#import "CustomCell.h"
#import "OpportunityCell.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "AddressBook/ABAddressBook.h"
#import <AddressBookUI/AddressBookUI.h>
#import "SettingsViewController.h"
#import "MessageUI/MessageUI.h"

@interface SalesforceViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,SFRestDelegate,UISearchBarDelegate,UISearchDisplayDelegate, UIGestureRecognizerDelegate, EGORefreshTableHeaderDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, EKEventEditViewDelegate, UIWebViewDelegate> {
    
    UITableView *tableview;
    NSMutableArray *lista;
    NSMutableArray *listaQuery;
    NSString *objeto;
    NSMutableArray *listaObjeto;
    NSMutableArray *listaContacto;
    NSString *titulo;
    NSString *origen;
    NSString *opportunity;
    UIAlertView *baseAlert;
    NSMutableArray *listaFiltered;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    BOOL _reloadWithAlert;
    UIActionSheet *popoverActionsheet;
    EKEventStore *eventStore;
	EKCalendar *defaultCalendar;
    NSDate *callDate;
    NSString *shouldReturn;
    NSString *accountId;
    UIView *tipMessageView;
    UILabel *tipMessage;
    NSMutableArray *listaTips;
    BOOL _tipShowing;
}

@property (nonatomic, retain) IBOutlet UITableView *tableview;
@property (nonatomic, retain) NSArray *lista;
@property (nonatomic, retain) NSArray *listaQuery;
@property (nonatomic, retain) NSString *objeto;
@property (nonatomic, retain) NSArray *listaObjeto;
@property (nonatomic, retain) NSArray *listaContacto;
@property (nonatomic, retain) NSString *titulo;
@property (nonatomic, retain) NSString *origen;
@property (nonatomic, retain) NSString *opportunity;
@property (nonatomic, retain) NSArray *listaFiltered;
@property (nonatomic, retain) UIActionSheet *popoverActionsheet;
@property (nonatomic, retain) EKEventStore *eventStore;
@property (nonatomic, retain) EKCalendar *defaultCalendar;
@property (nonatomic, retain) NSDate *callDate;
@property (nonatomic, retain) NSString *shouldReturn;
@property (nonatomic, retain) NSString *accountId;
@property (nonatomic, retain) IBOutlet UIView *tipMessageView;
@property (nonatomic, retain) IBOutlet UILabel *tipMessage;
@property (nonatomic, retain) NSArray *listaTips;

- (void)readFromSalesforce:(NSString*)Object;
- (void)showOptions;
- (void)sendMail:(NSString *)email;
- (void)createEvent:(NSString *)contactName Phone:(NSString *)contactPhone Address:(NSString *)contactAddress Email:(NSString*)contactEmail;
- (void)readFromAddressBook:(NSString *)viewDidLoad;
- (void)saveEventToSalesforce:(EKEvent*)event ContactId:(NSString*)contactId;
- (void)makeCall:(NSString *)telephone;
- (void)logCall;
- (void)logFacetimeCall;
- (void)logSkypeCall;
- (void)saveCallTaskToSalesforce:(NSDate*)date ContactId:(NSString*)contactId ContactName:(NSString*)contactName ContactPhone:(NSString*)contactPhone;
- (void)saveFacetimeCallTaskToSalesforce:(NSDate*)date ContactId:(NSString*)contactId ContactName:(NSString*)contactName ContactEmail:(NSString*)contactEmail;
- (void)saveSkypeCallTaskToSalesforce:(NSDate*)date ContactId:(NSString*)contactId ContactName:(NSString*)contactName ContactPhone:(NSString*)contactPhone;
- (NSString*)cleanTelephone:(NSString*)telephone;
- (NSString*)cleanEmail:(NSString*)email;
- (IBAction)showSettings:(id)sender;
- (void)loadTip;
- (void)closeTip;
- (void)customSearchBars;

@end
