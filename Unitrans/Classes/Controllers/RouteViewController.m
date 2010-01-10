//
//  RouteViewController.m
//  Unitrans
//
//  Created by Ken Zheng on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RouteViewController.h"
#import "StopSegmentedViewController.h"
#import "RouteMapViewController.h"
#import "DetailOverlayView.h"
#import "Route.h"
#import "Stop.h"

@implementation RouteViewController

@synthesize route;
@synthesize stops;

#pragma mark -
#pragma mark Init Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self setSegmentTransition:UIViewAnimationTransitionFlipFromLeft];
    }
    
    return self;
}

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
    
    [self setTitle:[NSString stringWithFormat:@"%@ Line", [route shortName]]];

    // Get route stops and sort by alphabetical order
    NSSortDescriptor *stopsSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
    NSArray *sortedStops = [[[route allStops] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:stopsSortDescriptor]];
    [self setStops:sortedStops];
    
    // Create table view
    UITableView *newTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self setTableView:newTableView];

    // Set view
    [self setView:tableView];
    [newTableView release];

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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        
        [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:12]];
        [[cell detailTextLabel] setFont:[UIFont systemFontOfSize:10]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Stop *stop = [stops objectAtIndex:[indexPath row]];
    
    // Set stop name and heading
	[[cell textLabel] setText:[stop name]];
    [[cell detailTextLabel] setText:[stop headingString]];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	Stop *selectedStop = [stops objectAtIndex:[indexPath row]];
    
    // Create new StopViewController
    StopSegmentedViewController *stopSegmentedViewController = [[StopSegmentedViewController alloc] init];
	[stopSegmentedViewController setStop:selectedStop];
	[stopSegmentedViewController setRoute:route];
    
    // Push StopViewController onto nav stack
	[[self navigationController] pushViewController:stopSegmentedViewController animated:YES];
	[stopSegmentedViewController release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 35.0;
}

@end

