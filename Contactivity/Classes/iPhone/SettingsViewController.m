//
//  SettingsViewController.m
//  Contactivity
//
//  Created by Erik Solis on 4/17/12.
//  Copyright (c) 2012 Tu Mundo App. All rights reserved.
//

#import "SettingsViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "KeychainWrapper.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize email, listaQuery, objeto, listaObjeto, description, scrollSpaceView, scrollView, switchUploadEvent, switchAddCc, switchTipMessage, switchMulticurrency, switchContactsIOwn, switchLeadsIOwn, switchOpportunitiesIOwn, bgView1, bgView2, bgView3, bgView4, bgView5, bgView6, bgView7, navBar, toolBar;

- (void)dealloc {
    [email release];
    self.listaQuery = nil;
    [objeto release];
    self.listaObjeto = nil;
    [description release];
    [switchUploadEvent release];
    [switchAddCc release];
    [switchTipMessage release];
    [switchContactsIOwn release];
    [switchLeadsIOwn release];
    [switchOpportunitiesIOwn release];
    [navBar release];
    [toolBar release];
    [super dealloc];
}

- (void) performDismissAlert {
	[baseAlert dismissWithClickedButtonIndex:0 animated:NO];
}

- (IBAction)done:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // LE PONEMOS COLOR A LA TABLA
    self.view.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
    
    // Appereance
    UIImage *topBGImage = [UIImage imageNamed:@"headerBar.png"];
    UIImage *bottomBGImage = [UIImage imageNamed:@"barraInferior.png"];
    [self.navBar setBackgroundImage:topBGImage forBarMetrics:UIBarMetricsDefault];
    [self.toolBar setBackgroundImage:bottomBGImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    UIImage *titleImage = [UIImage imageNamed:@"logoSuperiorDeriPhone.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:titleImage];
    [imageView setFrame:CGRectMake( self.view.bounds.size.width - imageView.bounds.size.width , 0, 59, 44)];
    [self.navigationController.navigationBar addSubview:imageView];
    [imageView release];
    
    NSArray *buttons = [self.navBar subviews];
    for (NSObject *object in buttons) {
        if ([object isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)object;
            if ([[button currentTitle] isEqualToString:@"Cancel"] || [[button currentTitle] isEqualToString:@"Cancelar"]) {
                [button setTintColor:[UIColor colorWithRed:10.0f/255.0f green:30.0f/255.0f blue:81.0f/255.0f alpha:1.0f]];
            } else if ([[button currentTitle] isEqualToString:@"New Case"] || [[button currentTitle] isEqualToString:@"Nuevo Caso"]) {
                [button setTintColor:[UIColor colorWithRed:10.0f/255.0f green:30.0f/255.0f blue:81.0f/255.0f alpha:1.0f]];
            } else if ([[button currentTitle] isEqualToString:@"Exit"] || [[button currentTitle] isEqualToString:@"Salir"]) {
                [button setTintColor:[UIColor colorWithRed:10.0f/255.0f green:30.0f/255.0f blue:81.0f/255.0f alpha:1.0f]];
            }
        }
    }
    
    // Inicializamos el scroll
    CGRect scrollFrame;
	scrollFrame.origin.x = 0;
	scrollFrame.origin.y = 0;
	scrollFrame.size.width = self.scrollView.bounds.size.width;
    scrollFrame.size.height = self.scrollView.bounds.size.height + 140;
    [scrollView setContentSize:scrollFrame.size];
    [scrollView setBounces:YES];
    [self.scrollSpaceView addSubview:scrollView];
    
    // Bordes
    self.bgView1.layer.borderWidth = 1;
    self.bgView1.layer.borderColor = [[UIColor grayColor] CGColor];
    self.bgView1.layer.cornerRadius = 10;
    self.bgView2.layer.borderWidth = 1;
    self.bgView2.layer.borderColor = [[UIColor grayColor] CGColor];
    self.bgView2.layer.cornerRadius = 10;
    self.bgView3.layer.borderWidth = 1;
    self.bgView3.layer.borderColor = [[UIColor grayColor] CGColor];
    self.bgView3.layer.cornerRadius = 10;
    self.bgView4.layer.borderWidth = 1;
    self.bgView4.layer.borderColor = [[UIColor grayColor] CGColor];
    self.bgView4.layer.cornerRadius = 10;
    self.bgView5.layer.borderWidth = 1;
    self.bgView5.layer.borderColor = [[UIColor grayColor] CGColor];
    self.bgView5.layer.cornerRadius = 10;
    self.bgView6.layer.borderWidth = 1;
    self.bgView6.layer.borderColor = [[UIColor grayColor] CGColor];
    self.bgView6.layer.cornerRadius = 10;
    self.bgView7.layer.borderWidth = 1;
    self.bgView7.layer.borderColor = [[UIColor grayColor] CGColor];
    self.bgView7.layer.cornerRadius = 10;
    
    // INICIALIZAMOS
    listaQuery = [[NSMutableArray alloc] init];
    listaObjeto = [[NSMutableArray alloc] init];
    objeto = [NSString stringWithFormat:@"EmailServicesAddress"];
         
    // Prendemos el subir eventos
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"kUploadEventId"] != NULL) {
        ([[userDefaults stringForKey:@"kUploadEventId"] isEqualToString:@"SI"]) ? [switchUploadEvent setOn:YES] : [switchUploadEvent setOn:NO];
    } else {
        [switchUploadEvent setOn:NO];
    }

    // Prendemos el agregar Cc
    if ([userDefaults objectForKey:@"kAddCcId"] != NULL) {
        ([[userDefaults stringForKey:@"kAddCcId"] isEqualToString:@"SI"]) ? [switchAddCc setOn:YES] : [switchAddCc setOn:NO];
    } else {
        [switchAddCc setOn:NO];
    }

    // MOSTRAMOS EL VALOR DE EMAIL
    [email setText:[NSString stringWithFormat:@"%@", [KeychainWrapper searchKeychain:@"kEmailId"]]];
    
    // PRENDEMOS EL MOSTRAR MENSAJES DE AYUDA
    if ([userDefaults objectForKey:@"kTipMessage"] != NULL) {
        ([[userDefaults stringForKey:@"kTipMessage"] isEqualToString:@"SI"]) ? [switchTipMessage setOn:YES] : [switchTipMessage setOn:NO];
    } else {
        [switchTipMessage setOn:YES];
    }
    
    // PRENDEMOS EL MULTICURRENCY
    if ([userDefaults objectForKey:@"kMulticurrency"] != NULL) {
        ([[userDefaults stringForKey:@"kMulticurrency"] isEqualToString:@"SI"]) ? [switchMulticurrency setOn:YES] : [switchMulticurrency setOn:NO];
    } else {
        [switchMulticurrency setOn:NO];
    }
    
    // PRENDEMOS EL CONTACTS I OWN
    if ([userDefaults objectForKey:@"kContactsIOwn"] != NULL) {
        ([[userDefaults stringForKey:@"kContactsIOwn"] isEqualToString:@"SI"]) ? [switchContactsIOwn setOn:YES] : [switchContactsIOwn setOn:NO];
    } else {
        [switchContactsIOwn setOn:NO];
    }
    
    // PRENDEMOS EL LEADS I OWN
    if ([userDefaults objectForKey:@"kLeadsIOwn"] != NULL) {
        ([[userDefaults stringForKey:@"kLeadsIOwn"] isEqualToString:@"SI"]) ? [switchLeadsIOwn setOn:YES] : [switchLeadsIOwn setOn:NO];
    } else {
        [switchLeadsIOwn setOn:NO];
    }

    // PRENDEMOS EL OPPORTUNITIES I OWN
    if ([userDefaults objectForKey:@"kOpportunitiesIOwn"] != NULL) {
        ([[userDefaults stringForKey:@"kOpportunitiesIOwn"] isEqualToString:@"SI"]) ? [switchOpportunitiesIOwn setOn:YES] : [switchOpportunitiesIOwn setOn:NO];
    } else {
        [switchOpportunitiesIOwn setOn:NO];
    }

}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // GUARDAMOS VALORES DE LOS SWITCHES
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([switchUploadEvent isOn]) {
        [userDefaults setObject:@"SI" forKey:@"kUploadEventId"];
    } else {
        [userDefaults setObject:@"NO" forKey:@"kUploadEventId"];
    }
    
    if ([switchAddCc isOn]) {
        [userDefaults setObject:@"SI" forKey:@"kAddCcId"];
    } else {
        [userDefaults setObject:@"NO" forKey:@"kAddCcId"];
    }
    
    if ([switchTipMessage isOn]) {
        [userDefaults setObject:@"SI" forKey:@"kTipMessage"];
    } else {
        [userDefaults setObject:@"NO" forKey:@"kTipMessage"];
    }
    
    if ([switchMulticurrency isOn]) {
        [userDefaults setObject:@"SI" forKey:@"kMulticurrency"];
    } else {
        [userDefaults setObject:@"NO" forKey:@"kMulticurrency"];
    }

    if ([switchContactsIOwn isOn]) {
        [userDefaults setObject:@"SI" forKey:@"kContactsIOwn"];
    } else {
        [userDefaults setObject:@"NO" forKey:@"kContactsIOwn"];
    }

    if ([switchLeadsIOwn isOn]) {
        [userDefaults setObject:@"SI" forKey:@"kLeadsIOwn"];
    } else {
        [userDefaults setObject:@"NO" forKey:@"kLeadsIOwn"];
    }

    if ([switchOpportunitiesIOwn isOn]) {
        [userDefaults setObject:@"SI" forKey:@"kOpportunitiesIOwn"];
    } else {
        [userDefaults setObject:@"NO" forKey:@"kOpportunitiesIOwn"];
    }

    // Release any retained subviews of the main view.
    self.bgView1 = nil;
    self.bgView2 = nil;
    self.bgView3 = nil;
    self.bgView4 = nil;
    self.bgView5 = nil;
    self.bgView6 = nil;
    self.bgView7 = nil;
    self.scrollView = nil;
    self.scrollSpaceView = nil;
}

