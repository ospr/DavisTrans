//
//  UnitransAppDelegate.m
//  Unitrans
//
//  Created by Kip Nicol on 10/21/09.
//  Copyright Apple Inc. 2009. All rights reserved.
//

#import "UnitransAppDelegate.h"

void criticalLoadingErrorAlert()
{
    NSString *reason = @"There was an error while loading the Unitrans data. Try quiting the application and relaunching it. "
    "If the problem persists, try removing the application and reinstalling it.\n\n"
    "Press the Home Button to exit the application.";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unitrans Critical Error" message:reason
                                                   delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];	
    [alert release];
}

@implementation UnitransAppDelegate

@synthesize window;
@synthesize navigationController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
        
    // Add the tab bar controller's current view as a subview of the window
	[window addSubview:navigationController.view];
	[window makeKeyAndVisible];
}

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


- (void)dealloc {
	[navigationController release];
    [window release];
    [super dealloc];
}

@end

