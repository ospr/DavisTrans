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

@class Route;
@class Stop;
@class RoutePattern;
@class CSRouteView;
@class OverlayHeaderView;
@class CSRouteAnnotation;

@interface RouteMapViewController : UIViewController <MKMapViewDelegate, BusInformationOperationDelegate, UIActionSheetDelegate> {
    Route *route;
    Stop *stop;
    RoutePattern *routePattern;
    
    BusInformationOperation *busInformationOperation;
    NSTimer *busTimer;
    NSArray *busAnnotations;
    NSArray *stopAnnotations;
    CSRouteAnnotation *routeAnnotation;
    
    BOOL busContinuousUpdatesRunning;
    BOOL errorShown;
    
    MKMapView *mapView;
    CSRouteView *routeAnnotationView;
    OverlayHeaderView *overlayHeaderView;
}

@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) RoutePattern *routePattern;
@property (nonatomic, retain) BusInformationOperation *busInformationOperation;
@property (nonatomic, retain) NSArray *busAnnotations;
@property (nonatomic, retain) NSArray *stopAnnotations;

- (void)zoomFitAnimated:(BOOL)animated;
- (void)beginContinuousBusUpdates;
- (void)endContinuousBusUpdates;
- (void)updateBusLocations;
- (void)updateMapWithRoutePattern:(RoutePattern *)newRoutePattern;

@end
