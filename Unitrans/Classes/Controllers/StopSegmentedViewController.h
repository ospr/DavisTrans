//
//  StopSegmentedViewController.h
//  Unitrans
//
//  Created by Kip on 12/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SegmentedViewController.h"
#import "StopViewController.h"
#import "DatePickerController.h"

@class Route;
@class Stop;
@class RouteMapViewController;

@interface StopSegmentedViewController : SegmentedViewController <StopViewControllerDelegate, DatePickerControllerDelegate> {
    Route *route;
    Stop *stop;
    
    StopViewController *stopViewController;
    RouteMapViewController *routeMapViewController;
}

@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) Stop *stop;

@end
