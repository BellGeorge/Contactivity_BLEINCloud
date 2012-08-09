//
//  SalesforceViewController.m
//  Contactivity
//
//  Created by Erik Solis on 4/10/12.
//  Copyright (c) 2012 Tu Mundo App. All rights reserved.
//

#import "SalesforceViewController.h"
#import "QuartzCore/QuartzCore.h"

#import "SFRestAPI.h"
#import "SFRestRequest.h"
#import "UIImage+Resizing.h"
#import "KeychainWrapper.h"

#define kCellRowHeight 57

@interface SalesforceViewController ()

@end

@implementation SalesforceViewController

@synthesize tableview, lista, objeto, listaObjeto, listaContacto, titulo, origen, opportunity, listaFiltered, listaQuery, popoverActionsheet, eventStore, defaultCalendar, callDate, shouldReturn, accountId, tipMessageView, tipMessage, listaTips;

- (void)dealloc {
    [tableview autorelease];
    self.lista = nil;
    self.listaQuery = nil;
    [objeto release];
    self.listaObjeto = nil;
    self.listaContacto = nil;
    [titulo release];
    [origen release];
    [opportunity release];
    self.listaFiltered = nil;
    _refreshHeaderView = nil;
    [popoverActionsheet release];
    [eventStore release];
    [defaultCalendar release];
    [callDate release];
    [shouldReturn release];
    [accountId release];
    [tipMessage release];
    self.listaTips = nil;
    [super dealloc];
}

- (void) performDismissAlert {
	[baseAlert dismissWithClickedButtonIndex:0 animated:NO];
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
    //self.tableview.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
    //[self.tableview setBackgroundColor:[UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0]];
    //[self.tableview setBackgroundColor:[UIColor whiteColor]];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:bgView.frame];
    [imageView setImage:[UIImage imageNamed:@"refreshBkg.png"]];
    [bgView addSubview:imageView];
    [self.tableview setBackgroundView:bgView];
    [imageView release];
    [bgView release];

    // CREAMOS LA VISTA ARRIBA DE LA TABLA PRINCIPAL
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableview.bounds.size.height, self.view.frame.size.width, self.tableview.bounds.size.height)];
		view.delegate = self;
		[self.tableview addSubview:view];
		_refreshHeaderView = view;
		[view release];
		
	}
	
	//  ACTUALIZAMOS LA FECHA DE ACTUALIZACIÓN
	[_refreshHeaderView refreshLastUpdatedDate];
    
    // INICIALIZAMOS
    //navTitle.title = [NSString stringWithFormat:@"%@", titulo];
    self.navigationItem.title = [NSString stringWithFormat:@"%@", titulo];
    //[navigationTitle setText:[NSString stringWithFormat:@"%@", titulo]];

    //self.navigationController.navigationBar.hidden = NO;
    UIImage *rightImage = [UIImage imageNamed:@"nav_chatterico(active).png"];
    rightImage = [rightImage imageScaledToSize:CGSizeMake(17, 19)];
    
    //Custom back button
    UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
    [backButton setTintColor:[UIColor colorWithRed:10.0f/255.0f green:30.0f/255.0f blue:81.0f/255.0f alpha:1.0f]];
    self.navigationItem.backBarButtonItem = backButton;

    if ([shouldReturn isEqualToString:@"NO"]) {
        UIImage *leftImage = [UIImage imageNamed:@"nav_settingsico(active).png"];
        leftImage = [leftImage imageScaledToSize:CGSizeMake(20, 20)];
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftButton setImage:leftImage forState:UIControlStateNormal];
        leftButton.frame = CGRectMake(0, 0, leftImage.size.width, leftImage.size.height);
        [leftButton addTarget:self action:@selector(showSettings:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:leftButton] autorelease];    
    }

    // OBTENEMOS EL TAMAÑO DE LA CELDA
    [self.tableview setRowHeight:kCellRowHeight];
    [self.searchDisplayController.searchResultsTableView setRowHeight:self.tableview.rowHeight];

    lista = [[NSMutableArray alloc] init];
    listaQuery = [[NSMutableArray alloc] init];
    listaFiltered = [[NSMutableArray alloc] init];
    listaObjeto = [[NSMutableArray alloc] init];
    listaContacto = [[NSMutableArray alloc] init];
    listaTips = [[NSMutableArray alloc] init];
    _reloadWithAlert = YES;
    
    // GENERAMOS USER DEFAULTS
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"kMulticurrency"] == NULL) {
        [userDefaults setObject:@"NO" forKey:@"kMulticurrency"];
    }
    if ([userDefaults objectForKey:@"kContactsIOwn"] == NULL) {
        [userDefaults setObject:@"NO" forKey:@"kContactsIOwn"];
    }
    if ([userDefaults objectForKey:@"kLeadsIOwn"] == NULL) {
        [userDefaults setObject:@"NO" forKey:@"kLeadsIOwn"];
    }
    if ([userDefaults objectForKey:@"kOpportunitiesIOwn"] == NULL) {
        [userDefaults setObject:@"NO" forKey:@"kOpportunitiesIOwn"];
    }

    if ([origen isEqualToString:@"Salesforce"]) {
        
        // LEEMOS INFORMACIÓN DE SALESFORCE
        [self readFromSalesforce:objeto];
                
    } else {
        
        // OBTENEMOS INFORMACÓN DEL ADDRESS BOOK
        [self readFromAddressBook:@"SI"];

        // ORDENAMOS LA INFORMACION
        NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Name" ascending:YES];
        [lista sortUsingDescriptors:[NSArray arrayWithObject:aSortDescriptor]];
        [aSortDescriptor release];
    }

    // INICIALIZA EL OBJECTO EVENT STORE
	self.eventStore = [[EKEventStore alloc] init];
    
    // LOCAL SOURCE
    EKSource *localSource = nil;
    for (EKSource *source in self.eventStore.sources) {
        if (source.sourceType == EKSourceTypeLocal) {
            localSource = source;
            break;
        }    
    }
    
    BOOL crearCalendario = YES;
    NSString *contactivityID = @"";
    for(EKCalendar *calendar in [self.eventStore calendars]) {
        if ([[calendar title] isEqualToString:@"Contactivity"]) {
            crearCalendario = NO;
            contactivityID = [NSString stringWithFormat:@"%@",[calendar calendarIdentifier]];
        }
        if (!crearCalendario) break;
    }
    
    EKCalendar *cal;
    if (crearCalendario) {
        cal = [EKCalendar calendarWithEventStore:self.eventStore];
        cal.title = @"Contactivity";
        cal.source = localSource;
        [self.eventStore saveCalendar:cal commit:YES error:nil];
        
        // GUARDAMOS EL ID DEL CALENDARIO
        contactivityID = [NSString stringWithFormat:@"%@",[cal calendarIdentifier]];
    } else {
        cal = [self.eventStore calendarWithIdentifier:contactivityID];
    }

	// SETEAMOS EL CALENDARIO POR DEFAULT
    self.defaultCalendar = [self.eventStore calendarWithIdentifier:[cal calendarIdentifier]];
    
    // AGREGAMOS MENSAJES
    NSString *mensaje = [NSString stringWithFormat:@"Touch any row more than 1 second to access your ORG from a browser"];
    NSDictionary *obj = [[[NSDictionary alloc] initWithObjectsAndKeys:mensaje, @"Tip", nil] autorelease];
    [listaTips addObject:obj];

    mensaje = [NSString stringWithFormat:@"Contactivity Calendar only shows Events created with this app"];
    obj = [[[NSDictionary alloc] initWithObjectsAndKeys:mensaje, @"Tip", nil] autorelease];
    [listaTips addObject:obj];

    mensaje = [NSString stringWithFormat:@"To \"Logout\" go to Settings-> Contactivity-> Logout Now-> ON"];
    obj = [[[NSDictionary alloc] initWithObjectsAndKeys:mensaje, @"Tip", nil] autorelease];
    [listaTips addObject:obj];
    
    mensaje = [NSString stringWithFormat:@"Touch any row more than 1 second to access your ORG from a browser"];
    obj = [[[NSDictionary alloc] initWithObjectsAndKeys:mensaje, @"Tip", nil] autorelease];
    [listaTips addObject:obj];

    mensaje = [NSString stringWithFormat:@"To upload events to Salesforce go the Settings and follow instructions"];
    obj = [[[NSDictionary alloc] initWithObjectsAndKeys:mensaje, @"Tip", nil] autorelease];
    [listaTips addObject:obj];

    mensaje = [NSString stringWithFormat:@"To upload mails to Salesforce go the Settings and follow instructions"];
    obj = [[[NSDictionary alloc] initWithObjectsAndKeys:mensaje, @"Tip", nil] autorelease];
    [listaTips addObject:obj];

    mensaje = [NSString stringWithFormat:@"Touch any row more than 1 second to access your ORG from a browser"];
    obj = [[[NSDictionary alloc] initWithObjectsAndKeys:mensaje, @"Tip", nil] autorelease];
    [listaTips addObject:obj];
    
    mensaje = [NSString stringWithFormat:@"Mail \"Screenshot\" is available within Web Access"];
    obj = [[[NSDictionary alloc] initWithObjectsAndKeys:mensaje, @"Tip", nil] autorelease];
    [listaTips addObject:obj];

    mensaje = [NSString stringWithFormat:@"Mail \"PDF\" file is available within Web Access"];
    obj = [[[NSDictionary alloc] initWithObjectsAndKeys:mensaje, @"Tip", nil] autorelease];
    [listaTips addObject:obj];

    mensaje = [NSString stringWithFormat:@"If any issue contact us by mail creating a \"New Case\" in Settings, we will help you"];
    obj = [[[NSDictionary alloc] initWithObjectsAndKeys:mensaje, @"Tip", nil] autorelease];
    [listaTips addObject:obj];

    mensaje = [NSString stringWithFormat:@"App created by www.bleincloud.com"];
    obj = [[[NSDictionary alloc] initWithObjectsAndKeys:mensaje, @"Tip", nil] autorelease];
    [listaTips addObject:obj];

    mensaje = [NSString stringWithFormat:@"Mail \"Original Attachment\" is available within Web Access"];
    obj = [[[NSDictionary alloc] initWithObjectsAndKeys:mensaje, @"Tip", nil] autorelease];
    [listaTips addObject:obj];
    
    mensaje = [NSString stringWithFormat:@"If any issue contact us by mail creating a \"New Case\" in Settings, we will help you"];
    obj = [[[NSDictionary alloc] initWithObjectsAndKeys:mensaje, @"Tip", nil] autorelease];
    [listaTips addObject:obj];
    
    mensaje = [NSString stringWithFormat:@"Pull down table to refresh information in real time"];
    obj = [[[NSDictionary alloc] initWithObjectsAndKeys:mensaje, @"Tip", nil] autorelease];
    [listaTips addObject:obj];
    
    mensaje = [NSString stringWithFormat:@"To track Contact activity in Opportunity, add him to \"Contact Roles\" in Salesforce"];
    obj = [[[NSDictionary alloc] initWithObjectsAndKeys:mensaje, @"Tip", nil] autorelease];
    [listaTips addObject:obj];

    mensaje = [NSString stringWithFormat:@"To enable \"Multi Currency\" go the Settings and follow instructions"];
    obj = [[[NSDictionary alloc] initWithObjectsAndKeys:mensaje, @"Tip", nil] autorelease];
    [listaTips addObject:obj];
    
    mensaje = [NSString stringWithFormat:@"To only see the records you \"OWN\" go the Settings and follow instructions"];
    obj = [[[NSDictionary alloc] initWithObjectsAndKeys:mensaje, @"Tip", nil] autorelease];
    [listaTips addObject:obj];
    
    mensaje = [NSString stringWithFormat:@"By default you can see records according your profile"];
    obj = [[[NSDictionary alloc] initWithObjectsAndKeys:mensaje, @"Tip", nil] autorelease];
    [listaTips addObject:obj];
    
    mensaje = [NSString stringWithFormat:@"Please install Skype from AppStore to make some calls"];
    obj = [[[NSDictionary alloc] initWithObjectsAndKeys:mensaje, @"Tip", nil] autorelease];
    [listaTips addObject:obj];

    mensaje = [NSString stringWithFormat:@"Please configure Facetime to make some calls"];
    obj = [[[NSDictionary alloc] initWithObjectsAndKeys:mensaje, @"Tip", nil] autorelease];
    [listaTips addObject:obj];

    mensaje = [NSString stringWithFormat:@"To cancel an event you must enter your ORG"];
    obj = [[[NSDictionary alloc] initWithObjectsAndKeys:mensaje, @"Tip", nil] autorelease];
    [listaTips addObject:obj];

    mensaje = [NSString stringWithFormat:@"Event changes are not registered in your ORG"];
    obj = [[[NSDictionary alloc] initWithObjectsAndKeys:mensaje, @"Tip", nil] autorelease];
    [listaTips addObject:obj];
    
    // Transparent search bar
    [self customSearchBars];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;    
}

