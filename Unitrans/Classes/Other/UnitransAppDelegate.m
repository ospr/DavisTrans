//
//  UnitransAppDelegate.m
//  Unitrans
//
//  Created by Kip Nicol on 10/21/09.
//  Copyright Apple Inc. 2009. All rights reserved.
//

#import "UnitransAppDelegate.h"


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

