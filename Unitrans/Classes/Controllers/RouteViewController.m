//
//  RouteViewController.m
//  Unitrans
//
//  Created by Ken Zheng on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RouteViewController.h"
#import "StopSegmentedViewController.h"
#import "FavoritesController.h"
#import "RouteMapViewController.h"
#import "DetailOverlayView.h"
#import "Route.h"
#import "Stop.h"

@implementation RouteViewController

@synthesize route;
@synthesize stops;
@synthesize filteredStops;
@synthesize searchBar;
@synthesize searchDisplayController;

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
    
    [searchBar release];
    [searchDisplayController release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    [self setTitle:[NSString stringWithFormat:@"%@ Line", [route shortName]]];

    // Get route stops and sort by alphabetical order
    NSSortDescriptor *stopsSortDescriptor1 = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
    NSSortDescriptor *stopsSortDescriptor2 = [[[NSSortDescriptor alloc] initWithKey:@"headingString" ascending:YES] autorelease];
    NSArray *sortedStops = [[[route allStops] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:stopsSortDescriptor1, stopsSortDescriptor2, nil]];
    [self setStops:sortedStops];
    
    // Create table view
    UITableView *newTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [newTableView setBackgroundColor:[UIColor clearColor]];
    [newTableView setOpaque:NO];
    [self setTableView:newTableView];
    
    // Create search bar
    CGRect searchBarFrame = CGRectMake(0, 0, [[self tableView] frame].size.width, 40);
    searchBar = [[UISearchBar alloc] initWithFrame:searchBarFrame];
    [searchBar setTintColor:[UIColor colorWithRed:(173/255.0) green:(85/255.0) blue:(85/255.0) alpha:1.0]];
    [searchBar setPlaceholder:@"Search Stops"];
    [searchBar setDelegate:self];
    [[self tableView] setTableHeaderView:searchBar];
    
    // Create search display controller
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    [searchDisplayController setDelegate:self];
    [searchDisplayController setSearchResultsDelegate:self];
    [searchDisplayController setSearchResultsDataSource:self];
    
    // Set view
    [self setView:tableView];
    [newTableView release];
    
    // Observe for when favorites change
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(favoritesChanged:)
												 name:@"FavoritesChanged" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Scroll to first row to hide the search bar    
    if (!hasAppeared) {
        hasAppeared = YES;
        [[self tableView] setContentOffset:CGPointMake(0, [[[self tableView] tableHeaderView] frame].size.height)];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Hide search display if view is currently active
    if ([searchDisplayController isActive]) {
        [searchDisplayController setActive:NO animated:animated];
    }
}

- (void)viewDidUnload 
{
	[super viewDidUnload];
	[self setRoute:nil];
	[self setStops:nil];
    [self setSearchBar:nil];
    [self setSearchDisplayController:nil];
}

- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


#pragma mark -
#pragma mark UITableView methods

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section 
{
    if (tv == [searchDisplayController searchResultsTableView])
        return [filteredStops count];
        
    return [stops count];
}

- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section
{
    if (tv == [searchDisplayController searchResultsTableView])
        return @"Filtered Stops";
    
    return @"Stops";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        
        [cell setBackgroundView:[[UIView new] autorelease]];
        [[cell backgroundView] setBackgroundColor:[UIColor whiteColor]];
        
        [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:12]];
        [[cell detailTextLabel] setFont:[UIFont systemFontOfSize:10]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }

    return cell;
}

- (void)tableView:(UITableView *)tv willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Stop *stop = nil;
    
    if (tv == [searchDisplayController searchResultsTableView])
        stop = [filteredStops objectAtIndex:[indexPath row]];
    else
        stop = [stops objectAtIndex:[indexPath row]];
    
    // Set stop name and heading (Add a star if the stop is a favorite)
    if ([[FavoritesController sharedFavorites] isFavoriteStop:stop forRoute:route]) {
        [[cell textLabel] setText:[NSString stringWithFormat:@"★ %@", [stop name]]];
        [cell setAccessibilityLabel:[NSString stringWithFormat:@"Favorite, %@, %@", [stop name], [stop headingString]]];
    }
    else {
        [[cell textLabel] setText:[stop name]];
    }
    [[cell detailTextLabel] setText:[stop headingString]];
}


- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	Stop *selectedStop = nil;
    
    if (tv == [searchDisplayController searchResultsTableView])
        selectedStop = [filteredStops objectAtIndex:[indexPath row]];
    else
        selectedStop = [stops objectAtIndex:[indexPath row]];
    
    // Create new StopViewController
    StopSegmentedViewController *stopSegmentedViewController = [[StopSegmentedViewController alloc] init];
	[stopSegmentedViewController setStop:selectedStop];
	[stopSegmentedViewController setRoute:route];
    
    // Push StopViewController onto nav stack
	[[self navigationController] pushViewController:stopSegmentedViewController animated:YES];
	[stopSegmentedViewController release];
    
    // Hide search bar if user selected a stop from the filtered table
    if (tv == [searchDisplayController searchResultsTableView])
        [searchDisplayController setActive:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 35.0;
}

#pragma mark -
#pragma mark UISearchBarDelegate Methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // Here we intelligently filter the stops based on the search text:
    // Break searchText up into components separated by space, then create an AND compound predicate
    // such that each subpredicate checks to see if the stop's name contains the given component
    NSArray *components = [searchText componentsSeparatedByString:@" "];
    NSMutableArray *subPredicates = [NSMutableArray array];
    
    for (NSString *component in components)
    {
        // Skip empty componenets (multiple string values)
        if ([component length] == 0) continue;
        
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"name", component];
        [subPredicates addObject:filterPredicate];
    }
    
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
    
    [self setFilteredStops:[stops filteredArrayUsingPredicate:compoundPredicate]];
    
    [[searchDisplayController searchResultsTableView] reloadData];
}

#pragma mark -
#pragma mark Notifications

- (void)favoritesChanged:(NSNotification *)notification
{	
	[[self tableView] reloadData];
}

@end
