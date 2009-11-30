//
//  AgencyViewController.m
//  Unitrans
//
//  Created by Ken Zheng on 11/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AgencyViewController.h"
#import "RouteViewController.h"
#import "AboutViewController.h"
#import "Agency.h"
#import "Route.h"
#import "DatabaseManager.h"
#import "UnitransAppDelegate.h"

@implementation AgencyViewController

@synthesize agency;
@synthesize routes;

# pragma mark -
# pragma mark Memory management

- (void)dealloc {
    [agency release];
    [routes release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Retrieve and set agency
    NSError *error;
    Agency *unitransAgency = [[DatabaseManager sharedDatabaseManager] retrieveUnitransAgency:&error];
    if (!unitransAgency) {
        criticalLoadingErrorAlert();
        return;
    }
    [self setAgency:unitransAgency];

    UIBarButtonItem *aboutButtonItem = [[UIBarButtonItem alloc] init];
    [aboutButtonItem setTitle:@"About"];
    [aboutButtonItem setTarget:self];
    [aboutButtonItem setAction:@selector(showAboutViewAction:)];
    [[self navigationItem] setRightBarButtonItem:aboutButtonItem];
    [aboutButtonItem release];
    
    // Get agency routes and sort by alphabetical order
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"shortName" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease];
    NSArray *sortedRoutes = [[[unitransAgency routes] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [self setRoutes:sortedRoutes];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [routes count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    Route *route = [routes objectAtIndex:[indexPath row]];
    
    // Set up the cell...
    NSString *mainLabel = [NSString stringWithFormat:@"%@ Line",  [route shortName]];
    NSString *detailLabel = [route longName];
	[[cell textLabel] setText:mainLabel];
    [[cell detailTextLabel] setText:detailLabel];
    [[cell detailTextLabel] setFont:[UIFont boldSystemFontOfSize:10]];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    [[cell imageView] setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@RouteIcon_43.png", [route shortName]]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    Route *selectedRoute = [routes objectAtIndex:[indexPath row]];
	
	RouteViewController *routeViewController = [[RouteViewController alloc] init];//[[RouteViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [routeViewController setRoute:selectedRoute];
    
	[self.navigationController pushViewController:routeViewController animated:YES];
	[routeViewController release];
}

#pragma mark -
#pragma mark Action Methods

- (IBAction)showAboutViewAction:(id)sender
{
    AboutViewController *aboutViewController = [[AboutViewController alloc] init];
    [aboutViewController setAgency:agency];
    [[self navigationController] pushViewController:aboutViewController animated:YES];
    [aboutViewController release];
}

@end

