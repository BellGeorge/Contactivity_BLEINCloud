//
//  CalendarKalViewController.m
//  Contactivity
//
//  Created by Erik Solis on 5/17/12.
//  Copyright (c) 2012 Tu Mundo App. All rights reserved.
//

#import "CalendarKalViewController.h"
#import "EventKitDataSource.h"
#import "Kal.h"

#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface CalendarKalViewController ()

@end

@implementation CalendarKalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    /*
     *    Kal Initialization
     *
     * When the calendar is first displayed to the user, Kal will automatically select today's date.
     * If your application requires an arbitrary starting date, use -[KalViewController initWithSelectedDate:]
     * instead of -[KalViewController init].
     */
    kal = [[KalViewController alloc] init];
    //kal.title = @"NativeCal";
    
    /*
     *    Kal Configuration
     *
     */
    // SOLEES
    //kal.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStyleBordered target:self action:@selector(showAndSelectToday)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Today" style:UIBarButtonItemStyleBordered target:self action:@selector(showAndSelectToday)] autorelease];
    // Change Logo
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"headerBar.png"] forBarMetrics:UIBarMetricsDefault];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contactivityHeader.png"]];
    [imageView setFrame:CGRectMake(self.navigationController.navigationBar.bounds.size.width/2 - imageView.bounds.size.width/2 , self.navigationController.navigationBar.bounds.size.height/2 - imageView.bounds.size.height/2, 138, 44)];
    [self.navigationController.navigationBar addSubview:imageView];
    [imageView release];
    
    // Change buttons color
    NSArray *buttons = [self.navigationController.navigationBar subviews];
    for (NSObject *object in buttons) {
        //NSLog(@"%@", [object class]);
        if ([object isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)object;
            //NSLog(@"%@", [button titleLabel]);
            if ([[button currentTitle] isEqualToString:@"Today"] || [[button currentTitle] isEqualToString:@"Hoy"]) {
                [button setTintColor:[UIColor colorWithRed:10.0f/255.0f green:30.0f/255.0f blue:81.0f/255.0f alpha:1.0f]];
            }
        }
    }
    
    kal.delegate = self;
    dataSource = [[EventKitDataSource alloc] init];
    kal.dataSource = dataSource;
    
    // Hacemos visible el calendario
    [self.view addSubview:kal.view];

}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    // Change Logo
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"headerBar.png"] forBarMetrics:UIBarMetricsDefault];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contactivityHeader.png"]];
    [imageView setFrame:CGRectMake(self.navigationController.navigationBar.bounds.size.width/2 - imageView.bounds.size.width/2 , self.navigationController.navigationBar.bounds.size.height/2 - imageView.bounds.size.height/2, 138, 44)];
    [self.navigationController.navigationBar addSubview:imageView];
    [imageView release];

    // Change buttons color
    NSArray *buttons = [self.navigationController.navigationBar subviews];
    for (NSObject *object in buttons) {
        //NSLog(@"%@", [object class]);
        if ([object isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)object;
            //NSLog(@"%@", [button titleLabel]);
            if ([[button currentTitle] isEqualToString:@"Today"] || [[button currentTitle] isEqualToString:@"Hoy"]) {
                [button setTintColor:[UIColor colorWithRed:10.0f/255.0f green:30.0f/255.0f blue:81.0f/255.0f alpha:1.0f]];
            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    // Change Logo
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"headerBar.png"] forBarMetrics:UIBarMetricsDefault];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contactivityHeader.png"]];
    [imageView setFrame:CGRectMake(self.navigationController.navigationBar.bounds.size.width/2 - imageView.bounds.size.width/2 , self.navigationController.navigationBar.bounds.size.height/2 - imageView.bounds.size.height/2, 138, 44)];
    [self.navigationController.navigationBar addSubview:imageView];
    [imageView release];
    
    // Change buttons color
    NSArray *buttons = [self.navigationController.navigationBar subviews];
    for (NSObject *object in buttons) {
        //NSLog(@"%@", [object class]);
        if ([object isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)object;
            //NSLog(@"%@", [button titleLabel]);
            if ([[button currentTitle] isEqualToString:@"Today"] || [[button currentTitle] isEqualToString:@"Hoy"]) {
                [button setTintColor:[UIColor colorWithRed:10.0f/255.0f green:30.0f/255.0f blue:81.0f/255.0f alpha:1.0f]];
            }
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Action handler for the navigation bar's right bar button item.
- (void)showAndSelectToday {
    [kal showAndSelectDate:[NSDate date]];
}

#pragma mark UITableViewDelegate protocol conformance

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Display a details screen for the selected event/row.
    EKEventViewController *vc = [[[EKEventViewController alloc] init] autorelease];
    vc.event = [dataSource eventAtIndexPath:indexPath];
    vc.allowsEditing = YES;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -
#pragma mark EKEventViewDelegate

- (void)eventViewController:(EKEventViewController *)controller didCompleteWithAction:(EKEventViewAction)action {
	//EKEvent *thisEvent = controller.event;
 	switch (action) {
		case EKEventViewActionDone:
            NSLog(@"Done");
			break;
			
		case EKEventViewActionDeleted:
            NSLog(@"Deleted Event");
			break;
			
		case EKEventViewActionResponded:
            NSLog(@"Responded");
			break;
			
		default:
			break;
	}
	// Dismiss the modal view controller
	[controller.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -

- (void)dealloc
{
    [kal release];
    [dataSource release];
    [super dealloc];
}

@end
