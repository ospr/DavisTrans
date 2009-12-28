//
//  StopSegmentedViewController.m
//  Unitrans
//
//  Created by Kip on 12/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StopSegmentedViewController.h"

#import "Route.h"
#import "Stop.h"
#import "StopViewController.h"
#import "RouteMapViewController.h"


@implementation StopSegmentedViewController

@synthesize route;
@synthesize stop;

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
    [stop release];
    
    [stopViewController release];
    [routeMapViewController release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationController] setToolbarHidden:NO animated:animated];
}

- (UIViewController *)viewControllerForSelectedSegmentIndex:(NSInteger)index
{
    UIViewController *viewController = nil;
    
    NSString *segmentIdentifier = [[self segmentItems] objectAtIndex:index];
    
    // Load RouteViewController
    if ([segmentIdentifier isEqualToString:@"List"]) 
    {
        if (!stopViewController) {
            stopViewController = [[StopViewController alloc] init];
            [stopViewController setRoute:route];
            [stopViewController setStop:stop];
        }
        
        viewController = stopViewController;
    }
    // Load RouteMapViewController
    else if ([segmentIdentifier isEqualToString:@"Map"])
    {
        if (!routeMapViewController) {
            routeMapViewController = [[RouteMapViewController alloc] init];
            [routeMapViewController setRoute:route];
            [routeMapViewController setStop:stop];
        }
        
        viewController = routeMapViewController;
    }
    
    return viewController;
}

@end
