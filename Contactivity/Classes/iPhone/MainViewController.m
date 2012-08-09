//
//  MainViewController.m
//  Contactivity
//
//  Created by Erik Solis on 4/10/12.
//  Copyright (c) 2012 Tu Mundo App. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize navBar = _navBar;
@synthesize vc1, vc2, vc3, vc4, vc5;

- (void)dealloc {
    [_window release];
    [_tabBarController release];
    [_navBar release];
    [vc1 release];
    [vc2 release];
    [vc3 release];
    [vc4 release];
    [vc5 release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Inicializamos el scroll
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    vc1 = [[CalendarKalViewController alloc] initWithNibName:@"CalendarKalViewController" bundle:nil];
    vc1.title = NSLocalizedString(@"Calendar", @"Calendar");
    vc1.tabBarItem.image = [UIImage imageNamed:@"calendar.png"];
    UINavigationController *calendarView = [[[UINavigationController alloc] initWithRootViewController:vc1] autorelease];
    //calendarView.tabBarItem.title = @"Calendar";
    [calendarView.navigationBar setBackgroundImage:[UIImage imageNamed:@"headerBar.png"] forBarMetrics:UIBarMetricsDefault];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contactivityHeader.png"]];
    [imageView setFrame:CGRectMake(calendarView.navigationBar.bounds.size.width/2 - imageView.bounds.size.width/2 , calendarView.navigationBar.bounds.size.height/2 - imageView.bounds.size.height/2, 138, 44)];
    [calendarView.navigationBar addSubview:imageView];
    [imageView release];

    vc2 = [[SalesforceViewController alloc] initWithNibName:@"SalesforceViewController" bundle:nil];
    vc2.objeto = [NSString stringWithFormat:@"%@",@"Contact"];
    vc2.titulo = [NSString stringWithFormat:@"%@",@"Address Book"];
    vc2.origen = [NSString stringWithFormat:@"%@",@"Local"];
    vc2.shouldReturn = [NSString stringWithFormat:@"%@",@"NO"];
    vc2.accountId = [NSString stringWithFormat:@"%@",@""];
    vc2.title = NSLocalizedString(@"Address Book", @"Address Book");
    vc2.tabBarItem.image = [UIImage imageNamed:@"addressBook.png"];
    UINavigationController *addressView = [[[UINavigationController alloc] initWithRootViewController:vc2] autorelease];
    [addressView.navigationBar setBackgroundImage:[UIImage imageNamed:@"headerBar.png"] forBarMetrics:UIBarMetricsDefault];
    
    vc3 = [[SalesforceViewController alloc] initWithNibName:@"SalesforceViewController" bundle:nil];
    vc3.objeto = [NSString stringWithFormat:@"%@",@"Contact"];
    vc3.titulo = [NSString stringWithFormat:@"%@",@"Contacts in Salesforce"];
    vc3.origen = [NSString stringWithFormat:@"%@",@"Salesforce"];
    vc3.shouldReturn = [NSString stringWithFormat:@"%@",@"NO"];
    vc3.accountId = [NSString stringWithFormat:@"%@",@""];
    vc3.opportunity = [NSString stringWithFormat:@"%@",@""];
    vc3.title = NSLocalizedString(@"Contacts", @"Contacts");
    vc3.tabBarItem.image = [UIImage imageNamed:@"contacts.png"];
    UINavigationController *contactView = [[[UINavigationController alloc] initWithRootViewController:vc3] autorelease];
    [contactView.navigationBar setBackgroundImage:[UIImage imageNamed:@"headerBar.png"] forBarMetrics:UIBarMetricsDefault];
    
    vc4 = [[SalesforceViewController alloc] initWithNibName:@"SalesforceViewController" bundle:nil];
    vc4.objeto = [NSString stringWithFormat:@"%@",@"Lead"];
    vc4.titulo = [NSString stringWithFormat:@"%@",@"Leads in Salesforce"];
    vc4.origen = [NSString stringWithFormat:@"%@",@"Salesforce"];
    vc4.shouldReturn = [NSString stringWithFormat:@"%@",@"NO"];
    vc4.accountId = [NSString stringWithFormat:@"%@",@""];
    vc4.opportunity = [NSString stringWithFormat:@"%@",@""];
    vc4.title = NSLocalizedString(@"Leads", @"Leads");
    vc4.tabBarItem.image = [UIImage imageNamed:@"leads.png"];
    UINavigationController *leadView = [[[UINavigationController alloc] initWithRootViewController:vc4] autorelease];
    [leadView.navigationBar setBackgroundImage:[UIImage imageNamed:@"headerBar.png"] forBarMetrics:UIBarMetricsDefault];
    
    vc5 = [[SalesforceViewController alloc] initWithNibName:@"SalesforceViewController" bundle:nil];
    vc5.objeto = [NSString stringWithFormat:@"%@",@"Opportunity"];
    vc5.titulo = [NSString stringWithFormat:@"%@",@"Opportunities in Salesforce"];
    vc5.origen = [NSString stringWithFormat:@"%@",@"Salesforce"];
    vc5.shouldReturn = [NSString stringWithFormat:@"%@",@"NO"];
    vc5.accountId = [NSString stringWithFormat:@"%@",@""];
    vc5.opportunity = [NSString stringWithFormat:@"%@",@""];
    vc5.title = NSLocalizedString(@"Opportunities", @"Opportunities");
    vc5.tabBarItem.image = [UIImage imageNamed:@"opportunities.png"];
    UINavigationController *oppView = [[[UINavigationController alloc] initWithRootViewController:vc5] autorelease];
    [oppView.navigationBar setBackgroundImage:[UIImage imageNamed:@"headerBar.png"] forBarMetrics:UIBarMetricsDefault];

    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:calendarView, addressView, contactView, leadView, oppView, nil];
    self.window.rootViewController = self.tabBarController;
    self.tabBarController.delegate = self;

    [self.window makeKeyAndVisible];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Tab Bar Controller

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}

@end
