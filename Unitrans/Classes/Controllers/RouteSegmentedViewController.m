//
//  RouteSegmentedViewController.m
//  Unitrans
//
//  Created by Kip on 12/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RouteSegmentedViewController.h"

#import "RouteViewController.h"
#import "RouteMapViewController.h"
#import "Route.h"

@implementation RouteSegmentedViewController

@synthesize route;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self setSegmentItems:[NSArray arrayWithObjects:@"List", @"Map", nil]];
    }
    
    return self;
}

- (void)dealloc 
{
    [route release];
    
    [routeViewController release];
    [routeMapViewController release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Show navigation controller
    [[self navigationController] setToolbarHidden:NO animated:animated];
}

- (ExtendedViewController *)viewControllerForSelectedSegmentIndex:(NSInteger)index
{
    ExtendedViewController *viewController = nil;
    
    NSString *segmentIdentifier = [[self segmentItems] objectAtIndex:index];
    
    // Load RouteViewController
    if ([segmentIdentifier isEqualToString:@"List"]) 
    {
        if (!routeViewController) {
            routeViewController = [[RouteViewController alloc] init];
            [routeViewController setRoute:route];
        }
        
        viewController = routeViewController;
    }
    // Load RouteMapViewController
    else if ([segmentIdentifier isEqualToString:@"Map"])
    {
        if (!routeMapViewController) {
            routeMapViewController = [[RouteMapViewController alloc] init];
            [routeMapViewController setRoute:route];
        }
        
        viewController = routeMapViewController;
    }
    
    return viewController;
}

@end
