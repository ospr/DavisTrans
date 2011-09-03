//
//  StopTimeViewController.m
//  Unitrans
//
//  Created by Ken Zheng on 11/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StopTimeViewController.h"
#import "StopSegmentedViewController.h"
#import "Trip.h"
#import "StopTime.h"
#import "Stop.h"
#import "Route.h"


@implementation StopTimeViewController

@synthesize route;
@synthesize stopTime;
@synthesize arrivalTimes;
@dynamic dataType;

#pragma mark -
#pragma mark Init Methods

- (void)dealloc 
{
    [route release];
    [stopTime release];
    [arrivalTimes release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];

	[self setTitle:@"Arrival Times"];
        
    // Create table view
    UITableView *newTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self setTableView:newTableView];
    [self setView:newTableView];
    
    // Set view
    [self setView:newTableView];
    [newTableView release];
    
    // Update stop times to show correct times
    [self updateStopTimes];
}

- (void)viewDidUnload 
{
	[super viewDidUnload];
	[self setRoute:nil];
	[self setStopTime:nil];
	[self setArrivalTimes:nil];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark Arrival/Departure Filter Methods

- (void)setDataType:(StopTimeViewDataType)newDataType
{
    dataType = newDataType;
    
    // Update stopTimes when dataType is set
    [self updateStopTimes];
}

- (StopTimeViewDataType)dataType
{
    return dataType;
}

- (void)updateStopTimes
{
    // Filter stop times based on arrival/departure view  
    NSArray *stopTimes = nil;
    switch ([self dataType]) {
        case kStopTimeViewDataTypeArrivalTimes: 
            stopTimes = [stopTime nextStopTimesInTrip];
            break;
        case kStopTimeViewDataTypeDepartureTimes: 
            stopTimes = [stopTime previousStopTimesInTrip];
            break;
        default:
            break;
    }

    // Sort StopTimes
    NSSortDescriptor *stopTimeSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"arrivalTime" ascending:YES] autorelease];
    NSArray *sortedStopTimes = [stopTimes sortedArrayUsingDescriptors:[NSArray arrayWithObject:stopTimeSortDescriptor]];

    [self setArrivalTimes:sortedStopTimes];
}

#pragma mark -
#pragma mark UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrivalTimes count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (dataType == kStopTimeViewDataTypeArrivalTimes)
        return @"Next arrival times on route:";
    else if (dataType == kStopTimeViewDataTypeDepartureTimes)
        return @"Previous departure times on route:";
    
    return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        
        [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:12]];
        [[cell detailTextLabel] setFont:[UIFont boldSystemFontOfSize:12]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    StopTime *arrivalTime = [arrivalTimes objectAtIndex:[indexPath row]];
    
    // Set arrivalTime's stop name and time string
    [[cell textLabel] setText:[[arrivalTime stop] name]];
    [[cell detailTextLabel] setText:[arrivalTime arrivalTimeString]];
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Smaller height for time cells
	if([indexPath section] == 0)
		return 35.0;
	else
		return [tv rowHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    // Get selected stopTime and the selected stop
    StopTime *selectedStopTime = [arrivalTimes objectAtIndex:[indexPath row]];
    Stop *selectedStop = [selectedStopTime stop];    
    
    // Create new StopViewController
    StopSegmentedViewController *stopSegmentedViewController = [[StopSegmentedViewController alloc] init];
	[stopSegmentedViewController setStop:selectedStop];
	[stopSegmentedViewController setRoute:route];
    
    // Push StopViewController onto nav stack
	[[self navigationController] pushViewController:stopSegmentedViewController animated:YES];
	[stopSegmentedViewController release];
}

#pragma mark -
#pragma mark Custom Accessor Methods

- (UIViewAnimationTransition)segmentTransition
{
    if (dataType == kStopTimeViewDataTypeArrivalTimes)
        return UIViewAnimationTransitionFlipFromLeft;
    else
        return UIViewAnimationTransitionFlipFromRight;
}

@end

