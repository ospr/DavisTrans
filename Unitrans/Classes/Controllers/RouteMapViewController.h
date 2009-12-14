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
@class CSRouteView;
@class OverlayHeaderView;
@class CSRouteAnnotation;

@interface RouteMapViewController : UIViewController <MKMapViewDelegate, BusInformationOperationDelegate> {
    Route *route;
    Stop *stop;
    
    BusInformationOperation *busInformationOperation;
    NSTimer *busTimer;
    NSArray *busAnnotations;
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
@property (nonatomic, retain) BusInformationOperation *busInformationOperation;
@property (nonatomic, retain) NSArray *busAnnotations;

- (void)zoomFitAnimated:(BOOL)animated;
- (void)beginContinuousBusUpdates;
- (void)endContinuousBusUpdates;
- (void)updateBusLocations;

@end
