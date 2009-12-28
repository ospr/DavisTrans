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


@implementation StopTimeSegmentedViewController

@synthesize stopTime;

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
    [stopTimeViewController release];
    
    [super dealloc];
}

- (ExtendedViewController *)viewControllerForSelectedSegmentIndex:(NSInteger)index
{
    NSString *segmentIdentifier = [[self segmentItems] objectAtIndex:index];
    
    // Create view controller if needed
    if (!stopTimeViewController) {
        stopTimeViewController = [[StopTimeViewController alloc] init];
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