- (void)viewWillAppear:(BOOL)animated {
    // MOSTRAMOS LOS TIPS
    if (!_tipShowing) {
        if ([origen isEqualToString:@"Salesforce"]) {
            // CONSULTAMOS SI MOSTRAMOS MENSAJES
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            if ([userDefaults objectForKey:@"kTipMessage"] != NULL) {
                if ([[userDefaults stringForKey:@"kTipMessage"] isEqualToString:@"SI"]) {
                    // ENTRADA DE TIP
                    [self performSelector:@selector(loadTip) withObject:nil afterDelay:3.0];
                    
                    // SALIDA DE TIP
                    [self performSelector:@selector(closeTip) withObject:nil afterDelay:8.0];
                }
            } else {
                [userDefaults setObject:@"SI" forKey:@"kUploadEventId"];
                
                // ENTRADA DE TIP
                [self performSelector:@selector(loadTip) withObject:nil afterDelay:3.0];
                
                // SALIDA DE TIP
                [self performSelector:@selector(closeTip) withObject:nil afterDelay:8.0];            
            }    
        }    
    }
    
    if ([origen isEqualToString:@"Salesforce"]) {
        // LONG TERM GESTURE TO OPEN WEB BROWSER
        UILongPressGestureRecognizer *lpgrSearch = [[UILongPressGestureRecognizer alloc] 
                                                    initWithTarget:self action:@selector(handleLongPressSearch:)];
        lpgrSearch.minimumPressDuration = 1.0; //SECONDS
        lpgrSearch.delegate = self;
        [self.searchDisplayController.searchResultsTableView addGestureRecognizer:lpgrSearch];
        [lpgrSearch release];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    // Borramos anuncio
    [tipMessageView removeFromSuperview];
    _tipShowing = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (void)readFromSalesforce:(NSString*)Object {

    [listaQuery removeAllObjects];
    [listaObjeto removeAllObjects];
    
    _reloading = YES;
    
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
    NSString *userId = [KeychainWrapper searchKeychain:@"kUserId"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *query;
    if ([objeto isEqualToString:@"Lead"]) {
        if ([[userDefaults stringForKey:@"kLeadsIOwn"] isEqualToString:@"SI"]) {
            //if you want to add an image to your cell, here's how
            query = [NSString stringWithFormat:@"SELECT Id, Name, FirstName, LastName, Email, Phone, Company, Street, City, State, PostalCode, Country from %@ where IsDeleted = false and IsConverted = false and OwnerId = %@%@%@ order by Name", objeto, @"'", userId, @"'"];
        } else {
            //if you want to add an image to your cell, here's how
            query = [NSString stringWithFormat:@"SELECT Id, Name, FirstName, LastName, Email, Phone, Company, Street, City, State, PostalCode, Country from %@ where IsDeleted = false and IsConverted = false order by Name", objeto];                
        }
    } else if ([objeto isEqualToString:@"Contact"]) {
        //if you want to add an image to your cell, here's how
        if ([[userDefaults stringForKey:@"kContactsIOwn"] isEqualToString:@"SI"]) {
            if ([accountId isEqualToString:@""]) {
                query = [NSString stringWithFormat:@"SELECT Id, Name, FirstName, LastName, Email, Phone, MobilePhone, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from %@ where IsDeleted = false and OwnerId = %@%@%@ order by Name", objeto, @"'", userId, @"'"];        
            } else {
                query = [NSString stringWithFormat:@"SELECT Id, Name, FirstName, LastName, Email, Phone, MobilePhone, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from %@ where IsDeleted = false and AccountId = %@%@%@ order by Name", objeto, @"'", accountId, @"'"];
            }
        } else {
            if ([accountId isEqualToString:@""]) {
                query = [NSString stringWithFormat:@"SELECT Id, Name, FirstName, LastName, Email, Phone, MobilePhone, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from %@ where IsDeleted = false order by Name", objeto];        
            } else {
                query = [NSString stringWithFormat:@"SELECT Id, Name, FirstName, LastName, Email, Phone, MobilePhone, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry from %@ where IsDeleted = false and AccountId = %@%@%@ order by Name", objeto, @"'", accountId, @"'"];
            }
        }
    } else if ([objeto isEqualToString:@"Opportunity"]) {
        if ([[userDefaults stringForKey:@"kOpportunitiesIOwn"] isEqualToString:@"SI"]) {
            if ([[userDefaults stringForKey:@"kMulticurrency"] isEqualToString:@"SI"]) {
                query = [NSString stringWithFormat:@"SELECT Id, Name, StageName, Amount, AccountId, CurrencyIsoCode from %@ where IsDeleted = false and IsClosed = false and OwnerId = %@%@%@ order by Name", objeto, @"'", userId, @"'"];
            } else {
                query = [NSString stringWithFormat:@"SELECT Id, Name, StageName, Amount, AccountId from %@ where IsDeleted = false and IsClosed = false and OwnerId = %@%@%@ order by Name", objeto, @"'", userId, @"'"];
            }            
        } else {
            if ([[userDefaults stringForKey:@"kMulticurrency"] isEqualToString:@"SI"]) {
                query = [NSString stringWithFormat:@"SELECT Id, Name, StageName, Amount, AccountId, CurrencyIsoCode from %@ where IsDeleted = false and IsClosed = false order by Name", objeto];
            } else {
                query = [NSString stringWithFormat:@"SELECT Id, Name, StageName, Amount, AccountId from %@ where IsDeleted = false and IsClosed = false order by Name", objeto];
            }            
        }
    }
    [userId release];
    
    //Here we use a query that should work on either Force.com or Database.com
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:query];
    [[SFRestAPI sharedInstance] send:request delegate:self];
}

#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {

    // OBTENEMOS EL OBJETO QUE FUE QUERYEADO
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

    // Cargamos informacion a la tabla
    NSArray *records = [[NSArray alloc] initWithArray:[jsonResponse objectForKey:@"records"]];
    
    if ([listaObjeto count] > 0) {
        NSString *objetoQuery = [NSString stringWithFormat:@"%@",[[listaObjeto objectAtIndex:0] valueForKey:@"QueryObject"]];
        if ([objetoQuery isEqualToString:@"Event"]) {
            // Auto dismiss after 0 seconds
            [self performSelector:@selector(performDismissAlert) withObject:nil afterDelay:0];
            
            // Mandamos nueva alerte
            UIAlertView *alert;
            alert = [[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                               message:@"Event uploaded to Salesforce !!"
                                              delegate:self
                                     cancelButtonTitle:@"ok"
                                     otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            // Deseleccionamos la celda
            [tableview deselectRowAtIndexPath:[self.tableview indexPathForSelectedRow] animated:YES];
            return;
        } else if ([objetoQuery isEqualToString:@"Task"]) {
            NSString *tipoTarea = [NSString stringWithFormat:@"%@",[[listaObjeto objectAtIndex:0] valueForKey:@"Type"]];
            if ([tipoTarea isEqualToString:@"Facetime"]) {
                // Auto dismiss after 0 seconds
                [self performSelector:@selector(performDismissAlert) withObject:nil afterDelay:0];
                
                // Mandamos nueva alerte
                UIAlertView *alert;
                alert = [[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                                   message:@"Facetime Call uploaded to Salesforce !!"
                                                  delegate:self
                                         cancelButtonTitle:@"ok"
                                         otherButtonTitles:nil];
                [alert show];
                [alert release];
                
                // Deseleccionamos la celda
                [tableview deselectRowAtIndexPath:[self.tableview indexPathForSelectedRow] animated:YES];
                return;
                
            } if ([tipoTarea isEqualToString:@"Skype"]) {
                // Auto dismiss after 0 seconds
                [self performSelector:@selector(performDismissAlert) withObject:nil afterDelay:0];
                
                // Mandamos nueva alerte
                UIAlertView *alert;
                alert = [[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                                   message:@"Skype Call uploaded to Salesforce !!"
                                                  delegate:self
                                         cancelButtonTitle:@"ok"
                                         otherButtonTitles:nil];
                [alert show];
                [alert release];
                
                // Deseleccionamos la celda
                [tableview deselectRowAtIndexPath:[self.tableview indexPathForSelectedRow] animated:YES];
                return;
                
            } else {
                // Auto dismiss after 0 seconds
                [self performSelector:@selector(performDismissAlert) withObject:nil afterDelay:0];
                
                // Mandamos nueva alerte
                UIAlertView *alert;
                alert = [[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                                   message:@"Call uploaded to Salesforce !!"
                                                  delegate:self
                                         cancelButtonTitle:@"ok"
                                         otherButtonTitles:nil];
                [alert show];
                [alert release];
                
                // Deseleccionamos la celda
                [tableview deselectRowAtIndexPath:[self.tableview indexPathForSelectedRow] animated:YES];
                return; 
                
            }
        } else {
            [listaQuery addObjectsFromArray:records];
        }
    } else {
        [listaQuery addObjectsFromArray:records];
    }
    [records release];
        
    // BUSCAMOS SI TIENE MAS REGISTROS
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
        NSString *objetoQuery = [NSString stringWithFormat:@"%@",[[listaObjeto objectAtIndex:0] valueForKey:@"QueryObject"]];
        
        if (![objetoQuery isEqualToString:@"Event"]) {
            // Copiamos informacion a la tabla nueva
            [lista removeAllObjects];
            [lista addObjectsFromArray:listaQuery];
            
            // ACTUALIZAMOS TABLA
            [tableview reloadData];
            
            //  model should call this when its done loading
            _reloading = NO;
            [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableview];        
        }
        
        // Quitamos el alert
        // Auto dismiss after 0 seconds
        if (_reloadWithAlert) {
            [self performSelector:@selector(performDismissAlert) withObject:nil afterDelay:0];
        } else {
            _reloadWithAlert = YES;
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
    
    // Actualizamos tabla
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
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
    
    // Actualizamos tabla
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
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
    
    // Actualizamos tabla
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
}

- (NSString*)cleanTelephone:(NSString*)telephone {
    NSString *telefono = [NSString stringWithFormat:@"%@", telephone];
    
    if (![telefono isEqualToString:@""] && ![telefono isEqualToString:@"(null)"]) {
        telefono = [telefono stringByReplacingOccurrencesOfString:@" " withString:@""];
        telefono = [telefono stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        telefono = [telefono stringByReplacingOccurrencesOfString:@"(" withString:@""];
        telefono = [telefono stringByReplacingOccurrencesOfString:@")" withString:@""];
        telefono = [telefono stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    
    return telefono;
}

- (NSString*)cleanEmail:(NSString*)email {
    NSString *correo = [NSString stringWithFormat:@"%@", email];
    
    if (![correo isEqualToString:@""] && ![correo isEqualToString:@"(null)"]) {
        correo = [correo stringByReplacingOccurrencesOfString:@" " withString:@""];
        correo = [correo stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        correo = [correo stringByReplacingOccurrencesOfString:@"(" withString:@""];
        correo = [correo stringByReplacingOccurrencesOfString:@")" withString:@""];
    }
    
    return correo;
}

#pragma mark - Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Customize the name of sections in the table view
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //return [NSString stringWithFormat:@"Ciudades en %@", titulo];
    return nil;
}

// Customize the sections using indexes
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == tableview) {
        NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
        [array addObject:@"*"];
        for (int i = 0; i < [lista count]; i++) {
            NSString *name;
            if ([objeto isEqualToString:@"Case"]) {
                name = [[lista objectAtIndex:i] objectForKey:@"Subject"];
            } else {
                name = [[lista objectAtIndex:i] objectForKey:@"Name"];
            }
            name = [[name substringToIndex:1] uppercaseString];
            BOOL encontrado = NO;
            for (int f = 0; f < [array count]; f++) {
                if ([[array objectAtIndex:f] isEqualToString:name]) {
                    encontrado = YES;
                    f = [array count];
                }
            }
            if (!encontrado) {
                [array addObject:name];
            }
        }    
        return array;
    }
    return nil;
}

// Customize the section to read in the table view
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (tableView == tableview) {
        for (int i = 0; i < [lista count]; i++) {
            NSString *name;
            if ([objeto isEqualToString:@"Case"]) {
                name = [[lista objectAtIndex:i] objectForKey:@"Subject"];
            } else {
                name = [[lista objectAtIndex:i] objectForKey:@"Name"];
            }
            if ([title isEqualToString:[[name substringToIndex:1] uppercaseString]]) {
                NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:(i) inSection:0];
                [tableView reloadData];
                [[self tableview] scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                return index;
            }
        }
    }
    return index;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Normal table
	if (tableView == tableview) {
        return [lista count];
    } else {
        return [listaFiltered count];
    }	
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    

    if ([objeto isEqualToString:@"Contact"] || [objeto isEqualToString:@"Lead"]) {

        static NSString *CellIdentifier = @"CustomCell";
        CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:nil options:nil];
            for(id currentObject in topLevelObjects) {
                if([currentObject isKindOfClass:[CustomCell class]]) {
                    cell = (CustomCell *)currentObject;
                    break;
                }
            }
        }
        
        NSDictionary *obj;
        // Si es la tabla completa
        if (tableView == tableview) {
            obj = [lista objectAtIndex:indexPath.row];
        } else {
            obj = [listaFiltered objectAtIndex:indexPath.row];
        }
        
        // Configure the cell to show the data.
        //((isReachable && !needsConnection) || nonWiFi) ? (testConnection ? YES : NO) : NO;
        NSString *nombre = [NSString stringWithFormat:@"%@", [obj objectForKey:@"Name"]];
        (![nombre isEqualToString:@"<null>"]) ? [[cell nombre] setText:[obj objectForKey:@"Name"]] : [[cell nombre] setText:@""];
        
        NSString *correo = [NSString stringWithFormat:@"%@", [obj objectForKey:@"Email"]];
        (![correo isEqualToString:@"<null>"]) ? [[cell correo] setText:[obj objectForKey:@"Email"]] : [[cell correo] setText:@""];
        
        NSString *telefono = [self cleanTelephone:[NSString stringWithFormat:@"%@", [obj objectForKey:@"Phone"]]];
        (![telefono isEqualToString:@"<null>"]) ? [[cell telefono] setText:telefono] : [[cell telefono] setText:@""];
        
        if ([objeto isEqualToString:@"Lead"]) {
            //if you want to add an image to your cell, here's how
            UIImage *image = [UIImage imageNamed:@"icon_lead.png"];
            [[cell imageView] setImage:image];
            
        } else if ([objeto isEqualToString:@"Contact"]) {
            
            NSString *telefonoMovil = [self cleanTelephone:[NSString stringWithFormat:@"%@", [obj objectForKey:@"MobilePhone"]]];
            (![telefonoMovil isEqualToString:@"<null>"]) ? [[cell telefono] setText:telefonoMovil] : @"";
            
            UIImage *image = [obj objectForKey:@"Photo"];
            
            if ([origen isEqualToString:@"Salesforce"]) {
                image = [UIImage imageNamed:@"icon_contact.png"];
            } else {
                if (image == NULL) {
                    image = [UIImage imageNamed:@"default_user.png"];
                }            
            }
            
            [[cell imageView] setImage:image];
        }
        
        [[cell imageView] layer].cornerRadius = 4;
        
        if(indexPath.row % 4 == 0) {}
        if(indexPath.row % 4 == 1) {}
        
        // Color of the cell selection
        UIView *bgColorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 57)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:bgColorView.frame];
        [imageView setImage:[UIImage imageNamed:@"cellSelectedBkg.png"]];
        [bgColorView addSubview:imageView];
        [cell setSelectedBackgroundView:bgColorView];
        [imageView release];
        [bgColorView release];
                
        return cell;    

    } else if ([objeto isEqualToString:@"Opportunity"]) {

        static NSString *CellIdentifier = @"OpportunityCell";
        OpportunityCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"OpportunityCell" owner:nil options:nil];
            for(id currentObject in topLevelObjects) {
                if([currentObject isKindOfClass:[OpportunityCell class]]) {
                    cell = (OpportunityCell *)currentObject;
                    break;
                }
            }
        }
        
        NSDictionary *obj;
        // Si es la tabla completa
        if (tableView == tableview) {
            obj = [lista objectAtIndex:indexPath.row];
        } else {
            obj = [listaFiltered objectAtIndex:indexPath.row];
        }
        
        // Configure the cell to show the data.
        //((isReachable && !needsConnection) || nonWiFi) ? (testConnection ? YES : NO) : NO;
        NSString *nombre = [NSString stringWithFormat:@"%@", [obj objectForKey:@"Name"]];
        (![nombre isEqualToString:@"<null>"]) ? [[cell nombre] setText:nombre] : [[cell nombre] setText:@""];
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [formatter setPositiveFormat:@"$ ###,###,##0.00"];
        NSNumber *formated = [[NSNumber alloc] initWithInt:[[NSString stringWithFormat:@"%@", [obj objectForKey:@"Amount"]] floatValue]];
        NSString *monto = [formatter stringFromNumber:formated];
        [[cell monto] setText:monto];
        
        NSString *estado = [NSString stringWithFormat:@"%@", [obj objectForKey:@"StageName"]];
        (![estado isEqualToString:@"<null>"]) ? [[cell estado] setText:estado] : [[cell estado] setText:@""];

        UIImage *image = [UIImage imageNamed:@"icon_opportunity.png"];
        [[cell imageView] setImage:image];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ([userDefaults objectForKey:@"kMulticurrency"] != NULL) {
            if ([[userDefaults stringForKey:@"kMulticurrency"] isEqualToString:@"SI"]) {
                NSString *moneda = [NSString stringWithFormat:@"%@", [obj objectForKey:@"CurrencyIsoCode"]];
                (![moneda isEqualToString:@"(null)"]) ? [[cell moneda] setText:moneda] : [[cell moneda] setText:@"Please Refresh"];
            }
        }
        
        [[cell imageView] layer].cornerRadius = 3;
        
        if(indexPath.row % 4 == 0) {}
        if(indexPath.row % 4 == 1) {}
        
        // Color of the cell selection
        UIView *bgColorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 57)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:bgColorView.frame];
        [imageView setImage:[UIImage imageNamed:@"cellSelectedBkg.png"]];
        [bgColorView addSubview:imageView];
        [cell setSelectedBackgroundView:bgColorView];
        [imageView release];
        [bgColorView release];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - Table view delegate

//Change heigth of the selected row
/*- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 10.0;
}*/ 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSDictionary *obj;
    // Si es la tabla completa
    if (tableView == tableview) {
        obj = [lista objectAtIndex:indexPath.row];
    } else {
        obj = [listaFiltered objectAtIndex:indexPath.row];
    }

    if ([objeto isEqualToString:@"Contact"] || [objeto isEqualToString:@"Lead"]) {        
        // Limpiamos el ID del registro
        [listaContacto removeAllObjects];
        NSString *Id = [NSString stringWithFormat:@"%@",[obj valueForKey:@"Id"]];
        NSString *name = [NSString stringWithFormat:@"%@",[obj valueForKey:@"Name"]];
        NSString *phone = [NSString stringWithFormat:@"%@",[obj valueForKey:@"Phone"]];
        phone = [self cleanTelephone:phone];
        NSString *mobilePhone = [NSString stringWithFormat:@"%@",[obj valueForKey:@"MobilePhone"]];
        mobilePhone = [self cleanTelephone:mobilePhone];
        NSString *email = [NSString stringWithFormat:@"%@",[obj valueForKey:@"Email"]];
        email = [self cleanEmail:email];
        NSDictionary *objId = [[[NSDictionary alloc] initWithObjectsAndKeys: Id, @"Id", name, @"Name", phone , @"Phone", mobilePhone, @"MobilePhone", email, @"Email", nil] autorelease];
        [listaContacto addObject:objId];
        
        // MOSTRAMOS LAS OPCIONES DEL REGRISTRO
        [self showOptions];
    } else if ([objeto isEqualToString:@"Opportunity"]) {
        SalesforceViewController *controller = [[SalesforceViewController alloc] initWithNibName:@"SalesforceViewController" bundle:nil];
        controller.objeto = [NSString stringWithFormat:@"%@",@"Contact"];
        controller.titulo = [NSString stringWithFormat:@"%@",@"Contacts in Salesforce"];
        controller.origen = [NSString stringWithFormat:@"%@",@"Salesforce"];
        controller.shouldReturn = [NSString stringWithFormat:@"%@",@"YES"];
        controller.accountId = [NSString stringWithFormat:@"%@",[obj valueForKey:@"AccountId"]];
        controller.opportunity = [NSString stringWithFormat:@"%@",[obj valueForKey:@"Id"]];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - Searchbar Table view delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.searchDisplayController.searchResultsTableView setRowHeight:self.tableview.rowHeight];
    [tableview deselectRowAtIndexPath:[self.tableview indexPathForSelectedRow] animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if(listaFiltered != nil) {
        [listaFiltered release];
    }
    listaFiltered = [[NSMutableArray alloc] init];
    
    // Search table
    for (int i = 0; i < [lista count]; i++) {
        NSString *name;
        if ([objeto isEqualToString:@"Case"]) {
            name = [[lista objectAtIndex:i] objectForKey:@"Subject"];
        } else {
            name = [[lista objectAtIndex:i] objectForKey:@"Name"];
        }
        
        // Buscamos palabra en lista completa
        if ([name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [listaFiltered addObject:[lista objectAtIndex:i]];
        }
    }
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    if ([self.tableview indexPathForSelectedRow] > 0) {
        [tableview deselectRowAtIndexPath:[self.tableview indexPathForSelectedRow] animated:YES];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)doneLoadingTableViewData{
	
    // Copiamos informacion a la tabla nueva
    [lista removeAllObjects];
    [lista addObjectsFromArray:listaQuery];

    // ORDENAMOS LA INFORMACION
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Name" ascending:YES];
    [lista sortUsingDescriptors:[NSArray arrayWithObject:aSortDescriptor]];

    // ACTUALIZAMOS TABLA
    [tableview reloadData];

	//  model should call this when its done loading
	_reloading = NO;

	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableview];
	
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
	// Mandamos refrescar la tabla

    _reloadWithAlert = NO;
    if ([origen isEqualToString:@"Salesforce"]) {
        [self readFromSalesforce:objeto];    
    } else {
        // OBTENEMOS INFORMACÓN DEL ADDRESS BOOK
        [self readFromAddressBook:@"NO"];

        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
	
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
	
	return [NSDate date]; // should return date data source was last changed
}

#pragma mark - ActionSheet

- (void)showOptions {
    
    // Si ya se muestra las opciones, las ocultamos
    if ([popoverActionsheet isVisible]) {
        [popoverActionsheet dismissWithClickedButtonIndex:[popoverActionsheet cancelButtonIndex] animated:YES];
        return;
    }
    
    popoverActionsheet = [[UIActionSheet alloc] initWithTitle:@"Select an option"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:
                          @"Add Event",
                          @"Email Now",
                          @"Call Now",
                          @"Facetime",
                          @"Skype",
                          nil];
    
    NSIndexPath *indexPath = [tableview indexPathForSelectedRow];
    NSDictionary *obj;
    if (indexPath == nil) {
        indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        obj = [listaFiltered objectAtIndex:indexPath.row];
    } else {
        obj = [lista objectAtIndex:indexPath.row];
    }
    
    NSString *correo = [NSString stringWithFormat:@"%@", [obj objectForKey:@"Email"]];
    NSString *telefono = [NSString stringWithFormat:@"%@", [obj objectForKey:@"Phone"]];
    NSString *telefonoMovil = [NSString stringWithFormat:@"%@", [obj objectForKey:@"MobilePhone"]];
    if (![telefonoMovil isEqualToString:@"(null)>"] && ![telefonoMovil isEqualToString:@""] && ![telefonoMovil isEqualToString:@"<null>"]) {
        telefono = [NSString stringWithFormat:@"%@", telefonoMovil];
    }
    
    NSArray *buttons = [popoverActionsheet subviews];
    for (NSObject *object in buttons) {
        if ([object isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)object;
            if ([[button currentTitle] isEqualToString:@"Call Now"]) {
                [button setEnabled:([telefono isEqualToString:@"<null>"] || [telefono isEqualToString:@""]) ? NO : YES];
            } else if ([[button currentTitle] isEqualToString:@"Email Now"]) {
                [button setEnabled:([correo isEqualToString:@"<null>"] || [correo isEqualToString:@""]) ? NO : YES];
            } else if ([[button currentTitle] isEqualToString:@"Facetime"]) {
                [button setEnabled:([correo isEqualToString:@"<null>"] || [correo isEqualToString:@""]) ? NO : YES];
            } else if ([[button currentTitle] isEqualToString:@"Skype"]) {
                [button setEnabled:([telefono isEqualToString:@"<null>"] || [telefono isEqualToString:@""]) ? NO : YES];
            }
        }
    }
    
    [popoverActionsheet showInView:self.view.superview];
}

- (void) actionSheet: (UIActionSheet *)actionSheet didDismissWithButtonIndex: (NSInteger)buttonIndex {
    NSIndexPath *indexPath = [tableview indexPathForSelectedRow];
    NSString *name = @" ";
    NSString *phone = @" ";
    NSString *mobilePhone = @" ";
    NSString *address = @" ";
    NSString *email = @" ";
    NSString *street = @" ";
    NSString *city = @" ";
    NSString *state = @" ";
    NSString *postalCode = @" ";
    NSString *country = @" ";

    if (indexPath == nil) {
        indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        // Search Table
        // SE PUSIERON ESPACIOS DESPUES DEL VALOR PARA DETECTAR LOS NULLS Y VACIOS
        name = [NSString stringWithFormat:@"%@ ", [[listaFiltered objectAtIndex:indexPath.row] objectForKey:@"Name"]];
        phone = [NSString stringWithFormat:@"%@ ", [[listaFiltered objectAtIndex:indexPath.row] objectForKey:@"Phone"]];
        email = [NSString stringWithFormat:@"%@ ", [[listaFiltered objectAtIndex:indexPath.row] objectForKey:@"Email"]];
        if ([objeto isEqualToString:@"Lead"]) {
            // Street, City, State, PostalCode, Country
            street = [NSString stringWithFormat:@"%@ ",[[listaFiltered objectAtIndex:indexPath.row] objectForKey:@"Street"]];
            city = [NSString stringWithFormat:@"%@ ",[[listaFiltered objectAtIndex:indexPath.row] objectForKey:@"City"]];
            state = [NSString stringWithFormat:@"%@ ",[[listaFiltered objectAtIndex:indexPath.row] objectForKey:@"Street"]];
            postalCode = [NSString stringWithFormat:@"%@ ",[[listaFiltered objectAtIndex:indexPath.row] objectForKey:@"PostalCode"]];
            country = [NSString stringWithFormat:@"%@ ",[[listaFiltered objectAtIndex:indexPath.row] objectForKey:@"Country"]];
        } else if ([objeto isEqualToString:@"Contact"]) {
            // MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
            mobilePhone = [NSString stringWithFormat:@"%@ ",[[listaFiltered objectAtIndex:indexPath.row] objectForKey:@"MobilePhone"]];
            street = [NSString stringWithFormat:@"%@ ",[[listaFiltered objectAtIndex:indexPath.row] objectForKey:@"MailingStreet"]];
            city = [NSString stringWithFormat:@"%@ ",[[listaFiltered objectAtIndex:indexPath.row] objectForKey:@"MailingCity"]];
            state = [NSString stringWithFormat:@"%@ ",[[listaFiltered objectAtIndex:indexPath.row] objectForKey:@"MailingState"]];
            postalCode = [NSString stringWithFormat:@"%@ ",[[listaFiltered objectAtIndex:indexPath.row] objectForKey:@"MailingPostalCode"]];
            country = [NSString stringWithFormat:@"%@ ",[[listaFiltered objectAtIndex:indexPath.row] objectForKey:@"MailingCountry"]];
        }
    } else {
        // Tabla principal
        // SE PUSIERON ESPACIOS DESPUES DEL VALOR PARA DETECTAR LOS NULLS Y VACIOS
        name = [NSString stringWithFormat:@"%@ ", [[lista objectAtIndex:indexPath.row] objectForKey:@"Name"]];
        phone = [NSString stringWithFormat:@"%@ ", [[lista objectAtIndex:indexPath.row] objectForKey:@"Phone"]];
        email = [NSString stringWithFormat:@"%@ ", [[lista objectAtIndex:indexPath.row] objectForKey:@"Email"]];
        if ([objeto isEqualToString:@"Lead"]) {
            // Street, City, State, PostalCode, Country
            street = [NSString stringWithFormat:@"%@ ",[[lista objectAtIndex:indexPath.row] objectForKey:@"Street"]];
            city = [NSString stringWithFormat:@"%@ ",[[lista objectAtIndex:indexPath.row] objectForKey:@"City"]];
            state = [NSString stringWithFormat:@"%@ ",[[lista objectAtIndex:indexPath.row] objectForKey:@"Street"]];
            postalCode = [NSString stringWithFormat:@"%@ ",[[lista objectAtIndex:indexPath.row] objectForKey:@"PostalCode"]];
            country = [NSString stringWithFormat:@"%@ ",[[lista objectAtIndex:indexPath.row] objectForKey:@"Country"]];
        } else if ([objeto isEqualToString:@"Contact"]) {
            // MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
            mobilePhone = [NSString stringWithFormat:@"%@ ",[[lista objectAtIndex:indexPath.row] objectForKey:@"MobilePhone"]];
            street = [NSString stringWithFormat:@"%@ ",[[lista objectAtIndex:indexPath.row] objectForKey:@"MailingStreet"]];
            city = [NSString stringWithFormat:@"%@ ",[[lista objectAtIndex:indexPath.row] objectForKey:@"MailingCity"]];
            state = [NSString stringWithFormat:@"%@ ",[[lista objectAtIndex:indexPath.row] objectForKey:@"MailingState"]];
            postalCode = [NSString stringWithFormat:@"%@ ",[[lista objectAtIndex:indexPath.row] objectForKey:@"MailingPostalCode"]];
            country = [NSString stringWithFormat:@"%@ ",[[lista objectAtIndex:indexPath.row] objectForKey:@"MailingCountry"]];
        }
    }
    name = ([name isEqualToString:@"<null> "] || [name isEqualToString:@" "]) ? @"" : name;
    phone = ([phone isEqualToString:@"<null> "] || [phone isEqualToString:@" "]) ? @"" : phone;
    phone = [self cleanTelephone:phone];
    mobilePhone = ([mobilePhone isEqualToString:@"<null> "] || [mobilePhone isEqualToString:@" "]) ? @"" : mobilePhone;
    mobilePhone = [self cleanTelephone:mobilePhone];    
    email = ([email isEqualToString:@"<null> "] || [email isEqualToString:@" "]) ? @"" : email;
    email = [self cleanEmail:email];
    street = ([street isEqualToString:@"<null> "] || [street isEqualToString:@" "]) ? @"" : street;
    city = ([city isEqualToString:@"<null> "] || [city isEqualToString:@" "]) ? @"" : city;
    state = ([state isEqualToString:@"<null> "] || [state isEqualToString:@" "]) ? @"" : state;
    postalCode = ([postalCode isEqualToString:@"<null> "] || [postalCode isEqualToString:@" "]) ? @"" : postalCode;
    country = ([country isEqualToString:@"<null> "] || [country isEqualToString:@" "]) ? @"": country;
    address = [NSString stringWithFormat:@"%@%@%@%@%@",street, city, state, postalCode, country];
    if (![address isEqualToString:@""]) {
        address = [NSString stringWithFormat:@"http://maps.google.com/maps?daddr=%@&saddr=Current Location", address];
        address = [address stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        address = [address stringByReplacingOccurrencesOfString:@"\n" withString:@"+"];    
    }
    
	switch (buttonIndex) {
        case 0: // Add Event
            if ([mobilePhone isEqualToString:@""]) {
                [self createEvent:name Phone:phone Address:address Email:email];
            } else {
                [self createEvent:name Phone:mobilePhone Address:address Email:email];
            }
			break;
        case 1: // Email Now
            [self sendMail:email];
			break;
		case 2: // Call Now
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone]];
            if ([mobilePhone isEqualToString:@""]) {
                [self makeCall:phone];
            } else {
                [self makeCall:mobilePhone];
            }
			break;
        case 3:
            // PREGUNTAMOS DEL LOG CALL
            [self performSelector:@selector(logFacetimeCall) withObject:nil afterDelay:0.0];
            break;
        case 4:
            [self performSelector:@selector(logSkypeCall) withObject:nil afterDelay:0.0];
            break;
		default:
			// They picked cancel
			return;
	}
}

#pragma mark - Action
- (void)createEvent:(NSString *)contactName Phone:(NSString *)contactPhone Address:(NSString *)contactAddress Email:(NSString *)contactEmail {
    /*EventViewController *controller = [[[EventViewController alloc] initWithNibName:@"EventViewController" bundle:nil] autorelease];
    //[self.navigationController pushViewController:controller animated:YES];
    controller.contactName = [NSString stringWithFormat:@"%@", contactName];
    controller.contactPhone = [NSString stringWithFormat:@"%@", contactPhone];
    controller.contactAddress = [NSString stringWithFormat:@"%@", contactAddress];
    [self presentModalViewController:controller animated:YES];*/
    // When add button is pushed, create an EKEventEditViewController to display the event.

    // GENERAMOS EVENTO
    EKEvent *newEvent  = [EKEvent eventWithEventStore:self.eventStore];
    
    newEvent.title = [NSString stringWithFormat:@"Meeting with %@", contactName];
    newEvent.calendar = defaultCalendar;
    contactPhone = [self cleanTelephone:contactPhone];
    newEvent.notes = [NSString stringWithFormat:@""];
    if (![contactPhone isEqualToString:@""]) {
        newEvent.notes = [newEvent.notes stringByAppendingFormat:@"Phone: %@\n\n", contactPhone];
    }
    if (![contactEmail isEqualToString:@""]) {
        newEvent.notes = [newEvent.notes stringByAppendingFormat:@"Email: %@\n\n", contactEmail];
    }
    if (![contactAddress isEqualToString:@""]) {
        newEvent.notes = [newEvent.notes stringByAppendingFormat:@"Address: %@", contactAddress];
    }
    
    // AGREGAMOS UNA ALERTA
    [newEvent addAlarm:[EKAlarm alarmWithRelativeOffset:0]];

	EKEventEditViewController *addController = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
	
	// set the addController's event store to the current event store.
	addController.eventStore = self.eventStore;
    addController.event = newEvent;
	
	// present EventsAddViewController as a modal view controller
	[self presentModalViewController:addController animated:YES];
	
	addController.editViewDelegate = self;
	[addController release];
}

#pragma mark -
#pragma mark EKEventEditViewDelegate

// Overriding EKEventEditViewDelegate method to update event store according to user actions.
- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
	
	NSError *error = nil;
	EKEvent *thisEvent = controller.event;
    NSString *contactId = [NSString stringWithFormat:@"%@",[[listaContacto objectAtIndex:0] valueForKey:@"Id"]];
    contactId = ([contactId isEqualToString:@"(null)"]) ? @"" : contactId;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	switch (action) {
		case EKEventEditViewActionCanceled:
            NSLog(@"Canceled Event from Event Edit Id: %@", contactId);
			break;
			
		case EKEventEditViewActionSaved:
            NSLog(@"Saved Event from Event Edit Id: %@", contactId);
			[controller.eventStore saveEvent:controller.event span:EKSpanThisEvent error:&error];
            // Salvamos el evento en salesforce si el usuario quiere que lo salvemos
            if ([[userDefaults stringForKey:@"kUploadEventId"] isEqualToString:@"SI"]) {
                [self saveEventToSalesforce:thisEvent ContactId:contactId];
            }
			break;
			
		case EKEventEditViewActionDeleted:
            NSLog(@"Deleted Event from Event Edit");
			[controller.eventStore removeEvent:thisEvent span:EKSpanThisEvent error:&error];
			break;
			
		default:
			break;
	}
	// Dismiss the modal view controller
	[controller dismissModalViewControllerAnimated:YES];
	
}


// Set the calendar edited by EKEventEditViewController to our chosen calendar - the default calendar.
- (EKCalendar *)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller {
	EKCalendar *calendarForEdit = self.defaultCalendar;
	return calendarForEdit;
}

#pragma mark - MailComposeController

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)sendMail:(NSString *)email {
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mcvc = [[MFMailComposeViewController alloc] init];
        mcvc.mailComposeDelegate = self;
        [mcvc setToRecipients:[NSArray arrayWithObjects:  [NSString stringWithFormat:@"%@", email], nil]];
        
        if ([origen isEqualToString:@"Salesforce"]) {
            // MOSTRAMOS EL VALOR DE EMAIL DE SALESFORCE
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *email = [KeychainWrapper searchKeychain:@"kEmailId"];
            if (![email isEqualToString:@""]) {
                if ([[userDefaults stringForKey:@"kAddCcId"] isEqualToString:@"SI"]) {
                    NSString *salesforceMail = [NSString stringWithFormat:@"%@", [KeychainWrapper searchKeychain:@"kEmailId"]];
                    if (![salesforceMail isEqualToString:@""]) {
                        [mcvc setBccRecipients:[NSArray arrayWithObjects:  [NSString stringWithFormat:@"%@", salesforceMail], nil]];
                    }
                }
            }        
        }
        
        [mcvc setSubject:@"Contactivity for Salesforce"];
        [mcvc setMessageBody:@"" isHTML:YES];
        mcvc.modalPresentationStyle = UIModalPresentationPageSheet;
        mcvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:mcvc animated:YES];
        [mcvc release];
        
    } else {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce" 
                                                         message:@"Please configure your mail and try again"
                                                        delegate:self
                                               cancelButtonTitle:@"ok"
                                               otherButtonTitles:nil] autorelease];
        [alert show];
    }
}

