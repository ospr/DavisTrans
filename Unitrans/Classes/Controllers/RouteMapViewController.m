//
//  RouteMapViewController.m
//  Unitrans
//
//  Created by Kip Nicol on 11/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RouteMapViewController.h"
#import "StopSegmentedViewController.h"
#import "RealTimeBusInfo.h"
#import "Route.h"
#import "StopTime.h"
#import "Stop.h"
#import "Shape.h"
#import "Trip.h"

#import "BusAnimationAnnotationView.h"
#import "AnimationImageView.h"

#import "UIColor_Extensions.h"
#import "NSOperationQueue_Extensions.h"
#import "Transform.h"

NSTimeInterval kBusUpdateShortInterval = 4.0;
NSTimeInterval kBusUpdateLongInterval = 20.0;

@implementation RouteMapViewController

@synthesize mapView;
@synthesize route;
@synthesize stop;
@synthesize routePattern;
@synthesize stopAnnotations;
@synthesize busAnnotations;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        locationManager = [CLLocationManager new];
        operationQueue = [[NSOperationQueue alloc] init];
        
        busUpdateInterval = kBusUpdateShortInterval;
        [self setSegmentTransition:UIViewAnimationTransitionFlipFromRight];
    }
    
    return self;
}

- (void)dealloc 
{
    // End bus updates if they are still running
    if (busContinuousUpdatesRunning)
        [self endContinuousBusUpdates];
    
    [route release];
    [stop release];
    [routePattern release];
    
    [operationQueue release];
    [locationManager release];
    [stopAnnotations release];
    
    // Perform special clean-up for mapView to avoid crashes from MKDotBounceAnimation
    // See http://omegadelta.net/2009/11/02/mkdotbounceanimation-animationdidstop-bug/
    [mapView setDelegate:nil];
    [mapView setShowsUserLocation:NO];
    [mapView performSelector:@selector(release) withObject:nil afterDelay:4.0];
        
    [super dealloc];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    // Create mapView
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, [[[self segmentedViewController] contentView] frame].size.width, [[[self segmentedViewController] contentView] frame].size.height)];
    [mapView setDelegate:self];
    [self setView:mapView];
    
    // Reset loaded after a new view is created
    mapViewIsLoaded = NO;
    
    // Set stopAnnotations to all stops in route
    [self setStopAnnotations:[[route allStops] allObjects]];
    
    // Create patterns button
    UIBarButtonItem *showPatternsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Network.png"]
                                                                           style:UIBarButtonItemStyleBordered
                                                                          target:self
                                                                          action:@selector(showPatternsAction:)];
    [showPatternsButton setAccessibilityLabel:@"Route Patterns"];
    [self setRightSegmentedBarButtonItem:showPatternsButton];
    [showPatternsButton release];
    
    // Create zoomFit button
    UIBarButtonItem *zoomFitButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Location.png"] 
                                                                      style:UIBarButtonItemStyleBordered 
                                                                     target:self 
                                                                     action:@selector(zoomFitAction:)];
    [zoomFitButton setAccessibilityLabel:@"Zoom to fit"];
    [self setLeftSegmentedBarButtonItem:zoomFitButton];
    [zoomFitButton release];
}

- (void)viewDidUnload 
{
	[super viewDidUnload];
    
    [self setMapView:nil];
	[self setRoute:nil];
	[self setStop:nil];
	[self setRoutePattern:nil];
	[self setStopAnnotations:nil];
}

