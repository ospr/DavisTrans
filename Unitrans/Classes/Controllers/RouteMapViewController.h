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

@class Route;
@class Stop;
@class CSRouteView;
@class OverlayHeaderView;

@interface RouteMapViewController : UIViewController <MKMapViewDelegate> {
    IBOutlet MKMapView *mapView;
    OverlayHeaderView *overlayHeaderView;
    UIBarButtonItem *busButtonItem;
    
    Route *route;
    Stop *stop;
    
    CSRouteView *routeAnnotationView;
    
    NSTimer *busTimer;
    NSArray *busAnnotations;
    BOOL busContinuousUpdatesRunning;
    
    BOOL errorShown;
}

@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) NSArray *busAnnotations;

- (void)beginContinuousBusUpdates;
- (void)endContinuousBusUpdates;
- (void)updateBusLocations:(NSTimer *)timer;

@end
