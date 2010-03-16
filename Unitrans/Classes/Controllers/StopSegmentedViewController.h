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

@class Route;
@class Stop;
@class RouteMapViewController;
@class PredictionsView;

@interface StopSegmentedViewController : SegmentedViewController <StopViewControllerDelegate> {
    Route *route;
    Stop *stop;
    
    StopViewController *stopViewController;
    RouteMapViewController *routeMapViewController;
    
    PredictionsView *predictionsView;
	
	UIDatePicker *datePicker;
	UIBarButtonItem *datePickerDone;
	UIBarButtonItem *datePickerCancel;
	UIBarButtonItem *backButton;
}

@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) StopViewController *stopViewController;
@property (nonatomic, retain) RouteMapViewController *routeMapViewController;
@property (nonatomic, retain) PredictionsView *predictionsView;
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic, retain) UIBarButtonItem *datePickerDone;
@property (nonatomic, retain) UIBarButtonItem *datePickerCancel;
@property (nonatomic, assign) UIBarButtonItem *backButton;

- (void) dismissDatePicker;

@end