- (void)loadMapView
{
    // Show user location
    [mapView setShowsUserLocation:YES];
    
    // Update map with default route pattern
    RoutePattern *defaultRoutePattern = [[route orderedRoutePatterns] objectAtIndex:0];
    [self updateMapWithRoutePattern:defaultRoutePattern];    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Tell map to zoom to show entire route
    if (!mapViewIsLoaded)
        [self zoomFitAnimated:NO includeUserLocation:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Reset errorShown when view appears again, so the user is warned about the error
    errorShown = NO;
}

- (void)viewDidAppear:(BOOL)animated
{    
    [super viewDidAppear:animated];
    
    // Load map annotations and show user after the view has appeared
    if (!mapViewIsLoaded) {
        [self loadMapView];
        mapViewIsLoaded = YES;
    }

    // Begin updating bus locations
    [self beginContinuousBusUpdates];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // End bus updates when view disappears
    if (busContinuousUpdatesRunning)
        [self endContinuousBusUpdates];
}

- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

# pragma mark -
# pragma mark MapView Delegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation
{        
    // If we are displaying the map for a specific stop then add a special stop pin for it
    if (stop && [stop isEqual:annotation]) 
    {
        Stop *stopAnnotation = annotation;
        MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"DefaultStop"];
        
        if (!pinAnnotationView) {
            pinAnnotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:stopAnnotation reuseIdentifier:@"DefaultStop"] autorelease];
            [pinAnnotationView setCanShowCallout:YES];
            [pinAnnotationView setPinColor:MKPinAnnotationColorPurple];
            [pinAnnotationView setAnimatesDrop:YES];
        }
        
        [stopAnnotation setSequence:[[routePattern trip] sequenceForStop:stopAnnotation]];
        [pinAnnotationView setAnnotation:stopAnnotation];
        
        return pinAnnotationView;
    }
    else if ([annotation isKindOfClass:[Stop class]]) 
    {        
        Stop *stopAnnotation = annotation;
        
        // If Stop is in current route pattern list of stops add a regular pin
        if ([[[routePattern trip] stops] containsObject:stopAnnotation])
        {   
            MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Stop"];
            
            if (!pinAnnotationView) {
                pinAnnotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:stopAnnotation reuseIdentifier:@"Stop"] autorelease];
                [pinAnnotationView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
                [pinAnnotationView setCanShowCallout:YES];
            }
            
            [stopAnnotation setSequence:[[routePattern trip] sequenceForStop:stopAnnotation]];
            [pinAnnotationView setAnnotation:stopAnnotation];
            
            return pinAnnotationView;
        }
        // Else if Stop is NOT in the current route pattern, add a hidden pin
        else {
            MKAnnotationView *pinAnnotationView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"HiddenStop"];
            
            if (!pinAnnotationView) {
                pinAnnotationView = [[[MKAnnotationView alloc] initWithAnnotation:stopAnnotation reuseIdentifier:@"HiddenStop"] autorelease];
                [pinAnnotationView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
                [pinAnnotationView setCanShowCallout:YES];
                [pinAnnotationView setImage:[UIImage imageNamed:@"HiddenStop.png"]];
                [pinAnnotationView setCenterOffset:CGPointMake(8, -16)];
                [pinAnnotationView setCalloutOffset:CGPointMake(-8, 1)];
            }
            
            [stopAnnotation setSequence:[[routePattern trip] sequenceForStop:stopAnnotation]];
            [pinAnnotationView setAnnotation:stopAnnotation];
            
            return pinAnnotationView;
        }
    }
    else if ([annotation isKindOfClass:[RealTimeBusInfo class]])
    {
        RealTimeBusInfo *busInfoAnnotation = annotation;
        
        // Create a new bus annotation view every time so that the
        // animation is updated everytime the bus view updates
        BusAnimationAnnotationView *busAnnotationView = [[[BusAnimationAnnotationView alloc] initWithAnnotation:busInfoAnnotation reuseIdentifier:@"Bus"] autorelease];
        
        // Rotate the bus arrow direction
        [[busAnnotationView busArrowImageView] setTransform:[Transform rotateByDegrees:[busInfoAnnotation heading]]];
        
        [busAnnotationView setAnnotation:busInfoAnnotation];
        
        return busAnnotationView;
    }
    
    return nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *polylineRenderer = [[[MKPolylineRenderer alloc] initWithOverlay:overlay] autorelease];
    [polylineRenderer setStrokeColor:[UIColor colorFromHexadecimal:[[route color] integerValue] alpha:0.65]];
    [polylineRenderer setLineWidth:4.0];

    return polylineRenderer;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    // This is a bit of a hack to get the view hierarchy to work in this order: BusViews, StopViews
    
    // Get the superview for the annotation views
    UIView *annotationSuperView = [[views lastObject] superview];
    
    // Iterate through subviews and find the RealTimeBusInfo annotations
    // move them to the front
    for (UIView *view in [annotationSuperView subviews])
    {   
        if ([view isMemberOfClass:[MKAnnotationView class]] && [[(MKAnnotationView*)view annotation] isKindOfClass:[RealTimeBusInfo class]])
            [[view superview] insertSubview:view atIndex:0];
    }
}

