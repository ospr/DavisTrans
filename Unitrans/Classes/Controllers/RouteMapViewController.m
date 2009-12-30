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

#import "CSRouteView.h"
#import "CSRouteAnnotation.h"
#import "BusAnimationAnnotationView.h"
#import "AnimationImageView.h"

#import "UIColor_Extensions.h"
#import "Transform.h"

@implementation RouteMapViewController

@synthesize mapView;
@synthesize route;
@synthesize stop;
@synthesize routePattern;
@synthesize busInformationOperation;
@synthesize busAnnotations;
@synthesize stopAnnotations;

- (void)dealloc 
{
    // End bus updates if they are still running
    if (busContinuousUpdatesRunning)
        [self endContinuousBusUpdates];
    
    [route release];
    [stop release];
    [routePattern release];
    
    [busInformationOperation release];
    [busAnnotations release];
    [stopAnnotations release];
    [routeAnnotation release];
    
    [mapView release];
    [routeAnnotationView release];
    
    [super dealloc];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    // Create patterns button
    UIBarButtonItem *showPatternsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Network.png"]
                                                                           style:UIBarButtonItemStyleBordered
                                                                          target:self
                                                                          action:@selector(showPatternsAction:)];
    [[self navigationItem] setRightBarButtonItem:showPatternsButton];
    [showPatternsButton release];
    
    // Create zoomFit button
    UIBarButtonItem *zoomFitButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Location.png"] 
                                                                      style:UIBarButtonItemStyleBordered 
                                                                     target:self 
                                                                     action:@selector(zoomFitAction:)];
    [[self navigationItem] setLeftBarButtonItem:zoomFitButton];
    [zoomFitButton release];
    
    // Create mapView
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, [[self view] frame].size.width, [[self view] frame].size.height)];
    [mapView setDelegate:self];
    [mapView setShowsUserLocation:YES];
    [self setView:mapView];
        
    // Create route annotation to hold the points, and add to mapView
    routeAnnotation = [[CSRouteAnnotation alloc] init];
    [routeAnnotation setLineColor:[UIColor colorFromHexadecimal:[[route color] integerValue] alpha:0.65]];
    
    // Create route annotation view
    routeAnnotationView = [[CSRouteView alloc] initWithAnnotation:routeAnnotation reuseIdentifier:@"Route"];
    [routeAnnotationView setFrame:CGRectMake(0, 0, [mapView frame].size.width, [mapView frame].size.height)];
    [routeAnnotationView setMapView:mapView];
    
    // Update map with default route pattern
    RoutePattern *defaultRoutePattern = [[route orderedRoutePatterns] objectAtIndex:0];
    [self updateMapWithRoutePattern:defaultRoutePattern];
    
    // Tell map to zoom to show entire route
    [self zoomFitAnimated:NO];
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
    
    // If stop has been set, select it
    if (stop)
        [mapView selectAnnotation:stop animated:YES];
    
    [self beginContinuousBusUpdates];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (busContinuousUpdatesRunning)
        [self endContinuousBusUpdates];
}

- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	[routeAnnotationView release];
}

