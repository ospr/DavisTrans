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

typedef enum _StopViewSectionIndex {
    SectionIndexSelectedDate = 0,
    SectionIndexPredictions = 1,
    SectionIndexStopTimes = 2
} StopViewSectionIndex;

@class Stop;
@class Route;

@interface StopViewController : TableViewController <PredictionOperationDelegate> {
    Route *route;
    Stop *stop;
	NSArray *stopTimes;
    NSArray *predictions;
	NSDate *selectedDate;

    BOOL predictionsContinuousUpdatesRunning;
    BOOL loadingPredictions;
    
    // Timers
    NSTimer *expiredStopTimeTimer;
    NSTimer *predictionTimer;

    // Operations
    PredictionOperation *predictionOperation;
    
    // Subviews
    UIActivityIndicatorView *predictionLoadingIndicatorView;
}

@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) NSArray *stopTimes;
@property (nonatomic, retain) NSArray *predictions;
@property (nonatomic, retain) NSDate *selectedDate;
@property (nonatomic, retain) PredictionOperation *predictionOperation;

- (void) updateStopTimes;
- (void) addUpdateNextStopTimeTimer;
- (void) updateStopTimePredictions;

- (void)beginContinuousPredictionsUpdates;
- (void)endContinuousPredictionsUpdates;

- (NSString *)selectedDateString;
- (NSString *)predictionString;

@end