- (void)mapView:(MKMapView *)mv annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{    
    if ([[view annotation] isKindOfClass:[Stop class]])
    {
        // Get stop user selected to view
        Stop *selectedStop = [view annotation];
        
        // Create new StopViewController
        StopSegmentedViewController *stopSegmentedViewController = [[StopSegmentedViewController alloc] init];
        [stopSegmentedViewController setStop:selectedStop];
        [stopSegmentedViewController setRoute:route];
        
        // Push StopViewController onto nav stack
		[[self navigationController] pushViewController:stopSegmentedViewController animated:YES];
		[stopSegmentedViewController release];
    }
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // Load alert message with error (only if error is not null)
    if (error)
        [self showError:error];
    
    NSLog(@"Error loading map: %@ %@", error, [error userInfo]);
}

#pragma mark -
#pragma mark Map Region Methods

- (MKCoordinateRegion)regionForLocations:(NSArray *)locations
{
    MKCoordinateRegion region;
	
	double maxLat = -91;
	double minLat =  91;
	double maxLon = -181;
	double minLon =  181;
	
	for(CLLocation *location in locations)
	{
		CLLocationCoordinate2D coordinate = [location coordinate];
		
		if(coordinate.latitude > maxLat)
			maxLat = coordinate.latitude;
		if(coordinate.latitude < minLat)
			minLat = coordinate.latitude;
		if(coordinate.longitude > maxLon)
			maxLon = coordinate.longitude;
		if(coordinate.longitude < minLon)
			minLon = coordinate.longitude; 
	}
    
    // Add a little padding to ensure the map is zoomed out enough
    maxLat += 0.001;
    minLat -= 0.001;
    maxLon += 0.001;
    minLon -= 0.001;
    
	region.span.latitudeDelta = (maxLat + 90) - (minLat + 90);
	region.span.longitudeDelta = (maxLon + 180) - (minLon + 180);
    
	// the center point is the average of the max and mins
	region.center.latitude = minLat + region.span.latitudeDelta / 2;
	region.center.longitude = minLon + region.span.longitudeDelta / 2;
    
    return region;
}

- (MKCoordinateRegion)defaultStopRegionWithUserLocation:(BOOL)withUserLocation
{
    NSMutableArray *locations = [NSMutableArray array];
    
    // If we are determining region using user location add it
    if (withUserLocation) {
        [locationManager requestWhenInUseAuthorization];
        CLLocation *userLocation  = [[mapView userLocation] location];
        
        if (userLocation)
            [locations addObject:userLocation];
    }
    
	// Add locations for all the stops as well
	for(Stop *stopAnnotation in [self stopAnnotations])
	{
        CLLocation *stopLocation = [[CLLocation alloc] initWithLatitude:[stopAnnotation coordinate].latitude longitude:[stopAnnotation coordinate].longitude];
		[locations addObject:stopLocation];
        [stopLocation release];
	}
    
    return [self regionForLocations:locations];
}

- (void)zoomFitAnimated:(BOOL)animated includeUserLocation:(BOOL)userLocation
{    
    [mapView setRegion:[self defaultStopRegionWithUserLocation:userLocation] animated:animated];
}

# pragma mark -
# pragma mark RealTimeInfo Methods

- (void)startNewBusUpdateTimer
{
    [busTimer invalidate];
    [busTimer release];
    busTimer = nil;
    
    busTimer = [[NSTimer scheduledTimerWithTimeInterval:busUpdateInterval
                                                 target:self
                                               selector:@selector(updateBusLocations)
                                               userInfo:nil
                                                repeats:YES] retain];
}

- (void)beginContinuousBusUpdates
{        
    busContinuousUpdatesRunning = YES;

    [self updateBusLocations];
    
    // If we are still updating after the first update, fire a timer to update
    if (busContinuousUpdatesRunning)
        [self startNewBusUpdateTimer];
}