#pragma mark - Call
- (void)makeCall:(NSString *)telephone {
    NSString *telefono = [NSString stringWithFormat:@"tel://%@", telephone];
	if (![telefono isEqualToString:@"tel://"]) {
        // GUARDAMOS LA HORA DE LA LLAMADA
        callDate = [[NSDate date] retain];
        
        // Creamos el webview para no salir de la app
        UIWebView *webview;
        webview = [[UIWebView alloc] initWithFrame:tableview.frame];
        webview.alpha = 0.0;
        
        // Llamamos el telefono desde un WebView
		[webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:telefono]]];		
		[self.view insertSubview:webview belowSubview:self.view];
        
        // PREGUNTAMOS DEL LOG CALL
        [self performSelector:@selector(logCall) withObject:nil afterDelay:1.0];
    }
}

- (void)logCall {
    // Preguntamos si quieren agregar el Log de la llamada
    // Mandamos nueva alerte
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                       message:@"Log Call to Salesforce?"
                                      delegate:self
                             cancelButtonTitle:@"NO"
                             otherButtonTitles:@"YES", nil];
    [alert show];
    [alert release];
}

- (void)logFacetimeCall {
    // Preguntamos si quieren agregar el Log de la llamada
    // Mandamos nueva alerte
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                       message:@"Log Facetime call to Salesforce?"
                                      delegate:self
                             cancelButtonTitle:@"NO"
                             otherButtonTitles:@"YES", nil];
    [alert show];
    [alert release];
}

