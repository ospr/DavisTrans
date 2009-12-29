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

#import "RouteSegmentedViewController.h"
#import "SegmentedViewController.h"

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
    
    // Add Unitrans image as title
    UIImageView *titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UnitransTitle.png"]] autorelease];
    [[self navigationItem] setTitleView:titleView];

    // Create about button
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Hide navigation controller
    [[self navigationController] setToolbarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Check to make sure that transit data is up to date, if not alert user!
    if (![agency transitDataUpToDate]) {
        NSString *reason = @"Your schedule data is out of date.";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Schedule Data" message:reason
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];	
        [alert release];
    }
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [routes count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        
        [[cell detailTextLabel] setFont:[UIFont boldSystemFontOfSize:10]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Route *route = [routes objectAtIndex:[indexPath row]];
    
    // Set route name and description
    NSString *mainLabel = [NSString stringWithFormat:@"%@ Line",  [route shortName]];
    NSString *detailLabel = [route longName];
	[[cell textLabel] setText:mainLabel];
    [[cell detailTextLabel] setText:detailLabel];
    
    // Set route icon
    [[cell imageView] setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@RouteIcon_43.png", [route shortName]]]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    Route *selectedRoute = [routes objectAtIndex:[indexPath row]];
    
    RouteSegmentedViewController *routeSegmentedViewController = [[RouteSegmentedViewController alloc] init];
    [routeSegmentedViewController setRoute:selectedRoute];
    
    [[self navigationController] pushViewController:routeSegmentedViewController animated:YES];
    [routeSegmentedViewController release];
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

