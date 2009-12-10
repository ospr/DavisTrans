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
#import "OverlayHeaderView.h"
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
    
    [overlayHeaderView release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    [self setTitle:[NSString stringWithFormat:@"%@ Line", [route shortName]]];
	
    // Create map button
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

    // Create detail overlay view
    CGRect bounds = [[self view] bounds];
    overlayHeaderView = [[OverlayHeaderView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
    [[[overlayHeaderView detailOverlayView] textLabel] setText:[NSString stringWithFormat:@"%@ Line", [route shortName]]];
    [[[overlayHeaderView detailOverlayView] detailTextLabel] setText:[route longName]];
    [[[overlayHeaderView detailOverlayView] imageView] setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@RouteIcon_43.png", [route shortName]]]];
    
    // Create table view (detail overlay's content view)
    UITableView *newTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self setTableView:newTableView];
    [overlayHeaderView setContentView:newTableView];
    [newTableView release];
    
    [self setView:overlayHeaderView];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Stops";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:12]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Stop *stop = [stops objectAtIndex:[indexPath row]];
    
    // Set stop name
	[[cell textLabel] setText:[stop name]];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	Stop *selectedStop = [stops objectAtIndex:[indexPath row]];
    
    // Create new StopViewController
	StopViewController *stopViewController = [[StopViewController alloc] init];
	[stopViewController setStop:selectedStop];
	[stopViewController setRoute:route];
    
    // Push StopViewController onto nav stack
	[[self navigationController] pushViewController:stopViewController animated:YES];
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
    // Create new RouteMapViewController
    RouteMapViewController *routeMapViewController = [[RouteMapViewController alloc] init];
    [routeMapViewController setRoute:route];
    
    // Push RouteMapViewController onto nav stack
    [[self navigationController] pushViewController:routeMapViewController animated:YES];
    [routeMapViewController release];
}

@end

