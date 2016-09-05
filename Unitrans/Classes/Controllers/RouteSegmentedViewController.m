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

#import "DetailOverlayView.h"
#import "UIColor_Extensions.h"

@implementation RouteSegmentedViewController

@synthesize route;
@synthesize routeViewController;
@synthesize routeMapViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self setSegmentItems:[NSArray arrayWithObjects:@"Map", @"Stops", nil]];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create detail overlay view
    DetailOverlayView *detailOverlayView = [[DetailOverlayView alloc] initWithFrame:CGRectMake(0, 0, 230, 40)];
    [[detailOverlayView textLabel] setText:[NSString stringWithFormat:@"%@ Line", [route shortName]]];
    [[detailOverlayView detailTextLabel] setText:[route longName]];
    [[detailOverlayView imageView] setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@RouteIcon_43.png", [route shortName]]]];
    [detailOverlayView setAccessibilityLabel:[NSString stringWithFormat:@"%@ Line, %@", [route shortName], [route longName]]]; 
    
    // Set navbar title view
    [[self navigationItem] setTitleView:detailOverlayView];
    [detailOverlayView release];
}

- (void)viewDidUnload 
{
	[super viewDidUnload];
	[self setRoute:nil];
	[self setRouteViewController:nil];
	[self setRouteMapViewController:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Show navigation controller
    [[self navigationController] setToolbarHidden:NO animated:animated];
}

- (ExtendedViewController *)viewControllerForSelectedSegmentIndex:(NSInteger)index
{
    ExtendedViewController *viewController = nil;
    
    NSString *segmentIdentifier = [[self segmentItems] objectAtIndex:index];
    
    // Load RouteViewController
    if ([segmentIdentifier isEqualToString:@"Stops"]) 
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
