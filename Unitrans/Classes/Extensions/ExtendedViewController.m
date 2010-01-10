//
//  ExtendedViewController.m
//  Unitrans
//
//  Created by Kip on 12/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ExtendedViewController.h"


@implementation ExtendedViewController

@synthesize segmentedViewController;
@synthesize segmentTransition;

- (void)dealloc 
{
    [segmentedViewController release];
    
    [super dealloc];
}

- (UINavigationController *)navigationController
{
    // If there is a segmentedViewController return its nav controller,
    // otherwise return the super's nav controller
    return segmentedViewController ? [segmentedViewController navigationController] : [super navigationController];
}

@end