# pragma mark -
# pragma mark MapView Delegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation
{        
    if ([annotation isKindOfClass:[Stop class]]) 
    {
        // Use a simple pinAnnotation for the stops
        MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Stop"];
        
        if (!pinAnnotationView) {
            pinAnnotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Stop"] autorelease];
            [pinAnnotationView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
            [pinAnnotationView setCanShowCallout:YES];
        }
        
        [pinAnnotationView setAnnotation:annotation];

        return pinAnnotationView;
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
    else if ([annotation isKindOfClass:[CSRouteAnnotation class]])
    {
        return routeAnnotationView;
    }
    
    return nil;
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

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    // This is a bit of a hack to get the view hierarchy to work in this order: RouteView, BusViews, StopViews
    
    // Get the superview for the annotation views
    UIView *annotationSuperView = [[views lastObject] superview];
    
    // Get the index of the routeview and move it to the bottom if it's not already
    NSUInteger routeViewIndex = [[annotationSuperView subviews] indexOfObject:routeAnnotationView];
    if (routeViewIndex != NSNotFound && routeViewIndex != 0) {
        [[routeAnnotationView superview] sendSubviewToBack:routeAnnotationView];
    }
    
    // Iterate through subviews and find the RealTimeBusInfo annotations
    // move them to just above the routeview
    for (UIView *view in [annotationSuperView subviews])
    {
        if ([view isMemberOfClass:[MKAnnotationView class]] && [[(MKAnnotationView*)view annotation] isKindOfClass:[RealTimeBusInfo class]])
            [[view superview] insertSubview:view aboveSubview:routeAnnotationView];
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
    // Load alert message with error
    if (!errorShown) {
        NSString *reason = @"There was an error while loading the map. Make sure you are connected to the internet.";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Map Loading Error" message:reason
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];	
        [alert release];
                
        // Show error only once!
        errorShown = YES;
    }
    
    NSLog(@"Error loading map: %@ %@", error, [error userInfo]);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

# pragma mark -
# pragma mark RealTimeInfo Methods

- (void)zoomFitAnimated:(BOOL)animated
{
    [mapView setRegion:[routeAnnotation region] animated:animated];
}

- (void)beginContinuousBusUpdates
{        
    busContinuousUpdatesRunning = YES;

    [self updateBusLocations];
    
    // If we are still updating after the first update, fire a timer every 4 seconds
    if (busContinuousUpdatesRunning)
        busTimer = [[NSTimer scheduledTimerWithTimeInterval:4.0
                                                     target:self
                                                   selector:@selector(updateBusLocations)
                                                   userInfo:nil
                                                    repeats:YES] retain];
}

- (void)endContinuousBusUpdates
{
    busContinuousUpdatesRunning = NO;
    
    [busTimer invalidate];
    [busTimer release];
    busTimer = nil;
    
    if (busAnnotations)
        [mapView removeAnnotations:busAnnotations];
    
    [self setBusAnnotations:nil];
}

- (void)updateBusLocations
{    
    // Get all buses for the current route
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self setBusInformationOperation:[[[BusInformationOperation alloc] initWithRouteName:[route shortName]] autorelease]];
    [busInformationOperation setDelegate:self];
    [busInformationOperation start];
}

- (void)updateBusAnnotations:(NSArray *)newBusAnnotations
{
    // If busInfos is nil there was an error
    if (!newBusAnnotations) {
        [self endContinuousBusUpdates];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Update Bus Location Error" message:@"There was an error while updating bus locations. Make sure you are connected to the internet." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    // If there were no buses, then stop upating and alert user
    else if ([newBusAnnotations count] == 0) {
        [self endContinuousBusUpdates];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Buses Found" message:@"There were no buses found for this route at this time." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    
    // Remove buses if they exsisted before
    if (busAnnotations)
        [mapView removeAnnotations:busAnnotations];
    
    // Add new bus annotations
    [mapView addAnnotations:newBusAnnotations];
    [self setBusAnnotations:newBusAnnotations];
    
    // Redraw map
    [mapView setNeedsDisplay];
}

#pragma mark -
#pragma mark BusInformationOperation Delegate Methods

- (void)busInformation:(BusInformationOperation *)busInformationOperation didFinishWithBusInformation:(NSArray *)busInformation
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    [self updateBusAnnotations:busInformation];
}

- (void)busInformation:(BusInformationOperation *)busInformationOperation didFailWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
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
    Trip *trip = [newRoutePattern trip];
    
    // Sort shapes by sequence number
    NSSortDescriptor *shapesSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"pointSequence" ascending:YES] autorelease];
    NSArray *sortedShapes = [[[trip shapes] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:shapesSortDescriptor]];
    
    // Iterate through shapes and add their locations to the array
    NSMutableArray *points = [NSMutableArray array];
    for (Shape *shape in sortedShapes) 
    {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[[shape pointLatitude] doubleValue] longitude:[[shape pointLongitude] doubleValue]];
        [points addObject:location];
        [location release];
    }
    
    // Update points in routeAnnotation
    [routeAnnotation setPoints:points];
    [mapView removeAnnotation:routeAnnotation];
    [mapView addAnnotation:routeAnnotation];
    
    // Remove old stopAnnotations and add new ones
    [mapView removeAnnotations:stopAnnotations];
    [mapView addAnnotations:[[trip stops] allObjects]];
    
    // Set new stopAnnotations
    [self setStopAnnotations:[[trip stops] allObjects]];
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
    [self zoomFitAnimated:YES];
}

#pragma mark -
#pragma mark Actions

- (IBAction)zoomFitAction:(id)sender
{
    [self zoomFitAnimated:YES];
}

- (IBAction)showPatternsAction:(id)sender
{
    // Set up actionSheet for patterns
    UIActionSheet *patternSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Route Pattern" 
                                                              delegate:self
                                                     cancelButtonTitle:nil
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:nil];
    
    // Add pattern names to actionSheet
    for (NSString *patternName in [[route orderedRoutePatterns] valueForKey:@"name"])
        [patternSheet addButtonWithTitle:patternName];

    // Add Cancel button
    [patternSheet addButtonWithTitle:@"Cancel"];
    [patternSheet setCancelButtonIndex:([patternSheet numberOfButtons] - 1)];
    
    // Show actionSheet
    [patternSheet showInView:[self view]];
    [patternSheet release];
}

@end
