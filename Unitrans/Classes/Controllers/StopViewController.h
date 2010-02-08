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

@protocol StopViewControllerDelegate;

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
	
	NSArray *activeStopTimes;	// the stop times to display
	NSArray *allStopTimes;		// contains all the stop times
	NSArray *currentStopTimes;	// contains only the stop times which aren't expired
    NSArray *predictions;
	
	NSDate *selectedDate;

    BOOL predictionsContinuousUpdatesRunning;
    BOOL loadingPredictions;
	BOOL showExpiredStopTimes;
    
    // Timers
    NSTimer *expiredStopTimeTimer;
    NSTimer *predictionTimer;

    // Operations
    PredictionOperation *predictionOperation;
    
    // Subviews
    UIActivityIndicatorView *predictionLoadingIndicatorView;
	
	id<StopViewControllerDelegate> delegate;
}

@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) NSArray *activeStopTimes;
@property (nonatomic, retain) NSArray *allStopTimes;
@property (nonatomic, retain) NSArray *currentStopTimes;
@property (nonatomic, retain) NSArray *predictions;
@property (nonatomic, retain) NSDate *selectedDate;
@property (nonatomic, assign) BOOL showExpiredStopTimes;
@property (nonatomic, retain) PredictionOperation *predictionOperation;
@property (nonatomic, retain) id<StopViewControllerDelegate> delegate;

- (void) updateStopTimes;
- (void) addUpdateNextStopTimeTimer;
- (void) updateStopTimePredictions;

- (void)beginContinuousPredictionsUpdates;
- (void)endContinuousPredictionsUpdates;

- (NSString *)selectedDateString;
- (NSString *)predictionString;

@end

// Delegate methods
@protocol StopViewControllerDelegate <NSObject>
@required
- (void) stopViewController:(StopViewController *)stopviewController showDatePickerWithDate:(NSDate *)date;
@end