- (void)endContinuousBusUpdates
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    busContinuousUpdatesRunning = NO;
        
    [busTimer invalidate];
    [busTimer release];
    busTimer = nil;
    
    [operationQueue cancelAllOperations];
    
    [mapView removeAnnotations:[self busAnnotations]];
}

- (void)updateBusLocations
{    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Get all buses for the current route
    BusInformationOperation *busInformationOperation = [[BusInformationOperation alloc] initWithRouteName:[route shortName]];
    [busInformationOperation setDelegate:self];
    
    [operationQueue addOperation:busInformationOperation];
    [busInformationOperation release];
}

- (void)updateBusAnnotations:(NSArray *)newBusAnnotations
{
    // If there were no buses, slow the update
    if (newBusAnnotations && [newBusAnnotations count] == 0 && busUpdateInterval != kBusUpdateLongInterval) {
        busUpdateInterval = kBusUpdateLongInterval;
        [self startNewBusUpdateTimer];
    }
    // If there are buses, update more quickly
    else if (newBusAnnotations && [newBusAnnotations count] && busUpdateInterval != kBusUpdateShortInterval) {
        busUpdateInterval = kBusUpdateShortInterval;
        [self startNewBusUpdateTimer];
    }
    
    // Turn bus arrays into a dictionary for easier processing
    NSDictionary *busAnnotationsDict = [NSDictionary dictionaryWithObjects:[self busAnnotations] forKeys:[[self busAnnotations] valueForKey:@"vehicleID"]];
    NSDictionary *newBusesDict = [NSDictionary dictionaryWithObjects:newBusAnnotations forKeys:[newBusAnnotations valueForKey:@"vehicleID"]];
    
    // Iterate through all of the new bus vehicleIDs
    for (NSString *vehicleID in newBusesDict)
    {
        RealTimeBusInfo *oldBus = [busAnnotationsDict objectForKey:vehicleID];
        RealTimeBusInfo *newBus = [newBusesDict objectForKey:vehicleID];
        
        // If the bus already exists then update it
        if (oldBus)
        {
            // Update bus
            [oldBus updateWithBusInfo:newBus];
        
            // Re-animate bus
            BusAnimationAnnotationView *busView = (BusAnimationAnnotationView *)[mapView viewForAnnotation:oldBus];
            [busView animate];
            
            // Rotate the bus arrow direction
            [[busView busArrowImageView] setTransform:[Transform rotateByDegrees:[oldBus heading]]];
        }
        // Otherwise this is a new bus and we need to add it
        else 
        {
            [mapView addAnnotation:newBus];
        }
    }
    
    // Iterate through all the old bus vehicleIDs
    for (NSString *vehicleID in busAnnotationsDict)
    {   
        RealTimeBusInfo *oldBus = [busAnnotationsDict objectForKey:vehicleID];
        
        // If the bus no longer exsists then remove it
        if (![newBusesDict objectForKey:vehicleID])
            [mapView removeAnnotation:oldBus];
    }
    
    // Redraw map
    [mapView setNeedsDisplay];
}

#pragma mark -
#pragma mark BusInformationOperation Delegate Methods

