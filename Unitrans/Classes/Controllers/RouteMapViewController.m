//
//  RouteMapViewController.m
//  Unitrans
//
//  Created by Kip Nicol on 11/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RouteMapViewController.h"
#import "StopViewController.h"
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

- (void)dealloc 
{
    [route release];
    [routeAnnotationView release];
    
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    // For now get a random trip
    Trip *trip = [[route trips] anyObject];
       
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
    for (Stop *stop in [trip stops])
        [mapView addAnnotation:stop];
    
    // Tell map to zoom to show entire route
    [mapView setRegion:[routeAnnotation region]];
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

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    // Hide route view when resizing
    [routeAnnotationView setHidden:YES];
}

- (void)mapView:(MKMapView *)mv regionDidChangeAnimated:(BOOL)animated
{
    // Update route path after region changed
    [routeAnnotationView regionChanged];
	[routeAnnotationView setHidden:NO];
}

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation
{        
    if ([annotation isKindOfClass:[Stop class]]) 
    {
        MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Stop"];
        
        if (!pinAnnotationView) {
            pinAnnotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Stop"] autorelease];
            [pinAnnotationView setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
            [pinAnnotationView setCanShowCallout:YES];
            [pinAnnotationView setEnabled:YES];
        }

        return pinAnnotationView;
    }
    else if ([annotation isKindOfClass:[CSRouteAnnotation class]])
    {
        return routeAnnotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mv annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"callout");
    
    if ([[view annotation] isKindOfClass:[Stop class]])
    {
        Stop *stop = [view annotation];
        
        StopViewController *stopViewController = [[StopViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [stopViewController setStop:stop];
        [stopViewController setRoute:route];
		[[self navigationController] pushViewController:stopViewController animated:YES];
		[stopViewController release];
    }
}

@end
