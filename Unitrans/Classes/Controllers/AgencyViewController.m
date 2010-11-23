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
#import "Service.h"
#import "DatabaseManager.h"
#import "UnitransAppDelegate.h"

#import "RouteSegmentedViewController.h"
#import "SegmentedViewController.h"
#import "StopSegmentedViewController.h"
#import "FavoritesController.h"
#import "CreditsViewController.h"
#import "NSOperationQueue_Extensions.h"

NSUInteger MaxConcurrentOperationCount = 3;

@implementation AgencyViewController

@synthesize agency;
@synthesize routes;
@synthesize favorites;
@synthesize favoritePredictions;
@synthesize isRunningContinuousPredictionUpdates = runningContinuousPredictionUpdates;

# pragma mark -
# pragma mark Memory management

- (void)dealloc {
	
	// End continuous updates if still running
	if (runningContinuousPredictionUpdates) {
		[self endContinuousPredictionUpdates];
	}
	
    [agency release];
    [routes release];
	[favorites release];
	[favoritePredictions release];
	[operationQueue release];
    
    [serviceButtonItem release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
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
    
    // Add service button
    serviceButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(changeServiceAction:)];
    [[self navigationItem] setLeftBarButtonItem:serviceButtonItem];
		
    // Get notifications when favorites change so we can reload the table
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(favoritesChanged:)
												 name:@"FavoritesChanged" object:nil];
	
    // Determine default service
    NSArray *allServices = [[DatabaseManager sharedDatabaseManager] allServices];
    for (Service *service in allServices)
    {
        [[DatabaseManager sharedDatabaseManager] useService:service];
        [self setAgency:[[DatabaseManager sharedDatabaseManager] retrieveUnitransAgency:nil]];
        if ([agency transitDataUpToDate]) {
            break;
        }
    }
    
    // Setup default service
    [self serviceChanged];
	
	// Create array to hold favorite predictions
	favoritePredictions = [[NSMutableArray alloc] init];
	
	// Create opeartion queue to handle favorite prediction operations
	operationQueue = [[NSOperationQueue alloc] init];
	[operationQueue setMaxConcurrentOperationCount:MaxConcurrentOperationCount];
	
    // Determine if schedule is out of date
    if (![agency transitDataUpToDate])
        outOfDate = YES;
}

- (void)viewDidUnload 
{
	[super viewDidUnload];
	[self setAgency:nil];
	[self setRoutes:nil];
	[self setFavorites:nil];
	[self setFavoritePredictions:nil];
    [serviceButtonItem release]; serviceButtonItem = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Hide navigation controller
    [[self navigationController] setToolbarHidden:YES animated:animated];
	
	// Initialize favorite predictions array
	if ([favoritePredictions count]) {
		[favoritePredictions removeAllObjects];
	}
	
	for(NSDictionary *favorite in favorites)
	{
		NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:4];
		[dictionary setObject:[[favorite valueForKey:@"route"] shortName] forKey:@"routeName"];
		[dictionary setObject:[(NSNumber *)[[favorite valueForKey:@"stop"] code] stringValue] forKey:@"stopCode"];
		[dictionary setObject:@"Loading..." forKey:@"predictions"];
		[dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"isUpdating"];
		[favoritePredictions addObject:dictionary];
	}
	
	[self beginContinuousPredictionUpdates];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // If schedule not up to date, alert user!
    if (outOfDate) {
        NSString *reason = @"Your Unitrans schedule data is out of date. Please check the App Store to download a current version.";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Old Schedule Data" message:reason
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];	
        [alert release];
    }
    
    // Show welcome message first time app is launched
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FirstLaunch"] == NO) {
        [self showWelcomeMessage];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstLaunch"];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	// Stop updating predictions
	[self endContinuousPredictionUpdates];
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
		
		if ([[[favoritePredictions objectAtIndex:[indexPath row]] valueForKey:@"predictions"] isEqual:@""]) {
			[[cell detailTextLabel] setText:[NSString stringWithFormat:@"#%@ %@", [stop stopID], [stop headingString]]];
		} else {
			[[cell detailTextLabel] setText:[NSString stringWithFormat:@"#%@ %@ - %@", [stop stopID], [stop headingString], [[favoritePredictions objectAtIndex:[indexPath row]] valueForKey:@"predictions"]]];
		}

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
#pragma mark Service Methods

