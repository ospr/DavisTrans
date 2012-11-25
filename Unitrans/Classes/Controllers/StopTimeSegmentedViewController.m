//
//  StopTimeSegmentedViewController.m
//  Unitrans
//
//  Created by Kip on 12/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StopTimeSegmentedViewController.h"

#import "StopTimeViewController.h"
#import "StopTime.h"
#import "Trip.h"
#import "Route.h"
#import "DetailOverlayView.h"
#import "UIColor_Extensions.h"

@implementation StopTimeSegmentedViewController

@synthesize route;
@synthesize stopTime;
@synthesize stopTimeViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self setSegmentItems:[NSArray arrayWithObjects:@"Arrivals", @"Departures", nil]];
    }
    
    return self;
}

- (void)dealloc 
{
    [route release];
    [stopTime release];
    
    [stopTimeViewController release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set background
    [[self view] setBackgroundColor:[UIColor davisTransScrollViewTexturedBackground]];
    
    // Create detail overlay view
    DetailOverlayView *detailOverlayView = [[DetailOverlayView alloc] initWithFrame:CGRectMake(0, 0, 255, 40)];
    [[detailOverlayView textLabel] setText:[NSString stringWithFormat:@"Depart - Arrive at %@", [stopTime arrivalTimeString]]];
    [[detailOverlayView detailTextLabel] setText:[NSString stringWithFormat:@"From - To: %@", [[stopTime stop] name]]];
    [[detailOverlayView imageView] setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@RouteToolbarIcon_43.png", [[[stopTime trip] route] shortName]]]];
    
    // Set navbar title view
    [[self navigationItem] setTitleView:detailOverlayView];
    [detailOverlayView release];
}

- (void)viewDidUnload 
{
	[super viewDidUnload];
	[self setRoute:nil];
	[self setStopTime:nil];
	[self setStopTimeViewController:nil];
}

- (ExtendedViewController *)viewControllerForSelectedSegmentIndex:(NSInteger)index
{
    NSString *segmentIdentifier = [[self segmentItems] objectAtIndex:index];
    
    // Create view controller if needed
    if (!stopTimeViewController) {
        stopTimeViewController = [[StopTimeViewController alloc] init];
        [stopTimeViewController setRoute:route];
        [stopTimeViewController setStopTime:stopTime];
    }

    // Load RouteViewController
    if ([segmentIdentifier isEqualToString:@"Arrivals"]) 
    {
        [stopTimeViewController setDataType:kStopTimeViewDataTypeArrivalTimes];
    }
    // Load RouteMapViewController
    else if ([segmentIdentifier isEqualToString:@"Departures"])
    {
        [stopTimeViewController setDataType:kStopTimeViewDataTypeDepartureTimes];
    }
    
    [[stopTimeViewController tableView] reloadData];
    
    return stopTimeViewController;
}

@end