- (void)viewDidDisappear:(BOOL)animated {

    // GUARDAMOS VALORES DE LOS SWITCHES
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([switchUploadEvent isOn]) {
        [userDefaults setObject:@"SI" forKey:@"kUploadEventId"];
    } else {
        [userDefaults setObject:@"NO" forKey:@"kUploadEventId"];
    }
    
    if ([switchAddCc isOn]) {
        [userDefaults setObject:@"SI" forKey:@"kAddCcId"];
    } else {
        [userDefaults setObject:@"NO" forKey:@"kAddCcId"];
    }
    
    if ([switchTipMessage isOn]) {
        [userDefaults setObject:@"SI" forKey:@"kTipMessage"];
    } else {
        [userDefaults setObject:@"NO" forKey:@"kTipMessage"];
    }
    
    if ([switchMulticurrency isOn]) {
        [userDefaults setObject:@"SI" forKey:@"kMulticurrency"];
    } else {
        [userDefaults setObject:@"NO" forKey:@"kMulticurrency"];
    }
    
    if ([switchContactsIOwn isOn]) {
        [userDefaults setObject:@"SI" forKey:@"kContactsIOwn"];
    } else {
        [userDefaults setObject:@"NO" forKey:@"kContactsIOwn"];
    }
    
    if ([switchLeadsIOwn isOn]) {
        [userDefaults setObject:@"SI" forKey:@"kLeadsIOwn"];
    } else {
        [userDefaults setObject:@"NO" forKey:@"kLeadsIOwn"];
    }
    
    if ([switchOpportunitiesIOwn isOn]) {
        [userDefaults setObject:@"SI" forKey:@"kOpportunitiesIOwn"];
    } else {
        [userDefaults setObject:@"NO" forKey:@"kOpportunitiesIOwn"];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (void)readFromSalesforce:(NSString*)Object {
    
    [listaQuery removeAllObjects];
    [listaObjeto removeAllObjects];
    
    if (_reloadWithAlert) {
        // Mesaje de bajando informacion
        baseAlert = [[[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                                message:@"Loading information..."
                                               delegate:self
                                      cancelButtonTitle:nil
                                      otherButtonTitles:nil] autorelease];
        [baseAlert show];
        
        // Create and add the activity indicator
        UIActivityIndicatorView *aiv = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
        aiv.center = CGPointMake(140.0f, 95.0f);
        [aiv startAnimating];
        [baseAlert addSubview:aiv];    
    }
    
    // Hacemos el query
    NSString *query;
    if ([objeto isEqualToString:@"EmailServicesAddress"]) {
        NSString *userId = [KeychainWrapper searchKeychain:@"kUserId"];
        
        query = [NSString stringWithFormat:@"SELECT Id, RunAsUserId, AuthorizedSenders, LocalPart, EmailDomainName from %@ where IsActive = true and RunAsUserId = %@%@%@ and LocalPart = 'emailtosalesforce' ", objeto, @"'",userId, @"'"];
    }
    
    //Here we use a query that should work on either Force.com or Database.com
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:query];
    [[SFRestAPI sharedInstance] send:request delegate:self];
}

#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    // Cargamos informacion a la tabla
    NSArray *records = [[NSArray alloc] initWithArray:[jsonResponse objectForKey:@"records"]];
    [listaQuery addObjectsFromArray:records];
    [records release];
    
    if ([request.queryParams objectForKey:@"q"] != NULL) {
        NSString *query = [NSString stringWithFormat:[request.queryParams objectForKey:@"q"]];
        NSString *queryObject = [NSString stringWithFormat:[request.queryParams objectForKey:@"q"]];
        NSRange rangeFrom = [query rangeOfString:@"from"];
        if (rangeFrom.length > 0) {
            queryObject = [NSString stringWithFormat:[query substringFromIndex:rangeFrom.location+5]];
            NSRange rangeWhere = [queryObject rangeOfString:@"where"];
            if (rangeWhere.length > 0) {
                queryObject = [queryObject substringToIndex:rangeWhere.location-1];
                
                NSDictionary *obj = [[[NSDictionary alloc] initWithObjectsAndKeys:queryObject, @"QueryObject", nil] autorelease];
                [listaObjeto addObject:obj];
            }            
        }    
    }
    
    NSString *done = [NSString stringWithFormat:@"%@", [jsonResponse objectForKey:@"done"]];
    if ([done isEqualToString:@"0"]) {
        NSString *nextRecords = [NSString stringWithFormat:@"%@", [jsonResponse objectForKey:@"nextRecordsUrl"]];
        
        SFRestRequest *tempRequest = [[SFRestRequest alloc] init];
        [tempRequest setEndpoint:@"/services/data"];
        [tempRequest setPath:nextRecords];  // this is the URL returned in nextRecordsUrl
        [tempRequest setMethod:SFRestMethodGET];
        [[SFRestAPI sharedInstance] send:tempRequest delegate:self];
        [tempRequest release];
    } else {
        
        NSLog(@"Objeto queryado: %@", [[listaObjeto objectAtIndex:0] valueForKey:@"QueryObject"]);
        
        if ([[[listaObjeto objectAtIndex:0] valueForKey:@"QueryObject"] isEqualToString:@"EmailServicesAddress"]) {
            if ([listaQuery count] > 0) {
                NSDictionary *obj = [listaQuery objectAtIndex:0];
                NSString *localPart = [NSString stringWithFormat:[obj objectForKey:@"LocalPart"]];
                NSString *emailDomainName = [NSString stringWithFormat:[obj objectForKey:@"EmailDomainName"]];
                NSString *emailAddress = [NSString stringWithFormat:@"%@@%@", localPart, emailDomainName];
                if (![emailDomainName isEqualToString:@"<null>"]) {
                    [email setText:emailAddress];
                    
                    // GUARDAMOS EL VALOR DE EMAIL
                    NSString *emailId = [NSString stringWithFormat:@"%@",emailAddress];
                    [KeychainWrapper createKeychainValue:emailId forIdentifier:@"kEmailId"];
                } else {
                    // BORRAMOS EL VALOR DE EMAIL
                    [self deleteEmail:0];
                }            
            }
        }

        // Quitamos el alert
        // Auto dismiss after 0 seconds
        if (_reloadWithAlert) {
            [self performSelector:@selector(performDismissAlert) withObject:nil afterDelay:0];
        }

    }
}


- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    if (_reloadWithAlert) {
        [self performSelector:@selector(performDismissAlert) withObject:nil afterDelay:0];
    }
    
    // Mandamos nueva alerte
    UIAlertView *alert;
    alert = [[[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                        message:[NSString stringWithFormat:@"Loading fail, please try again. %@", error.description]
                                       delegate:self
                              cancelButtonTitle:@"ok"
                              otherButtonTitles:nil] autorelease];
    [alert show];
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
    if (_reloadWithAlert) {
        [self performSelector:@selector(performDismissAlert) withObject:nil afterDelay:0];
    }
    
    // Mandamos nueva alerte
    UIAlertView *alert;
    alert = [[[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                        message:@"Request canceled, please try again"
                                       delegate:self
                              cancelButtonTitle:@"ok"
                              otherButtonTitles:nil] autorelease];
    [alert show];
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    if (_reloadWithAlert) {
        [self performSelector:@selector(performDismissAlert) withObject:nil afterDelay:0];
    }
    
    // Mandamos nueva alerte
    UIAlertView *alert;
    alert = [[[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                        message:@"Request time out, please try again"
                                       delegate:self
                              cancelButtonTitle:@"ok"
                              otherButtonTitles:nil] autorelease];
    [alert show];
}

- (IBAction)downloadEmail:(id)sender {
    // LEEMOS INFORMACIÓN DE SALESFORCE
    objeto = [NSString stringWithFormat:@"EmailServicesAddress"];
    _reloadWithAlert = YES;
    [self readFromSalesforce:objeto];
}

- (IBAction)deleteEmail:(id)sender {
    [email setText:@""];
    
    // BORRAMOS EL VALOR DE EMAIL
    [KeychainWrapper deleteKeychainValue:@"kEmailId"];
}

- (IBAction)showInstructions:(id)sender {
    DisclaimerViewController *controller = [[[DisclaimerViewController alloc] initWithNibName:@"DisclaimerViewController" bundle:nil] autorelease];
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:controller animated:YES];
}

#pragma mark - MailComposeController

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }

	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)switchChanged:(id)sender {
    // MENSAJE DE BCC EMAIL
    if ([sender tag] == 2) {
        if ([sender isOn]) {
            // Mandamos nueva alerte
            UIAlertView *alert;
            alert = [[[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                                message:[NSString stringWithFormat:@"Now please touch the \"Download it from Salesforce\" button to get your Salesforce email"]
                                               delegate:self
                                      cancelButtonTitle:@"ok"
                                      otherButtonTitles:nil] autorelease];
            [alert show];
        }
    }
    // MENSAJE MULTICURRENCY
    else if ([sender tag] == 4) {
        // Mandamos nueva alerte
        UIAlertView *alert;
        alert = [[[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                            message:[NSString stringWithFormat:@"Now please refresh Opportunities by pulling down its table view"]
                                           delegate:self
                                  cancelButtonTitle:@"ok"
                                  otherButtonTitles:nil] autorelease];
        [alert show];
    }
    // MENSAJE CONTACTS I OWN
    else if ([sender tag] == 5) {
        // Mandamos nueva alerte
        UIAlertView *alert;
        alert = [[[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                            message:[NSString stringWithFormat:@"Now please refresh Contacts by pulling down its table view"]
                                           delegate:self
                                  cancelButtonTitle:@"ok"
                                  otherButtonTitles:nil] autorelease];
        [alert show];
    }
    // MENSAJE LEADS I OWN
    else if ([sender tag] == 6) {
        // Mandamos nueva alerte
        UIAlertView *alert;
        alert = [[[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                            message:[NSString stringWithFormat:@"Now please refresh Leads by pulling down its table view"]
                                           delegate:self
                                  cancelButtonTitle:@"ok"
                                  otherButtonTitles:nil] autorelease];
        [alert show];
    }
    // MENSAJE OPPORTUNITIES I OWN
    else if ([sender tag] == 7) {
        // Mandamos nueva alerte
        UIAlertView *alert;
        alert = [[[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                            message:[NSString stringWithFormat:@"Now please refresh Opportunities by pulling down its table view"]
                                           delegate:self
                                  cancelButtonTitle:@"ok"
                                  otherButtonTitles:nil] autorelease];
        [alert show];
    }
}

#pragma mark - AlertView

- (IBAction)sendTweet:(id)sender {
    TWTweetComposeViewController *tweetView = [[TWTweetComposeViewController alloc] init];
    if ([TWTweetComposeViewController canSendTweet]) {
        
        [tweetView setInitialText:@"Check this out - Contactivity for Salesforce !!"];
        NSURL *contactivityUrl = [NSURL URLWithString:@"http://itunes.apple.com/us/app/contactivity-for-salesforce/id532374980?ls=1&mt=8"];
        [tweetView addURL:contactivityUrl];
        
        [self presentModalViewController:tweetView animated:YES];
        
        TWTweetComposeViewControllerCompletionHandler completionHandler = ^(TWTweetComposeViewControllerResult result) {
            switch (result) {
                case TWTweetComposeViewControllerResultCancelled:
                    break;
                case TWTweetComposeViewControllerResultDone:
                    break;
                default:
                    NSLog(@"Twitter Result: default or Problem");
                    break;
            }
            [self dismissModalViewControllerAnimated:YES];
        };
        [tweetView setCompletionHandler:completionHandler];    
    } else {
        // Mandamos nueva alerte
        UIAlertView *alert;
        alert = [[[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                            message:@"Please configure and log into your Twitter first at Settings-> Twitter"
                                           delegate:self
                                  cancelButtonTitle:@"ok"
                                  otherButtonTitles:nil] autorelease];
        [alert show];
    }
    
}

@end
