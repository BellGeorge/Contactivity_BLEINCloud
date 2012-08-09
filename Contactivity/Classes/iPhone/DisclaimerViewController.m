//
//  DisclaimerViewController.m
//  Contactivity
//
//  Created by Erik Solis on 6/7/12.
//  Copyright (c) 2012 Tu Mundo App. All rights reserved.
//

#import "DisclaimerViewController.h"
#import "QuartzCore/QuartzCore.h"

@interface DisclaimerViewController ()

@end

@implementation DisclaimerViewController

@synthesize navBar, imageView, scrollView;

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
        
    // Appereance
    UIImage *topBGImage = [UIImage imageNamed:@"headerBar.png"];
    [self.navBar setBackgroundImage:topBGImage forBarMetrics:UIBarMetricsDefault];
    
    NSArray *buttons = [self.navBar subviews];
    for (NSObject *object in buttons) {
        if ([object isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)object;
            if ([[button currentTitle] isEqualToString:@"Cancel"] || [[button currentTitle] isEqualToString:@"Cancelar"]) {
                [button setTintColor:[UIColor colorWithRed:10.0f/255.0f green:30.0f/255.0f blue:81.0f/255.0f alpha:1.0f]];
            } else if ([[button currentTitle] isEqualToString:@"Send"] || [[button currentTitle] isEqualToString:@"Enviar"]) {
                [button setTintColor:[UIColor colorWithRed:10.0f/255.0f green:30.0f/255.0f blue:81.0f/255.0f alpha:1.0f]];
            } else if ([[button currentTitle] isEqualToString:@"Close"] || [[button currentTitle] isEqualToString:@"Cerrar"]) {
                [button setTintColor:[UIColor colorWithRed:10.0f/255.0f green:30.0f/255.0f blue:81.0f/255.0f alpha:1.0f]];
            } else if ([[button currentTitle] isEqualToString:@"New Case"] || [[button currentTitle] isEqualToString:@"Nuevo Caso"]) {
                [button setTintColor:[UIColor colorWithRed:10.0f/255.0f green:30.0f/255.0f blue:81.0f/255.0f alpha:1.0f]];
            }
        }
    }
    
    // BGViews
    imageView.layer.cornerRadius = 10;
    
    // Inicializamos el scroll
    CGRect scrollFrame;
	scrollFrame.origin.x = 0;
	scrollFrame.origin.y = 0;
	scrollFrame.size.width = self.scrollView.bounds.size.width;
    scrollFrame.size.height = self.scrollView.bounds.size.height + 340;
	scrollView.contentSize = scrollFrame.size;
	scrollView.bounces = YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [imageView release];
    [navBar release];
}

- (void)viewDidAppear:(BOOL)animated {
    // Appereance
    UIImage *topBGImage = [UIImage imageNamed:@"headerBar.png"];
    [self.navBar setBackgroundImage:topBGImage forBarMetrics:UIBarMetricsDefault];
    
    NSArray *buttons = [self.navBar subviews];
    for (NSObject *object in buttons) {
        if ([object isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)object;
            if ([[button currentTitle] isEqualToString:@"Cancel"] || [[button currentTitle] isEqualToString:@"Cancelar"]) {
                [button setTintColor:[UIColor colorWithRed:10.0f/255.0f green:30.0f/255.0f blue:81.0f/255.0f alpha:1.0f]];
            } else if ([[button currentTitle] isEqualToString:@"Send"] || [[button currentTitle] isEqualToString:@"Enviar"]) {
                [button setTintColor:[UIColor colorWithRed:10.0f/255.0f green:30.0f/255.0f blue:81.0f/255.0f alpha:1.0f]];
            } else if ([[button currentTitle] isEqualToString:@"Close"] || [[button currentTitle] isEqualToString:@"Cerrar"]) {
                [button setTintColor:[UIColor colorWithRed:10.0f/255.0f green:30.0f/255.0f blue:81.0f/255.0f alpha:1.0f]];
            } else if ([[button currentTitle] isEqualToString:@"New Case"] || [[button currentTitle] isEqualToString:@"Nuevo Caso"]) {
                [button setTintColor:[UIColor colorWithRed:10.0f/255.0f green:30.0f/255.0f blue:81.0f/255.0f alpha:1.0f]];
            }
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - Actions

- (IBAction)done:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
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

@end