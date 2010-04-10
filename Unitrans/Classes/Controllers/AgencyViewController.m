//
//  AgencyViewController.m
//  Unitrans
//
//  Created by Ken Zheng on 11/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AgencyViewController.h"
#import "RouteViewController.h"
#import "Agency.h"
#import "Route.h"
#import "Stop.h"
#import "DatabaseManager.h"
#import "UnitransAppDelegate.h"

#import "RouteSegmentedViewController.h"
#import "SegmentedViewController.h"
#import "StopSegmentedViewController.h"

@implementation AgencyViewController

@synthesize agency;
@synthesize routes;
@synthesize favorites;

# pragma mark -
# pragma mark Memory management

- (void)dealloc {
    [agency release];
    [routes release];
	[favorites release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    // Retrieve and set agency
    NSError *error;
    Agency *unitransAgency = [[DatabaseManager sharedDatabaseManager] retrieveUnitransAgency:&error];
    if (!unitransAgency) {
        criticalLoadingErrorAlert();
        return;
    }
    [self setAgency:unitransAgency];
    
    // Create table view and set as view
    UITableView *newTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self setTableView:newTableView];
    [self setView:newTableView];
    [newTableView release];
    
    // Add Unitrans image as title
    UIImageView *titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UnitransTitle.png"]] autorelease];
    [[self navigationItem] setTitleView:titleView];

    // Add info button
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(showAboutViewAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *infoButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    [[self navigationItem] setRightBarButtonItem:infoButtonItem];
    [infoButtonItem release];
    
    // Get agency routes and sort by alphabetical order
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"shortName" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease];
    NSArray *sortedRoutes = [[[unitransAgency routes] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [self setRoutes:sortedRoutes];
	
	favorites = [[NSMutableArray alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(favoritesChanged:)
												 name:@"FavoritesChanged" object:nil];
	
	[self loadFavoritesData];
	[tableView reloadData];
}

- (void)viewDidUnload 
{
	[super viewDidUnload];
	[self setAgency:nil];
	[self setRoutes:nil];
	[self setFavorites:nil];
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


#pragma mark -
#pragma mark UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [self favoritesSectionVisible] ? 2 : 1;
}

- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section
{
    if (section == SectionIndexFavorites && [self favoritesSectionVisible])
        return @"Favorites";
    else
        return @"Routes";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (section == SectionIndexFavorites && [self favoritesSectionVisible])
        return [favorites count];
    else
        return [routes count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = nil;
    
    if ([indexPath section] == SectionIndexFavorites && [self favoritesSectionVisible])
        CellIdentifier = @"Favorites";
    else
        CellIdentifier = @"Routes";
    
    UITableViewCell *cell = [[self tableView] dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        
        if ([CellIdentifier isEqualToString:@"Favorites"]) {
            [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:12]];
            [[cell detailTextLabel] setFont:[UIFont boldSystemFontOfSize:10]];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        else if ([CellIdentifier isEqualToString:@"Routes"]) {
            [[cell detailTextLabel] setFont:[UIFont boldSystemFontOfSize:10]];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if ([indexPath section] == SectionIndexFavorites && [self favoritesSectionVisible]) 
    {
        Route *route = [[favorites objectAtIndex:[indexPath row]] valueForKey:@"route"];
        Stop *stop = [[favorites objectAtIndex:[indexPath row]] valueForKey:@"stop"];
        
        [[cell textLabel] setText:[stop name]];
        [[cell detailTextLabel] setText:[NSString stringWithFormat:@"#%@ %@", [stop stopID], [stop headingString]]];
        [[cell imageView] setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@RouteIcon_43.png", [route shortName]]]];
    }
    else 
    {
        Route *route = [routes objectAtIndex:[indexPath row]];
        
        // Set route name and description
        [[cell textLabel] setText:[NSString stringWithFormat:@"%@ Line", [route shortName]]];
        [[cell detailTextLabel] setText:[route longName]];
        [[cell imageView] setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@RouteIcon_43.png", [route shortName]]]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{   
    if ([indexPath section] == SectionIndexFavorites && [self favoritesSectionVisible])
    {
        Route *route = [[favorites objectAtIndex:[indexPath row]] valueForKey:@"route"];
        Stop *stop = [[favorites objectAtIndex:[indexPath row]] valueForKey:@"stop"];
       
        // Create new StopViewController
        StopSegmentedViewController *stopSegmentedViewController = [[StopSegmentedViewController alloc] init];
        [stopSegmentedViewController setStop:stop];
        [stopSegmentedViewController setRoute:route];
        [stopSegmentedViewController setIsFavorite:YES];
        
        // Push StopViewController onto nav stack
        [[self navigationController] pushViewController:stopSegmentedViewController animated:YES];
        [stopSegmentedViewController release];
    }
    else 
    {
        Route *selectedRoute = [routes objectAtIndex:[indexPath row]];
        
        RouteSegmentedViewController *routeSegmentedViewController = [[RouteSegmentedViewController alloc] init];
        [routeSegmentedViewController setRoute:selectedRoute];
        [routeSegmentedViewController setFavoriteStops:[self allFavoriteStopsForRoute:selectedRoute]];
        
        [[self navigationController] pushViewController:routeSegmentedViewController animated:YES];
        [routeSegmentedViewController release];
    }
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if([indexPath section] == SectionIndexFavorites && [self favoritesSectionVisible])
		return 35.0;
	else
		return [[self tableView] rowHeight];
}

#pragma mark -
#pragma mark Favorites methods

- (BOOL)favoritesSectionVisible
{
    return [favorites count] != 0 ? YES : NO;
}
        
        
- (void)addFavoriteStop:(NSDictionary *)stopInfo
{
	if(![favorites containsObject:stopInfo])
		[favorites addObject:stopInfo];
	else
		NSLog(@"Failed to add favorite stop with name: %@ for route: %@.", [[stopInfo valueForKey:@"stop"] name], [[stopInfo valueForKey:@"route"] shortName]);
}

- (void)removeFavoriteStop:(NSDictionary *)stopInfo
{
	if([favorites containsObject:stopInfo])
		[favorites removeObject:stopInfo];
	else
		NSLog(@"Failed to remove favorite stop with name: %@ for route: %@.", [[stopInfo valueForKey:@"stop"] name], [[stopInfo valueForKey:@"route"] shortName]);
}

- (NSArray *)allFavoriteStopsForRoute:(Route *)route
{
	NSMutableArray *stopsForRoute = [[[NSMutableArray alloc] init] autorelease];
	
	for(NSDictionary *dict in favorites)
		if([[[dict valueForKey:@"route"] shortName] isEqual:[route shortName]])
			[stopsForRoute addObject:[dict valueForKey:@"stop"]];
	
	return [NSArray arrayWithArray:stopsForRoute];
}

- (NSString *)pathForFavoritesData
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *folderPath = [NSString stringWithFormat:@"%@/Unitrans/", documentsDirectory];
	
	// Check if save path exists
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:folderPath]) 
		[fileManager createDirectoryAtPath:folderPath attributes:nil];
	
	NSString *filename = @"Favorites.data";
	
	return [folderPath stringByAppendingPathComponent:filename];
}

- (void)saveFavoritesData
{
	NSMutableArray *favoritesSaveData = [[NSMutableArray alloc] init];
	
	// Save only the route shortName and stop codes
	for(NSDictionary *dict in favorites)
	{
		NSArray *keys = [NSArray arrayWithObjects:@"routeShortName", @"stopCode", nil];
		NSArray *objects = [NSArray arrayWithObjects:[[dict valueForKey:@"route"] shortName], [[dict valueForKey:@"stop"] code], nil];
		[favoritesSaveData addObject:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
	}
	
	NSString *path = [self pathForFavoritesData];
	
	if ([NSKeyedArchiver archiveRootObject:[NSArray arrayWithArray:favoritesSaveData] toFile:path])
		NSLog(@"Saved favorites data at: %@", path);
	else
		NSLog(@"Failed to save favorites data at: %@", path);
	
	[favoritesSaveData release];
}

- (void)loadFavoritesData
{
	NSString *path = [self pathForFavoritesData];
	NSArray *favoritesSaveData = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	
	// Find and store appropriate route and stop objects for route shortName and stopCode
	for(NSDictionary *dict in favoritesSaveData)
	{
		Route *route = [self routeObjectForShortName:[dict valueForKey:@"routeShortName"]];
		Stop *stop = [self stopObjectForRoute:route withStopCode:[dict valueForKey:@"stopCode"]];
		
		if(route && stop)
		{
			NSArray *keys = [NSArray arrayWithObjects:@"route", @"stop", nil];
			NSArray *objects = [NSArray arrayWithObjects:route, stop, nil];
			[favorites addObject:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
		}
		else
			continue;
	}
}

- (Route *)routeObjectForShortName:(NSString *)shortName
{
	for(Route *route in routes)
		if([[route shortName] isEqual:shortName])
			return route;
	return nil;
}

- (Stop *)stopObjectForRoute:(Route *)route withStopCode:(NSNumber *)stopCode
{
	if (!route) {
		NSLog(@"stopObjectForRoute: route is nil.");
		return nil;
	}
	
	NSArray *allStopsForRoute = [[route allStops] allObjects];
	
	for(Stop *stop in allStopsForRoute)
		if([[stop code] isEqual:stopCode])
			return stop;
	return nil;
}

#pragma mark -
#pragma mark Action Methods

- (IBAction)showAboutViewAction:(id)sender
{
    AboutViewController *aboutViewController = [[AboutViewController alloc] init];
    [aboutViewController setAgency:agency];
    [aboutViewController setDelegate:self];
    
    UINavigationController *infoNavigationController = [[UINavigationController alloc] initWithRootViewController:aboutViewController];
    [[infoNavigationController navigationBar] setTintColor:[[[self navigationController] navigationBar] tintColor]];
    
    [[self navigationController] presentModalViewController:infoNavigationController animated:YES];
    
    [aboutViewController release];
    [infoNavigationController release];
}

- (void)aboutViewControllerDidFinish:(AboutViewController *)aboutViewController
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Notifications

- (void)favoritesChanged:(NSNotification *)notification
{	
	NSDictionary *stopInfo = [NSDictionary dictionaryWithObjectsAndKeys:[[notification userInfo] valueForKey:@"route"], @"route",
							  [[notification userInfo] valueForKey:@"stop"], @"stop", nil];
	
	if([[[notification userInfo] valueForKey:@"isFavorite"] boolValue])
		[self addFavoriteStop:stopInfo];
	else
		[self removeFavoriteStop:stopInfo];
	
	// Sort the favorite stops by route, stop name, and stop heading
	NSSortDescriptor *stopsSortDescriptor1 = [[[NSSortDescriptor alloc] initWithKey:@"route" ascending:YES] autorelease];
	NSSortDescriptor *stopsSortDescriptor2 = [[[NSSortDescriptor alloc] initWithKey:@"stop" ascending:YES] autorelease];
	NSArray *sortedFavoriteStops = [favorites sortedArrayUsingDescriptors:[NSArray arrayWithObjects:stopsSortDescriptor1, stopsSortDescriptor2, nil]];
	[self setFavorites:[NSMutableArray arrayWithArray:sortedFavoriteStops]];
	
	[[self tableView] reloadData];
}

@end

