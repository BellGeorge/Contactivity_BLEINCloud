/*
 Copyright (c) 2011, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "AppDelegate.h"
#import "MainViewController.h"

/*
 NOTE if you ever need to update these, you can obtain them from your Salesforce org,
 (When you are logged in as an org administrator, go to Setup -> Develop -> Remote Access -> New )
 */


// Fill these in when creating a new Remote Access client on Force.com 
static NSString *const RemoteAccessConsumerKey = @"3MVG9Iu66FKeHhINkB1l7xt7kR8czFcCTUhgoA8Ol2Ltf1eYHOU4SqQRSEitYFDUpqRWcoQ2.dBv_a1Dyu5xa";
//static NSString *const RemoteAccessConsumerKey = @"3MVG9";
static NSString *const OAuthRedirectURI = @"testsfdc:///mobilesdk/detect/oauth/done";


@implementation AppDelegate

@synthesize splash, rootVC;

- (void)dealloc
{
    [splash release];
    [rootVC release];
    [super dealloc];
}

#pragma mark - Remote Access / OAuth configuration


- (NSString*)remoteAccessConsumerKey {
    return RemoteAccessConsumerKey;
}

- (NSString*)oauthRedirectURI {
    return OAuthRedirectURI;
}



#pragma mark - App lifecycle


//NOTE be sure to call all super methods you override.


- (UIViewController*)newRootViewController {    
    // Tiempo de espera
    [NSThread sleepForTimeInterval:3];

    UIDevice *device = [UIDevice currentDevice];
    
    if ([device userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
        // Add the main view controller's view to the window and display.
        rootVC = [[MainViewController alloc] init];
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:rootVC];
        return navVC;
    } else {
        // Add the main view controller's view to the window and display.
        /*iPadMainViewController *rootVC = [[iPadMainViewController alloc] initWithNibName:@"iPadMainViewController" bundle:nil];
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:rootVC];
        [rootVC release];
        return navVC;*/
        return nil;
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    //NSLog(@"ResignActive");
    UIImage *image = [UIImage imageNamed:@"Default.png"];
    splash = [[UIImageView alloc] initWithImage:image];
    [self.rootVC.window addSubview:splash];
    
    // Borramos RestKit Cache
    [Trash cleanRestKitLibraryCache];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //NSLog(@"Active");
    [splash removeFromSuperview];
    [Appirater appEnteredForeground:YES];
    
    // Borramos RestKit Cache
    [Trash cleanRestKitLibraryCache];
}

@end