- (void)changeServiceAction:(id)sender
{
    // Get services from database
    NSArray *services = [[DatabaseManager sharedDatabaseManager] allServices];
    Service *currentService = [[DatabaseManager sharedDatabaseManager] currentService];
    
    // Set up actionSheet for services
    UIActionSheet *serviceSheet = [[UIActionSheet alloc] init];
    [serviceSheet setTitle:@"Choose Service"];
    [serviceSheet setDelegate:self];
    
    // Add pattern names to actionSheet
    for (Service *service in services) {
        // Add a check mark to the selected route pattern
        if ([service isEqual:currentService])
            [serviceSheet addButtonWithTitle:[NSString stringWithFormat:@"✔ %@", [service longName]]];
        else
            [serviceSheet addButtonWithTitle:[NSString stringWithFormat:@"%@", [service longName]]];
    }
    
    // Add Cancel button
    [serviceSheet addButtonWithTitle:@"Cancel"];
    [serviceSheet setCancelButtonIndex:([serviceSheet numberOfButtons] - 1)];
    
    // Show actionSheet
    [serviceSheet showInView:[self view]];
    [serviceSheet release];
}

- (void)serviceChanged
{
    // Load agency
    NSError *error;
    Agency *unitransAgency = [[DatabaseManager sharedDatabaseManager] retrieveUnitransAgency:&error];
    if (!unitransAgency) {
        criticalLoadingErrorAlert();
        return;
    }
    [self setAgency:unitransAgency];
    
    // Set new service name
    Service *currentService = [[DatabaseManager sharedDatabaseManager] currentService];
    [serviceButtonItem setTitle:[currentService shortName]];
    
    // Get agency routes and sort by alphabetical order
    NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"shortName" ascending:YES selector:@selector(caseInsensitiveCompare:)] autorelease];
    NSArray *sortedRoutes = [[[unitransAgency routes] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [self setRoutes:sortedRoutes];
    
    // Update favorites (this will hide any favorites which aren't valid for the selected service)
    [[FavoritesController sharedFavorites] loadFavoritesDataWithRoutes:routes];
    [self setFavorites:[[FavoritesController sharedFavorites] favorites]];
    
    // Update table
    [[self tableView] reloadData];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Ignore cancels
    if (buttonIndex == [actionSheet cancelButtonIndex])
        return;
    
    // Get selected service
    NSArray *services = [[DatabaseManager sharedDatabaseManager] allServices];
    Service *currentService = [[DatabaseManager sharedDatabaseManager] currentService];
    Service *selectedService = [services objectAtIndex:buttonIndex];
    
    // Update database and UI with new service
    if (![selectedService isEqual:currentService]) {
        [[DatabaseManager sharedDatabaseManager] useService:selectedService];
        [self serviceChanged];
    }
}


#pragma mark -
#pragma mark Favorites methods

- (BOOL)favoritesSectionVisible
{
    return [favorites count] != 0 ? YES : NO;
}

- (void)updatePredictions
{
	for(NSMutableDictionary *favorite in favoritePredictions)
	{
		if (![[favorite valueForKey:@"isUpdating"] boolValue]) {
			PredictionOperation *predictionOperation = [[PredictionOperation alloc] initWithRouteName:[favorite valueForKey:@"routeName"]
																							  stopTag:[favorite valueForKey:@"stopCode"]];
			[predictionOperation setDelegate:self];
			[operationQueue addOperation:predictionOperation];
			[favorite setObject:[NSNumber numberWithBool:YES] forKey:@"isUpdating"];
			[predictionOperation release];
			
			if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
				[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
			}
		}
	}
}

- (void)beginContinuousPredictionUpdates
{
	[self setIsRunningContinuousPredictionUpdates:YES];
	
	[self updatePredictions];
	
	// if we are still updating after the first update, start a timer to update every 20 seconds
	if (runningContinuousPredictionUpdates) {
		predictionTimer = [[NSTimer scheduledTimerWithTimeInterval:20.0 
															target:self 
														  selector:@selector(updatePredictions) 
														  userInfo:nil 
														   repeats:YES] retain];
	}
}

- (void)endContinuousPredictionUpdates
{
	[self setIsRunningContinuousPredictionUpdates:NO];
	
	[predictionTimer invalidate];
	[predictionTimer release];
	predictionTimer = nil;
	
	[operationQueue cancelAllOperations];
}
        
#pragma mark -
#pragma mark About Methods

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
	[[self tableView] reloadData];
}

