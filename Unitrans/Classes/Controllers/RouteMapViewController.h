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
@class CSRouteView;
@class CSRouteAnnotation;

@interface RouteMapViewController : ExtendedViewController <MKMapViewDelegate, BusInformationOperationDelegate, UIActionSheetDelegate> {
    Route *route;
    Stop *stop;
    RoutePattern *routePattern;
    
    BusInformationOperation *busInformationOperation;
    NSTimer *busTimer;
    NSTimeInterval busUpdateInterval;
    NSArray *busAnnotations;
    NSArray *stopAnnotations;
    CSRouteAnnotation *routeAnnotation;
    
    BOOL mapViewIsLoaded;
    BOOL busContinuousUpdatesRunning;
    BOOL errorShown;
    
    MKMapView *mapView;
    CSRouteView *routeAnnotationView;
}

@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) RoutePattern *routePattern;
@property (nonatomic, retain) BusInformationOperation *busInformationOperation;
@property (nonatomic, retain) NSArray *busAnnotations;
@property (nonatomic, retain) NSArray *stopAnnotations;
@property (nonatomic, retain) CSRouteAnnotation *routeAnnotation;
@property (nonatomic, retain) CSRouteView *routeAnnotationView;

- (void)loadMapView;

- (void)zoomFitAnimated:(BOOL)animated;
- (void)beginContinuousBusUpdates;
- (void)endContinuousBusUpdates;
- (void)updateBusLocations;
- (void)updateMapWithRoutePattern:(RoutePattern *)newRoutePattern;

@end
