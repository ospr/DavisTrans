//
//  StopSegmentedViewController.h
//  DavisTrans
//
//  Created by Kip on 12/27/09.
//  Copyright 2009 Kip Nicol & Ken Zheng
//

#import <UIKit/UIKit.h>

#import "SegmentedViewController.h"
#import "StopViewController.h"

@class Route;
@class Stop;
@class RouteMapViewController;
@class DetailOverlayView;
@class PredictionsView;

@interface StopSegmentedViewController : SegmentedViewController <StopViewControllerDelegate> {
    Route *route;
    Stop *stop;
    
    StopViewController *stopViewController;
    RouteMapViewController *routeMapViewController;
    
    DetailOverlayView *detailOverlayView;
    PredictionsView *predictionsView;
    UITableView *fakeTableView;
	
	UIDatePicker *datePicker;
	UIBarButtonItem *datePickerDone;
	UIBarButtonItem *datePickerCancel;
	UIBarButtonItem *backButton;
	
	BOOL isFavorite;
}

@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) StopViewController *stopViewController;
@property (nonatomic, retain) RouteMapViewController *routeMapViewController;
@property (nonatomic, retain) DetailOverlayView *detailOverlayView;
@property (nonatomic, retain) PredictionsView *predictionsView;
@property (nonatomic, retain) UITableView *fakeTableView;
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic, retain) UIBarButtonItem *datePickerDone;
@property (nonatomic, retain) UIBarButtonItem *datePickerCancel;
@property (nonatomic, assign) UIBarButtonItem *backButton;
@property (nonatomic, assign) BOOL isFavorite;

- (void) dismissDatePicker;

- (void)showPredictionViewWithAnimation;
- (void)hidePredictionViewWithAnimation;

@end

