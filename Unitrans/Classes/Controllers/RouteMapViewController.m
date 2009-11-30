//
//  RouteMapViewController.m
//  Unitrans
//
//  Created by Kip Nicol on 11/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RouteMapViewController.h"
#import "StopViewController.h"
#import "OverlayHeaderView.h"
#import "RealTimeBusInfoManager.h"
#import "RealTimeBusInfo.h"
#import "Route.h"
#import "StopTime.h"
#import "Stop.h"
#import "Shape.h"
#import "Trip.h"

#import "CSRouteView.h"
#import "CSRouteAnnotation.h"

#import "UIColor_Extensions.h"

@implementation RouteMapViewController

@synthesize mapView;
@synthesize route;
@synthesize stop;
@synthesize busAnnotations;

- (void)dealloc 
{
    [route release];
    [stop release];
    [routeAnnotationView release];
    [busAnnotations release];
    [busTimer release];
    [busButtonItem release];
    
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    busButtonItem = [[UIBarButtonItem alloc] init];
    [busButtonItem setTitle:@"Bus"];
    [busButtonItem setTarget:self];
    [busButtonItem setAction:@selector(beginContinuousBusUpdatesAction:)];
    [[self navigationItem] setRightBarButtonItem:busButtonItem];
    
    mapView = [[MKMapView alloc] init];
    [mapView setDelegate:self];
    
    // For now get a random trip
    Trip *trip = [route primaryTrip];
       
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
    
    // Create route annotation to hold the points, and add to mapView
    CSRouteAnnotation *routeAnnotation = [[[CSRouteAnnotation alloc] initWithPoints:points] autorelease];
    [routeAnnotation setLineColor:[UIColor colorFromHexadecimal:[[route color] integerValue] alpha:0.60]];
	[mapView addAnnotation:routeAnnotation];
    
    // Create route annotation view
    routeAnnotationView = [[CSRouteView alloc] initWithAnnotation:routeAnnotation reuseIdentifier:@"Route"];
    [routeAnnotationView setFrame:CGRectMake(0, 0, [mapView frame].size.width, [mapView frame].size.height)];
    [routeAnnotationView setMapView:mapView];
    
    // Add stop annotations
    for (Stop *tripStop in [trip stops])
        [mapView addAnnotation:tripStop];
    
    // Create detail overlay view
    CGRect bounds = [[self view] bounds];
    overlayHeaderView = [[OverlayHeaderView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
    [[[overlayHeaderView detailOverlayView] textLabel] setText:[NSString stringWithFormat:@"%@ Line", [route shortName]]];
    [[[overlayHeaderView detailOverlayView] detailTextLabel] setText:[route longName]];
    [[[overlayHeaderView detailOverlayView] imageView] setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@RouteIcon_43.png", [route shortName]]]];

    [overlayHeaderView setContentView:mapView];
    
    [self setView:overlayHeaderView];
    [overlayHeaderView layoutSubviews];
    
    // Tell map to zoom to show entire route
    [mapView setRegion:[routeAnnotation region]];
}

- (void)viewDidAppear:(BOOL)animated
{    
    // If stop has been set, select it
    if (stop)
        [mapView selectAnnotation:stop animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
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
    [busButtonItem release];
}

# pragma mark -
# pragma mark MapView Delegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation
{        
    if ([annotation isKindOfClass:[Stop class]]) 
    {
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
        MKAnnotationView *busAnnotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"Bus"];
        
        if (!busAnnotationView) {
            busAnnotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Bus"] autorelease];
            [busAnnotationView setImage:[UIImage imageNamed:@"TempBusIcon.png"]];
        }
        
        [busAnnotationView setAnnotation:annotation];
        
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
        Stop *selectedStop = [view annotation];
        
        StopViewController *stopViewController = [[StopViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [stopViewController setStop:selectedStop];
        [stopViewController setRoute:route];
		[[self navigationController] pushViewController:stopViewController animated:YES];
		[stopViewController release];
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
    
    NSLog(@"Error loading map: %@", error);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

# pragma mark -
# pragma mark RealTimeInfo Methods

- (IBAction)beginContinuousBusUpdatesAction:(id)sender
{
    [self beginContinuousBusUpdates];
}

- (IBAction)endContinuousBusUpdatesAction:(id)sender
{    
    [self endContinuousBusUpdates];
}

- (void)beginContinuousBusUpdates
{    
    [busButtonItem setAction:@selector(endContinuousBusUpdatesAction:)];
    [busButtonItem setStyle:UIBarButtonItemStyleDone];
    
    busContinuousUpdatesRunning = YES;

    [self updateBusLocations:nil];
    
    // If we are still updating after the first update, fire a timer every 4 seconds
    if (busContinuousUpdatesRunning)
        busTimer = [[NSTimer scheduledTimerWithTimeInterval:4.0
                                                     target:self
                                                   selector:@selector(updateBusLocations:)
                                                   userInfo:nil
                                                    repeats:YES] retain];
}

- (void)endContinuousBusUpdates
{
    [busButtonItem setAction:@selector(beginContinuousBusUpdatesAction:)];
    [busButtonItem setStyle:UIBarButtonItemStyleBordered];
    busContinuousUpdatesRunning = NO;
    
    [busTimer invalidate];
    [busTimer release];
    busTimer = nil;
    
    if (busAnnotations)
        [mapView removeAnnotations:busAnnotations];
    
    [self setBusAnnotations:nil];
}

- (void)updateBusLocations:(NSTimer *)timer
{
    NSError *error;
    
    // Get all buses for the current route
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSArray *busInfos = [[RealTimeBusInfoManager sharedRealTimeBusInfoManager] retrieveRealTimeBusInfoWithRoute:[route shortName] error:&error];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // If busInfos is nil there was an error
    if (!busInfos) {
        [self endContinuousBusUpdates];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Update Bus Location Error" message:@"There was an error while updating bus locations. Make sure you are connected to the internet." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    
    // If there were no buses, then stop upating and alert user
    if ([busInfos count] == 0) {
        [self endContinuousBusUpdates];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Buses Found" message:@"There were no buses found for this route at this time." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    
    // Remove buses if they exsisted before
    if (busAnnotations)
        [mapView removeAnnotations:busAnnotations];
    
    // Add new bus annotations
    [mapView addAnnotations:busInfos];
    [self setBusAnnotations:busInfos];
    
    // Redraw map
    [mapView setNeedsDisplay];
}

@end