#pragma mark -
#pragma mark Credit Methods

- (void)showCreditViewAction
{
    // Push about view onto nav stack
    AboutViewController *aboutViewController = [[AboutViewController alloc] init];
    [aboutViewController setAgency:agency];
    [aboutViewController setDelegate:self];
    
    UINavigationController *infoNavigationController = [[UINavigationController alloc] initWithRootViewController:aboutViewController];
    [[infoNavigationController navigationBar] setTintColor:[[[self navigationController] navigationBar] tintColor]];
    
    [[self navigationController] presentModalViewController:infoNavigationController animated:YES];
    
    // Push credit view onto nav stack
    CreditsViewController *creditsViewController = [[CreditsViewController alloc] init];
    
    [[aboutViewController navigationController] pushViewController:creditsViewController animated:YES];
    
    [aboutViewController release];
    [infoNavigationController release];
    [creditsViewController release];
}

#pragma mark -
#pragma mark Welcome Methods

- (void)showWelcomeMessage
{
    NSString *message = @"Welcome to DavisTrans, the future official Unitrans iPhone Application! "
    @"Bringing you this application are two UC Davis students. "
    @"We hope that you find this app as useful and convenient as we have. " 
    @"Feel free to contact Unitrans if you have questions or comments. Enjoy :)";
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DavisTrans" message:message 
                                                   delegate:self cancelButtonTitle:@"OK" 
                                          otherButtonTitles:@"View Credits", nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Show credits if view credits button is pressed
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"View Credits"]) {
        [self showCreditViewAction];
    }
}

#pragma mark -
#pragma mark PredictionOperation Delegate Methods

- (void)predictionOperation:(PredictionOperation *)predictionOperation didFinishWithPredictions:(NSArray *)newPredictions
{		
	// Stop activity indicator if there are no more operations running
    if ([operationQueue allFinished]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
	 
	NSString *routeName = [predictionOperation routeName];
	NSString *stopCode = [predictionOperation stopTag];
	NSString *predictionText = [predictionOperation predictionText];
	
    // Update favorites predictions
	for(NSDictionary *favorite in favoritePredictions)
	{
		if ([[favorite valueForKey:@"routeName"] isEqualToString:routeName] && [[favorite valueForKey:@"stopCode"] isEqualToString:stopCode]) {
			[favorite setValue:predictionText forKey:@"predictions"];
			[favorite setValue:[NSNumber numberWithBool:NO] forKey:@"isUpdating"];
			break;
		}
	}
	
	[tableView reloadData];
}

- (void)predictionOperation:(PredictionOperation *)predictionOperation didFailWithError:(NSError *)error
{
	// Stop activity indicator if there are no more operations running
    if ([operationQueue allFinished]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
	
	NSString *routeName = [predictionOperation routeName];
	NSString *stopCode = [predictionOperation stopTag];
	
	// Update favorites predictions
	for(NSDictionary *favorite in favoritePredictions)
	{
		if ([[favorite valueForKey:@"routeName"] isEqualToString:routeName] && [[favorite valueForKey:@"stopCode"] isEqualToString:stopCode]) {
			[favorite setValue:@"" forKey:@"predictions"];
			[favorite setValue:[NSNumber numberWithBool:NO] forKey:@"isUpdating"];
			break;
		}
	}
	
	[tableView reloadData];
}


@end

