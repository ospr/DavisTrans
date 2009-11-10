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
@class CSRouteView;

@interface RouteMapViewController : UIViewController {
    IBOutlet MKMapView *mapView;
    UIBarButtonItem *busButtonItem;
    
    Route *route;
    
    CSRouteView *routeAnnotationView;
    
    NSTimer *busTimer;
    NSArray *busAnnotations;
    BOOL busContinuousUpdatesRunning;
}

@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) NSArray *busAnnotations;

- (void)beginContinuousBusUpdates;
- (void)endContinuousBusUpdates;

@end