- (void)busInformation:(BusInformationOperation *)busInformationOperation didFinishWithBusInformation:(NSArray *)busInformation
{
    // Stop activity indicator if there are no more operations running
    if ([operationQueue allFinished]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
    // Update bus annotations
    [self updateBusAnnotations:busInformation];
}

- (void)busInformation:(BusInformationOperation *)busInformationOperation didFailWithError:(NSError *)error
{
    // Stop activity indicator if there are no more operations running
    if ([operationQueue allFinished]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
    // End bus updates if there was an error
    [self endContinuousBusUpdates];
    [self showError:error];
    
    // Clear bus annotations
    [self updateBusAnnotations:nil];
}

#pragma mark -
#pragma mark Route Pattern Methods

- (void)updateMapWithRoutePattern:(RoutePattern *)newRoutePattern
{
    // If the routePatterns are the same we don't need to update anything
    if ([newRoutePattern isEqual:routePattern])
        return;
    
    [self setRoutePattern:newRoutePattern];
        
    // Get trip
    Trip *trip = [routePattern trip];
    
    // Sort shapes by sequence number
    NSSortDescriptor *shapesSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"pointSequence" ascending:YES] autorelease];
    NSArray *sortedShapes = [[[trip shapes] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:shapesSortDescriptor]];
    
    // Iterate through shapes and add their locations to the array
    NSUInteger pointsCount = [sortedShapes count];
    CLLocationCoordinate2D *points = malloc(sizeof(CLLocationCoordinate2D) * pointsCount);
    for (int i = 0; i < pointsCount; i++)
    {
        Shape *shape = [sortedShapes objectAtIndex:i];
        
        CLLocationCoordinate2D location;
        location.latitude = [[shape pointLatitude] doubleValue];
        location.longitude = [[shape pointLongitude] doubleValue];
        points[i] = location;
    }

    // Update route path overlay
    [mapView removeOverlays:[mapView overlays]];
    [mapView addOverlay:[MKPolyline polylineWithCoordinates:points count:pointsCount]];
    
    // Update stopAnnotations
    [mapView removeAnnotations:stopAnnotations];
    [mapView addAnnotations:[[route allStops] allObjects]];
    
    free(points);
}

#pragma mark -
#pragma mark UIActionSheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Ignore cancels
    if (buttonIndex == [actionSheet cancelButtonIndex])
        return;
    
    // Get selected routePattern and set it
    RoutePattern *selectedRoutePattern = [[route orderedRoutePatterns] objectAtIndex:buttonIndex];
    
    // Update map with new route pattern
    [self updateMapWithRoutePattern:selectedRoutePattern];
    [self zoomFitAnimated:YES includeUserLocation:NO];
}

#pragma mark -
#pragma mark Actions

- (IBAction)zoomFitAction:(id)sender
{
    [self zoomFitAnimated:YES includeUserLocation:YES];
}

- (IBAction)showPatternsAction:(id)sender
{
    // Set up actionSheet for patterns
    UIActionSheet *patternSheet = [[UIActionSheet alloc] init];
    [patternSheet setTitle:@"Choose Route Pattern"];
    [patternSheet setDelegate:self];
    
    // Add pattern names to actionSheet
    for (NSString *patternName in [[route orderedRoutePatterns] valueForKey:@"name"]) {
        // Add a check mark to the selected route pattern
        if ([patternName isEqualToString:[routePattern name]])
            [patternSheet addButtonWithTitle:[NSString stringWithFormat:@"✔ %@", patternName]];
        else
            [patternSheet addButtonWithTitle:[NSString stringWithFormat:@"%@", patternName]];
    }

    // Add Cancel button
    [patternSheet addButtonWithTitle:@"Cancel"];
    [patternSheet setCancelButtonIndex:([patternSheet numberOfButtons] - 1)];
    
    // Show actionSheet
    [patternSheet showFromToolbar:[[self navigationController] toolbar]];
    [patternSheet release];
}

#pragma mark -
#pragma mark Custom Accessors

- (NSArray *)busAnnotations
{
    NSMutableArray *newBusAnnotations = [NSMutableArray array];
    
    for (NSObject<MKAnnotation> *annotation in [mapView annotations])
    {
        if ([annotation isKindOfClass:[RealTimeBusInfo class]])
            [newBusAnnotations addObject:annotation];
    }
    
    return [NSArray arrayWithArray:newBusAnnotations];
}

#pragma mark -
#pragma mark Error Handling Methods

- (void)showError:(NSError *)error
{
    NSString *errorTitle = nil;
    NSString *errorMessage = nil;
    
    // Don't show multiple errors
    if (errorShown)
        return;
    
    errorShown = YES;
    
    if ([[error domain] isEqualToString:NSURLErrorDomain]) {
        errorTitle = @"No Internet Connection";
        errorMessage = @"It appears your device has no Internet connection. You will not be able to update map data or see bus locations.";
    }
    else {
        errorTitle = @"Error Loading Data";
        errorMessage = @"There was an unexpected error while loading data. You may not be able to update map data or see bus locations.";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errorTitle
                                                        message:errorMessage
                                                       delegate:self 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

@end
