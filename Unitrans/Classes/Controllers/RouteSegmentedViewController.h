//
//  RouteSegmentedViewController.h
//  DavisTrans
//
//  Created by Kip on 12/26/09.
//  Copyright 2009 Kip Nicol & Ken Zheng
//

#import <UIKit/UIKit.h>
#import "SegmentedViewController.h"

@class Route;
@class RouteViewController;
@class RouteMapViewController;

@interface RouteSegmentedViewController : SegmentedViewController {
    Route *route;
    
    RouteViewController *routeViewController;
    RouteMapViewController *routeMapViewController;
}

@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) RouteViewController *routeViewController;
@property (nonatomic, retain) RouteMapViewController *routeMapViewController;

@end
