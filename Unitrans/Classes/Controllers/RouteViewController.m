//
//  RouteViewController.m
//  Unitrans
//
//  Created by Ken Zheng on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RouteViewController.h"
#import "StopViewController.h"
#import "RouteMapViewController.h"
#import "Route.h"
#import "Stop.h"

@implementation RouteViewController

@synthesize route;
@synthesize stops;

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [route release];
    [stops release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	UIBarButtonItem *mapButtonItem = [[UIBarButtonItem alloc] init];
    [mapButtonItem setTitle:@"Map"];
    [mapButtonItem setTarget:self];
    [mapButtonItem setAction:@selector(showStopInMapAction:)];
    [[self navigationItem] setRightBarButtonItem:mapButtonItem];
    [mapButtonItem release];

    // Get route stops and sort by alphabetical order
    NSSortDescriptor *stopsSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
    NSArray *sortedStops = [[[route allStops] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:stopsSortDescriptor]];
    [self setStops:sortedStops];
    
	[self setTitle:[NSString stringWithFormat:@"%@ Line", [route shortName]]];
}

- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark -
#pragma mark UITableView methods

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [stops count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	Stop *stop = [stops objectAtIndex:[indexPath row]];
	[[cell textLabel] setText:[stop name]];
	[[cell textLabel] setFont:[UIFont boldSystemFontOfSize:12]];
	//[[cell textLabel] setTextAlignment:UITextAlignmentLeft];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	Stop *selectedStop = [stops objectAtIndex:[indexPath row]];
	StopViewController *stopViewController = [[StopViewController alloc] initWithStyle:UITableViewStyleGrouped];
	[stopViewController setStop:selectedStop];
	[stopViewController setRoute:route];
	[self.navigationController pushViewController:stopViewController animated:YES];
	[stopViewController release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 35.0;
}

#pragma mark -
#pragma mark IBAction methods
- (IBAction)showStopInMapAction:(id)action
{
    RouteMapViewController *routeMapViewController = [[RouteMapViewController alloc] initWithNibName:@"RouteMapView" bundle:nil];
    [routeMapViewController setRoute:route];
    [[self navigationController] pushViewController:routeMapViewController animated:YES];
    [routeMapViewController release];
}

@end

