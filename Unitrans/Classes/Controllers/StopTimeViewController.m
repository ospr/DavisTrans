//
//  StopTimeViewController.m
//  Unitrans
//
//  Created by Ken Zheng on 11/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StopTimeViewController.h"
#import "OverlayHeaderView.h"
#import "Trip.h"
#import "StopTime.h"
#import "Stop.h"
#import "Route.h"


@implementation StopTimeViewController

@synthesize stopTime;
@synthesize arrivalTimes;

#pragma mark -
#pragma mark Memory management

- (void)dealloc 
{
    [stopTime release];
    [arrivalTimes release];
    [overlayHeaderView release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];

	[self setTitle:@"Arrival Times"];
    
    NSSortDescriptor *stopTimeSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"arrivalTime" ascending:YES] autorelease];
    NSArray *sortedStopTimes = [[[[stopTime trip] stopTimes] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:stopTimeSortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"arrivalTime > %@", [stopTime arrivalTime]];
    NSArray *filteredStopTimes = [sortedStopTimes filteredArrayUsingPredicate:predicate];
    
    [self setArrivalTimes:filteredStopTimes];
    
    // Create detail overlay view
    CGRect bounds = [[self view] bounds];
    overlayHeaderView = [[OverlayHeaderView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
    [[[overlayHeaderView detailOverlayView] textLabel] setText:[NSString stringWithFormat:@"Departing at: %@", [stopTime arrivalTimeString]]];
    [[[overlayHeaderView detailOverlayView] detailTextLabel] setText:[NSString stringWithFormat:@"Departing from: %@", [[stopTime stop] name]]];
    [[[overlayHeaderView detailOverlayView] imageView] setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@RouteIcon_43.png", [[[stopTime trip] route] shortName]]]];
    
    // Create table view (detail overlay's content view)
    UITableView *newTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self setTableView:newTableView];
    [overlayHeaderView setContentView:newTableView];
    [newTableView release];
    
    // Set view
    [self setView:overlayHeaderView];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark UITableView methods

// TODO: Implement UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrivalTimes count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Next arrival times on route:";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    StopTime *arrivalTime = [arrivalTimes objectAtIndex:[indexPath row]];
    
    [[cell textLabel] setText:[[arrivalTime stop] name]];
    [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:12]];
	
    [[cell detailTextLabel] setText:[arrivalTime arrivalTimeString]];
    [[cell detailTextLabel] setFont:[UIFont boldSystemFontOfSize:12]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if([indexPath section] == 0)
		return 35.0;
	else
		return [tv rowHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}

@end