- (void)logSkypeCall {
    // Preguntamos si quieren agregar el Log de la llamada
    // Mandamos nueva alerte
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                       message:@"Log Skype call to Salesforce?"
                                      delegate:self
                             cancelButtonTitle:@"NO"
                             otherButtonTitles:@"YES", nil];
    [alert show];
    [alert release];
}

#pragma mark - AlertView

// User pressed button. Retrieve results
-(void) alertView: (UIAlertView*)aView clickedButtonAtIndex: (NSInteger)anIndex {
	if ([aView.message isEqualToString:@"Log Call to Salesforce?"]) {
		if (anIndex == 1) {
            NSString *contactId = [NSString stringWithFormat:@"%@",[[listaContacto objectAtIndex:0] valueForKey:@"Id"]];
            contactId = ([contactId isEqualToString:@"(null)"]) ? @"" : contactId;
            NSString *contactName = [NSString stringWithFormat:@"%@",[[listaContacto objectAtIndex:0] valueForKey:@"Name"]];
            contactName = ([contactName isEqualToString:@"(null)"]) ? @"" : contactName;
            NSString *contactPhone = [NSString stringWithFormat:@"%@",[[listaContacto objectAtIndex:0] valueForKey:@"Phone"]];
            contactPhone = [self cleanTelephone:contactPhone];
            contactPhone = ([contactPhone isEqualToString:@"<null>"]) ? @"" : contactPhone;
            NSString *contactMobilePhone = [NSString stringWithFormat:@"%@",[[listaContacto objectAtIndex:0] valueForKey:@"MobilePhone"]];
            contactMobilePhone = [self cleanTelephone:contactMobilePhone];
            contactMobilePhone = ([contactMobilePhone isEqualToString:@"<null>"]) ? @"" : contactMobilePhone;
            if ([contactMobilePhone isEqualToString:@""]) {
                [self saveCallTaskToSalesforce:callDate ContactId:contactId ContactName:contactName ContactPhone:contactPhone];
            } else {
                [self saveCallTaskToSalesforce:callDate ContactId:contactId ContactName:contactName ContactPhone:contactMobilePhone];
            }
		} else {
            // Liberamos la fecha de llamada
            [callDate release];
        }
	} else if ([aView.message isEqualToString:@"Log Facetime call to Salesforce?"]) {
        // GUARDAMOS LA HORA DE LA LLAMADA
        callDate = [[NSDate date] retain];

		if (anIndex == 1) {
            NSString *contactId = [NSString stringWithFormat:@"%@",[[listaContacto objectAtIndex:0] valueForKey:@"Id"]];
            contactId = ([contactId isEqualToString:@"(null)"]) ? @"" : contactId;
            NSString *contactName = [NSString stringWithFormat:@"%@",[[listaContacto objectAtIndex:0] valueForKey:@"Name"]];
            contactName = ([contactName isEqualToString:@"(null)"]) ? @"" : contactName;
            NSString *contactEmail = [NSString stringWithFormat:@"%@",[[listaContacto objectAtIndex:0] valueForKey:@"Email"]];
            contactEmail = ([contactEmail isEqualToString:@"(null)"]) ? @"" : contactEmail;
            [self saveFacetimeCallTaskToSalesforce:callDate ContactId:contactId ContactName:contactName ContactEmail:contactEmail];
		} else {
            // Liberamos la fecha de llamada
            [callDate release];

            BOOL result = NO;
            NSString *contactEmail = [NSString stringWithFormat:@"%@",[[listaContacto objectAtIndex:0] valueForKey:@"Email"]];
            NSString *facetimeCall = [NSString stringWithFormat:@"facetime://%@", contactEmail];
            result = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:facetimeCall]];
            // SI NO HAY FACETIME INSTALADO, MANDAMOS ALERTA DE ERROR
            if (!result) {
                // Mandamos nueva alerte
                UIAlertView *alert;
                alert = [[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                                   message:@"Please check that your Facetime is active"
                                                  delegate:self
                                         cancelButtonTitle:@"ok"
                                         otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
        }
	} else if ([aView.message isEqualToString:@"Facetime Call uploaded to Salesforce !!"]) {
        if (anIndex == 0) {
            BOOL result = NO;
            NSString *contactEmail = [NSString stringWithFormat:@"%@",[[listaContacto objectAtIndex:0] valueForKey:@"Email"]];
            NSString *facetimeCall = [NSString stringWithFormat:@"facetime://%@", contactEmail];
            result = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:facetimeCall]];
            // SI NO HAY FACETIME INSTALADO, MANDAMOS ALERTA DE ERROR
            if (!result) {
                // Mandamos nueva alerte
                UIAlertView *alert;
                alert = [[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                                   message:@"Please check that your Facetime is active"
                                                  delegate:self
                                         cancelButtonTitle:@"ok"
                                         otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
        }
    } else if ([aView.message isEqualToString:@"Log Skype call to Salesforce?"]) {
        // GUARDAMOS LA HORA DE LA LLAMADA
        callDate = [[NSDate date] retain];
        
		if (anIndex == 1) {
            NSString *contactId = [NSString stringWithFormat:@"%@",[[listaContacto objectAtIndex:0] valueForKey:@"Id"]];
            contactId = ([contactId isEqualToString:@"(null)"]) ? @"" : contactId;
            NSString *contactName = [NSString stringWithFormat:@"%@",[[listaContacto objectAtIndex:0] valueForKey:@"Name"]];
            contactName = ([contactName isEqualToString:@"(null)"]) ? @"" : contactName;
            NSString *contactEmail = [NSString stringWithFormat:@"%@",[[listaContacto objectAtIndex:0] valueForKey:@"Email"]];
            contactEmail = ([contactEmail isEqualToString:@"(null)"]) ? @"" : contactEmail;
            NSString *contactPhone = [NSString stringWithFormat:@"%@",[[listaContacto objectAtIndex:0] valueForKey:@"Phone"]];
            contactPhone = [self cleanTelephone:contactPhone];
            contactPhone = ([contactPhone isEqualToString:@"<null>"]) ? @"" : contactPhone;
            NSString *contactMobilePhone = [NSString stringWithFormat:@"%@",[[listaContacto objectAtIndex:0] valueForKey:@"MobilePhone"]];
            contactMobilePhone = [self cleanTelephone:contactMobilePhone];
            contactMobilePhone = ([contactMobilePhone isEqualToString:@"<null>"]) ? @"" : contactMobilePhone;
            if ([contactMobilePhone isEqualToString:@""]) {
                [self saveSkypeCallTaskToSalesforce:callDate ContactId:contactId ContactName:contactName ContactPhone:contactPhone];
            } else {
                [self saveSkypeCallTaskToSalesforce:callDate ContactId:contactId ContactName:contactName ContactPhone:contactMobilePhone];
            }
		} else {
            // Liberamos la fecha de llamada
            [callDate release];
            
            BOOL result = NO;
            NSString *contactPhone = [NSString stringWithFormat:@"%@",[[listaContacto objectAtIndex:0] valueForKey:@"Phone"]];
            contactPhone = ([contactPhone isEqualToString:@"<null>"]) ? @"" : contactPhone;
            NSString *contactMobilePhone = [NSString stringWithFormat:@"%@",[[listaContacto objectAtIndex:0] valueForKey:@"MobilePhone"]];
            contactMobilePhone = ([contactMobilePhone isEqualToString:@"<null>"]) ? @"" : contactMobilePhone;

            if ([contactMobilePhone isEqualToString:@""]) {
                result = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"skype://%@?call", contactPhone]]];
            } else {
                result = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"skype://%@?call", contactMobilePhone]]];
            }
            
            // SI NO HAY SKYPE INSTALADO, MANDAMOS ALERTA DE ERROR
            if (!result) {
                // Mandamos nueva alerte
                UIAlertView *alert;
                alert = [[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                                   message:@"Please install Skype from AppStore"
                                                  delegate:self
                                         cancelButtonTitle:@"ok"
                                         otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
        }
	} else if ([aView.message isEqualToString:@"Skype Call uploaded to Salesforce !!"]) {
        if (anIndex == 0) {
            BOOL result = NO;
            NSString *contactPhone = [NSString stringWithFormat:@"%@",[[listaContacto objectAtIndex:0] valueForKey:@"Phone"]];
            contactPhone = ([contactPhone isEqualToString:@"<null>"]) ? @"" : contactPhone;
            NSString *contactMobilePhone = [NSString stringWithFormat:@"%@",[[listaContacto objectAtIndex:0] valueForKey:@"MobilePhone"]];
            contactMobilePhone = ([contactMobilePhone isEqualToString:@"<null>"]) ? @"" : contactMobilePhone;
            
            if ([contactMobilePhone isEqualToString:@""]) {
                result = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"skype://%@?call", contactPhone]]];
            } else {
                result = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"skype://%@?call", contactMobilePhone]]];
            }
            
            // SI NO HAY SKYPE INSTALADO, MANDAMOS ALERTA DE ERROR
            if (!result) {
                // Mandamos nueva alerte
                UIAlertView *alert;
                alert = [[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                                   message:@"Please install Skype from AppStore"
                                                  delegate:self
                                         cancelButtonTitle:@"ok"
                                         otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
        }
    }
}

