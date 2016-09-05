//
//  RouteMapViewController.h
//  Unitrans
//
//  Created by Kip Nicol on 11/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BusInformationOperation.h"
#import "ExtendedViewController.h"

@class Route;
@class Stop;
@class RoutePattern;

@interface RouteMapViewController : ExtendedViewController <MKMapViewDelegate, BusInformationOperationDelegate, UIActionSheetDelegate> {
    Route *route;
    Stop *stop;
    RoutePattern *routePattern;
    
    NSOperationQueue *operationQueue;
    CLLocationManager *locationManager;
    NSTimer *busTimer;
    NSTimeInterval busUpdateInterval;
    NSArray *stopAnnotations;
    
    BOOL mapViewIsLoaded;
    BOOL busContinuousUpdatesRunning;
    BOOL errorShown;
    
    MKMapView *mapView;
}

@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) RoutePattern *routePattern;
@property (nonatomic, retain) NSArray *stopAnnotations;
@property (nonatomic, readonly) NSArray *busAnnotations;

- (void)loadMapView;

- (void)zoomFitAnimated:(BOOL)animated includeUserLocation:(BOOL)userLocation;
- (void)beginContinuousBusUpdates;
- (void)endContinuousBusUpdates;
- (void)updateBusLocations;
- (void)updateMapWithRoutePattern:(RoutePattern *)newRoutePattern;

- (void)showError:(NSError *)error;

@end
