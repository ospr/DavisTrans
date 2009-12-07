//
//  StopViewController.h
//  Unitrans
//
//  Created by Ken Zheng on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewController.h"
#import "PredictionOperation.h"

@class Stop;
@class Route;
@class OverlayHeaderView;

@interface StopViewController : TableViewController <PredictionOperationDelegate> {
    Route *route;
    Stop *stop;
	NSArray *stopTimes;
    NSArray *predictions;
    PredictionOperation *predictionOperation;
	NSDate *selectedDate; // defaults to today
    NSTimer *expiredStopTimeTimer;
	NSDateFormatter *selectedDateFormatter;
	NSDateFormatter *dayOfWeekFormatter;
	NSDateFormatter *referenceDateFormatter;
	NSDateFormatter *referenceDateTimeFormatter;
    UIActivityIndicatorView *predictionLoadingIndicatorView;
    BOOL loadingPredictions;
    
    OverlayHeaderView *overlayHeaderView;
}

@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) NSArray *stopTimes;
@property (nonatomic, retain) NSArray *predictions;
@property (nonatomic, retain) PredictionOperation *predictionOperation;
@property (nonatomic, retain) NSDate *selectedDate;
@property (nonatomic, retain) NSDateFormatter *selectedDateFormatter;
@property (nonatomic, retain) NSDateFormatter *referenceDateFormatter;
@property (nonatomic, retain) NSDateFormatter *referenceDateTimeFormatter;

- (void) updateStopTimes;
- (void) addUpdateNextStopTimeTimer;
- (void) updateStopTimePredictions;

@end