#pragma mark - Address Book

- (void)readFromAddressBook:(NSString *)viewDidLoad {
    
    // Borramos objetos de lista
    [listaQuery removeAllObjects];
    [listaObjeto removeAllObjects];

    ABAddressBookRef addressBook = ABAddressBookCreate( );
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
    CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
    
    for ( int i = 0; i < nPeople; i++ ) {
        ABMultiValueRef aMultiValue;
        NSString *name = @"";
        NSString *firstName = @"";
        NSString *lastName = @"";
        NSString *phone = @"";
        NSString *address = @"";
        NSString *email = @"";
        NSString *street = @"";
        NSString *city = @"";
        NSString *state = @"";
        NSString *postalCode = @"";
        NSString *country = @"";
        
        ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, i );
        firstName = [NSString stringWithFormat:@"%@", ABRecordCopyValue(ref, kABPersonFirstNameProperty)];
        firstName = ([firstName isEqualToString:@"(null)"]) ? @"" : firstName;
        lastName = [NSString stringWithFormat:@"%@", ABRecordCopyValue(ref, kABPersonLastNameProperty)];
        lastName = ([lastName isEqualToString:@"(null)"]) ? @"" : lastName;
        name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        
        // OBTENEMOS EL TELEFONO
        aMultiValue = (ABRecordCopyValue(ref, kABPersonPhoneProperty));
        if (ABMultiValueGetCount(aMultiValue)) {
            // TRAEMOS TODOS LOS TELEFONOS DEL USUARIO
            CFArrayRef numArray = ABMultiValueCopyArrayOfAllValues(aMultiValue);
            for (int j=0; j < CFArrayGetCount(numArray); j++) {
                NSString *labelString = (NSString *)ABMultiValueCopyLabelAtIndex(aMultiValue, j);
                // BUSCAMOS TELEFONO DE TRABAJO Y MOBILE
                NSRange rangeWork = [labelString rangeOfString:@"Work"];
                NSRange rangeMobile = [labelString rangeOfString:@"Mobile"];
                if (rangeMobile.length > 0 || rangeWork.length > 0) {
                    // LIMPIAMOS EL TELEFONO
                    phone = @"";
                    // OBTENEMOS EL NUMERO DE TELEFONO INDIVIDUAL
                    NSArray *numTel = [(NSString *)ABMultiValueCopyValueAtIndex(ABRecordCopyValue(ref, kABPersonPhoneProperty), j) componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
                    // LIMPIAMOS EL NÚMERO DE TELÉFONO DEL FORMATO ACTUAL
                    for (int k=0; k < [numTel count]; k++) {
                        if ([numTel objectAtIndex:k] != nil) {
                            phone = [phone stringByAppendingString:[numTel objectAtIndex:k]];
                        }
                    }
                    // SALIMOS SI YA ENCONTRAMOS EL MOVIL SINO, PONEMOS EL DEL TRABAJO
                    if (rangeMobile.length > 0 && ![phone isEqualToString:@""]) {
                        break;
                    }                
                }
            }
        }
        
        // OBTENEMOS EL EMAIL
        aMultiValue = (ABRecordCopyValue(ref, kABPersonEmailProperty));
        if (ABMultiValueGetCount(aMultiValue)) {
            // TRAEMOS TODOS LOS TELEFONOS DEL USUARIO
            CFArrayRef numArray = ABMultiValueCopyArrayOfAllValues(aMultiValue);
            for (int j=0; j < CFArrayGetCount(numArray); j++) {
                NSString *labelString = (NSString *)ABMultiValueCopyLabelAtIndex(aMultiValue, j);
                // BUSCAMOS EMAIL DE TRABAJO Y HOME
                NSRange rangeWork = [labelString rangeOfString:@"Work"];
                NSRange rangeMobile = [labelString rangeOfString:@"Home"];
                if (rangeMobile.length > 0 || rangeWork.length > 0) {
                    // OBTENEMOS EL EMAIL INDIVIDUAL
                    email = [NSString stringWithFormat:@"%@", (NSString *)ABMultiValueCopyValueAtIndex(ABRecordCopyValue(ref, kABPersonEmailProperty), j)];
                    // SALIMOS SI YA ENCONTRAMOS EL DEL TRABAJO
                    if (rangeWork.length > 0 && ![email isEqualToString:@""]) {
                        break;
                    }                
                }
            }
        }
        
        // OBTENEMOS LA DIRECCIÓN
        aMultiValue = (ABRecordCopyValue(ref, kABPersonAddressProperty));
        if (ABMultiValueGetCount(aMultiValue)) {
            // TRAEMOS TODOS LAS DIRECCIONES DEL USUARIO
            CFArrayRef numArray = ABMultiValueCopyArrayOfAllValues(aMultiValue);
            for (int j=0; j < CFArrayGetCount(numArray); j++) {
                NSString *labelString = (NSString *)ABMultiValueCopyLabelAtIndex(aMultiValue, j);
                // BUSCAMOS DIRECCION DE TRABAJO Y HOME
                NSRange rangeWork = [labelString rangeOfString:@"Work"];
                NSRange rangeMobile = [labelString rangeOfString:@"Home"];
                if (rangeMobile.length > 0 || rangeWork.length > 0) {
                    // OBTENEMOS EL EMAIL INDIVIDUAL
                    NSMutableArray *mutable = [NSMutableArray arrayWithObject:ABMultiValueCopyValueAtIndex(aMultiValue, j)];
                    street = [NSString stringWithFormat:@"%@",[[mutable objectAtIndex:0] objectForKey:@"Street"]];
                    city = [NSString stringWithFormat:@"%@",[[mutable objectAtIndex:0] objectForKey:@"City"]];
                    state = [NSString stringWithFormat:@"%@",[[mutable objectAtIndex:0] objectForKey:@"State"]];
                    postalCode = [NSString stringWithFormat:@"%@",[[mutable objectAtIndex:0] objectForKey:@"ZIP"]];
                    country = [NSString stringWithFormat:@"%@",[[mutable objectAtIndex:0] objectForKey:@"Country"]];
                    address = [NSString stringWithFormat:@"%@ %@ %@ %@ %@", street, city, state, postalCode, country];

                    // SALIMOS SI YA ENCONTRAMOS EL DEL TRABAJO
                    if (rangeWork.length > 0 && ![address isEqualToString:@""]) {
                        break;
                    }                
                }
            }
        }
        
        // Obtenemos la imagen
        NSData *imageData = [(NSData *)ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail) autorelease];
        UIImage *image = [UIImage imageWithData:imageData];
        
        NSDictionary *contacto = [[[NSDictionary alloc] initWithObjectsAndKeys:name, @"Name", phone, @"Phone", @"<null>", @"MobilePhone",email, @"Email", street, @"MailingStreet", city, @"MailingCity", state, @"MailingState", postalCode, @"MailingPostalCode", country, @"MailingCountry", image, @"Photo", nil] autorelease];
        
        if ([viewDidLoad isEqualToString:@"SI"]) {
            [lista addObject:contacto];
        } else {
            [listaQuery addObject:contacto];
        }
    }
}

