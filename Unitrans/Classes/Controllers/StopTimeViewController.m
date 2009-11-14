//
//  StopTimeViewController.m
//  Unitrans
//
//  Created by Ken Zheng on 11/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StopTimeViewController.h"
#import "Trip.h"
#import "StopTime.h"
#import "Stop.h"


@implementation StopTimeViewController

@synthesize stopTime;
@synthesize arrivalTimes;

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    StopTime *arrivalTime = [arrivalTimes objectAtIndex:[indexPath row]];
    
    //NSString *stopAndArrivalString = [NSString stringWithFormat:@"%@  -  %@", [[stopTime stop] name], [stopTime arrivalTimeString]];
    [[cell textLabel] setText:[[arrivalTime stop] name]];
    [[cell textLabel] setFont:[UIFont fontWithName:@"Helvetica" size:12]];
	
    [[cell detailTextLabel] setText:[arrivalTime arrivalTimeString]];
    [[cell detailTextLabel] setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if([indexPath section] == 0)
		return 35.0;
	else
		return [tableView rowHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}

@end