- (void)saveEventToSalesforce:(EKEvent*)event ContactId:(NSString*)contactId {
    NSString *userId = [KeychainWrapper searchKeychain:@"kUserId"];
    
    //set Date formatter
    NSTimeInterval startDateSeconds = [event.startDate timeIntervalSince1970];
    NSTimeInterval endDateSeconds = [event.endDate timeIntervalSince1970];
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:startDateSeconds];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:endDateSeconds];
    
    NSDateFormatter* df_utc = [[[NSDateFormatter alloc] init] autorelease];
    [df_utc setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [df_utc setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000'Z'"];
    
    NSString *startDateString = [df_utc stringFromDate:startDate];
    NSString *endDateString = [df_utc stringFromDate:endDate];
    
    // Demas campos
    NSString *ownerId = [NSString stringWithFormat:@"%@",userId];
    NSString *whoId = [NSString stringWithFormat:@"%@",contactId];
    NSString *subject = [NSString stringWithFormat:@"%@",event.title];
    NSString *location = [NSString stringWithFormat:@"%@",event.location];
    location = ([location isEqualToString:@"(null)"]) ? @"" : location;
    NSString *description = [NSString stringWithFormat:@"%@",event.notes];
    description = ([description isEqualToString:@"(null)"]) ? @"" : description;
    NSString *isPrivate = [NSString stringWithFormat:@"%@",@"false"];

    // Subimos a Event
    NSDictionary *tmpDict = [[[NSDictionary alloc] initWithObjectsAndKeys:
                              ownerId, @"OwnerId",
                              whoId, @"WhoId",
                              subject, @"Subject",
                              location, @"Location",
                              description, @"Description",
                              isPrivate, @"IsPrivate",
                              startDateString, @"StartDateTime",
                              endDateString, @"EndDateTime",
                              nil] autorelease];

    if (_reloadWithAlert) {
        // Mesaje de bajando informacion
        baseAlert = [[[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                                message:@"Uploading Event information..."
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
    
    // Limpiamos el objeto
    [listaObjeto removeAllObjects];
    
    // Llenamos el objeto
    NSDictionary *obj = [[[NSDictionary alloc] initWithObjectsAndKeys:@"Event", @"QueryObject", nil] autorelease];
    [listaObjeto addObject:obj];
    
    SFRestRequest *request;
    request = [[SFRestAPI sharedInstance] requestForCreateWithObjectType:@"Event" fields:tmpDict];
    
    //in our sample app, once a delete is done, we are done, thus no delegate callback
    [[SFRestAPI sharedInstance] send:request delegate:self];
}

- (void)saveCallTaskToSalesforce:(NSDate*)date ContactId:(NSString*)contactId ContactName:(NSString*)contactName ContactPhone:(NSString*)contactPhone {
    //set Date formatter
    NSDateFormatter* df_utc = [[[NSDateFormatter alloc] init] autorelease];
    [df_utc setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [df_utc setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000'Z'"];
    NSString *callDateString = [df_utc stringFromDate:callDate];
    
    NSDateFormatter* df_utc2 = [[[NSDateFormatter alloc] init] autorelease];
    [df_utc2 setDateFormat:@"MM-dd-yyyy HH:mm a"];
    NSString *callStartDateString = [df_utc2 stringFromDate:callDate];
    NSString *callEndDateString = [df_utc2 stringFromDate:[NSDate date]];

    [callDate release];

    NSString *userId = [KeychainWrapper searchKeychain:@"kUserId"];
    
    // Demas campos
    NSString *ownerId = [NSString stringWithFormat:@"%@",userId];
    NSString *whoId = [NSString stringWithFormat:@"%@",contactId];
    NSString *whatId = [NSString stringWithFormat:@"%@",opportunity];
    whatId = ([whatId isEqualToString:@"(null)"]) ? @"" : whatId;
    NSString *subject = [NSString stringWithFormat:@"Call to %@",contactName];
    NSString *description = [NSString stringWithFormat:@"Phone number %@\n\nCall start time: %@\nCall end time:  %@\n\nfrom Contactivity for Salesforce",contactPhone, callStartDateString, callEndDateString];
    
    // Subimos a Event
    NSDictionary *tmpDict = [[[NSDictionary alloc] initWithObjectsAndKeys:
                              ownerId, @"OwnerId",
                              whoId, @"WhoId",
                              whatId, @"WhatId",
                              subject, @"Subject",
                              description, @"Description",
                              callDateString, @"ActivityDate",
                              nil] autorelease];
    
    if (_reloadWithAlert) {
        // Mesaje de bajando informacion
        baseAlert = [[[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                                message:@"Uploading Call information..."
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
    
    // Limpiamos el objeto
    [listaObjeto removeAllObjects];
    
    // Llenamos el objeto
    NSDictionary *obj = [[[NSDictionary alloc] initWithObjectsAndKeys:@"Task", @"QueryObject", nil] autorelease];
    [listaObjeto addObject:obj];
    
    SFRestRequest *request;
    request = [[SFRestAPI sharedInstance] requestForCreateWithObjectType:@"Task" fields:tmpDict];
    
    //in our sample app, once a delete is done, we are done, thus no delegate callback
    [[SFRestAPI sharedInstance] send:request delegate:self];
}

- (void)saveFacetimeCallTaskToSalesforce:(NSDate*)date ContactId:(NSString*)contactId ContactName:(NSString*)contactName ContactEmail:(NSString*)contactEmail {
    //set Date formatter
    NSDateFormatter* df_utc = [[[NSDateFormatter alloc] init] autorelease];
    [df_utc setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [df_utc setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000'Z'"];
    NSString *callDateString = [df_utc stringFromDate:callDate];
    
    NSDateFormatter* df_utc2 = [[[NSDateFormatter alloc] init] autorelease];
    [df_utc2 setDateFormat:@"MM-dd-yyyy HH:mm a"];
    NSString *callStartDateString = [df_utc2 stringFromDate:callDate];
    
    [callDate release];
    
    NSString *userId = [KeychainWrapper searchKeychain:@"kUserId"];
    
    // Demas campos
    NSString *ownerId = [NSString stringWithFormat:@"%@",userId];
    NSString *whoId = [NSString stringWithFormat:@"%@",contactId];
    NSString *whatId = [NSString stringWithFormat:@"%@",opportunity];
    whatId = ([whatId isEqualToString:@"(null)"]) ? @"" : whatId;
    NSString *subject = [NSString stringWithFormat:@"Facetime Call to %@",contactName];
    NSString *description = [NSString stringWithFormat:@"Email address %@\n\nCall start time: %@\n\nfrom Contactivity for Salesforce",contactEmail, callStartDateString];
    
    // Subimos a Event
    NSDictionary *tmpDict = [[[NSDictionary alloc] initWithObjectsAndKeys:
                              ownerId, @"OwnerId",
                              whoId, @"WhoId",
                              whatId, @"WhatId",
                              subject, @"Subject",
                              description, @"Description",
                              callDateString, @"ActivityDate",
                              nil] autorelease];
    
    if (_reloadWithAlert) {
        // Mesaje de bajando informacion
        baseAlert = [[[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                                message:@"Uploading Facetime Call information..."
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
    
    // Limpiamos el objeto
    [listaObjeto removeAllObjects];
    
    // Llenamos el objeto
    NSDictionary *obj = [[[NSDictionary alloc] initWithObjectsAndKeys:@"Task", @"QueryObject", @"Facetime", @"Type", nil] autorelease];
    [listaObjeto addObject:obj];
    
    SFRestRequest *request;
    request = [[SFRestAPI sharedInstance] requestForCreateWithObjectType:@"Task" fields:tmpDict];
    
    //in our sample app, once a delete is done, we are done, thus no delegate callback
    [[SFRestAPI sharedInstance] send:request delegate:self];
}

- (void)saveSkypeCallTaskToSalesforce:(NSDate*)date ContactId:(NSString*)contactId ContactName:(NSString*)contactName ContactPhone:(NSString*)contactPhone {
    //set Date formatter
    NSDateFormatter* df_utc = [[[NSDateFormatter alloc] init] autorelease];
    [df_utc setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [df_utc setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.000'Z'"];
    NSString *callDateString = [df_utc stringFromDate:callDate];
    
    NSDateFormatter* df_utc2 = [[[NSDateFormatter alloc] init] autorelease];
    [df_utc2 setDateFormat:@"MM-dd-yyyy HH:mm a"];
    NSString *callStartDateString = [df_utc2 stringFromDate:callDate];
    
    [callDate release];
    
    NSString *userId = [KeychainWrapper searchKeychain:@"kUserId"];
    
    // Demas campos
    NSString *ownerId = [NSString stringWithFormat:@"%@",userId];
    NSString *whoId = [NSString stringWithFormat:@"%@",contactId];
    NSString *whatId = [NSString stringWithFormat:@"%@",opportunity];
    whatId = ([whatId isEqualToString:@"(null)"]) ? @"" : whatId;
    NSString *subject = [NSString stringWithFormat:@"Skype Call to %@",contactName];
    NSString *description = [NSString stringWithFormat:@"Phone number %@\n\nCall start time: %@\n\nfrom Contactivity for Salesforce",contactPhone, callStartDateString];
    
    // Subimos a Event
    NSDictionary *tmpDict = [[[NSDictionary alloc] initWithObjectsAndKeys:
                              ownerId, @"OwnerId",
                              whoId, @"WhoId",
                              whatId, @"WhatId",
                              subject, @"Subject",
                              description, @"Description",
                              callDateString, @"ActivityDate",
                              nil] autorelease];
    
    if (_reloadWithAlert) {
        // Mesaje de bajando informacion
        baseAlert = [[[UIAlertView alloc] initWithTitle:@"Contactivity for Salesforce"
                                                message:@"Uploading Skype Call information..."
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
    
    // Limpiamos el objeto
    [listaObjeto removeAllObjects];
    
    // Llenamos el objeto
    NSDictionary *obj = [[[NSDictionary alloc] initWithObjectsAndKeys:@"Task", @"QueryObject", @"Skype", @"Type", nil] autorelease];
    [listaObjeto addObject:obj];
    
    SFRestRequest *request;
    request = [[SFRestAPI sharedInstance] requestForCreateWithObjectType:@"Task" fields:tmpDict];
    
    //in our sample app, once a delete is done, we are done, thus no delegate callback
    [[SFRestAPI sharedInstance] send:request delegate:self];
}

- (IBAction)showSettings:(id)sender {
    SettingsViewController *controller = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    [self presentModalViewController:controller animated:YES];
}

- (void)loadTip {
    // Mostramos el TIP
    if (!_tipShowing) {
        NSString *tip = [NSString stringWithFormat:@"%@", [[listaTips objectAtIndex:(arc4random()%([listaTips count]-1))] objectForKey:@"Tip"]];
        [tipMessage setText:tip];
        
        self.tipMessageView.backgroundColor = [UIColor clearColor];
        
        // ENTRADA DE ANUNCIO
        [tipMessageView setFrame:CGRectMake(5,390,314,42)];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.0];
        [self.tipMessageView removeFromSuperview];
        [self.view addSubview:tipMessageView];
        [tipMessageView setFrame:CGRectMake(5,328,314,42)];
        [UIView commitAnimations];
        
        _tipShowing = YES;
    }
}

- (void)closeTip {
    // SALIDA DE ANUNCIO
    if (_tipShowing) {
        [tipMessageView setFrame:CGRectMake(5,328,314,42)];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.0];
        [self.view addSubview:tipMessageView];
        [tipMessageView setFrame:CGRectMake(5,390,314,42)];
        [UIView commitAnimations];
        
        _tipShowing = NO;    
    }
}

- (void)customSearchBars {
    // Transparent search bar
    [tableview setBackgroundColor:[UIColor clearColor]];
    
    for (UIView *subview in self.searchDisplayController.searchBar.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 49)];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:bgView.frame];
            [imageView setImage:[UIImage imageNamed:@"searchBarBkg.png"]];
            [bgView addSubview:imageView];
            [subview addSubview:bgView];
            [imageView release];
            [bgView release];
            break;
        }
    }
}


@end
