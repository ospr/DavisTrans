//
//  StopViewController.h
//  Unitrans
//
//  Created by Ken Zheng on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewController.h"

@protocol StopViewControllerDelegate;

typedef enum _StopViewSectionIndex {
    SectionIndexSelectedDate = 0,
    SectionIndexStopTimes = 1
} StopViewSectionIndex;

@class Stop;
@class Route;

@interface StopViewController : TableViewController {
    Route *route;
    Stop *stop;
	
	NSArray *activeStopTimes;	// the stop times to display
	NSArray *allStopTimes;		// contains all the stop times
	NSArray *currentStopTimes;	// contains only the stop times which aren't expired
	
	NSDate *selectedDate;

	BOOL showExpiredStopTimes;
    
    // Timers
    NSTimer *expiredStopTimeTimer;
    NSTimer *nextDayTimer;
    	
	id<StopViewControllerDelegate> delegate;
}

@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) NSArray *activeStopTimes;
@property (nonatomic, retain) NSArray *allStopTimes;
@property (nonatomic, retain) NSArray *currentStopTimes;
@property (nonatomic, retain) NSDate *selectedDate;
@property (nonatomic, assign) BOOL showExpiredStopTimes;
@property (nonatomic, retain) id<StopViewControllerDelegate> delegate;

- (void)updateStopTimes;
- (void)toggleExpiredStopTimes;
- (void)filterExpiredStopTimes;
- (void)startNextDayTimer;
- (void)stopNextDayTimer;
- (void)startExpiredStopTimeTimer;
- (void)stopExpiredStopTimeTimer;
- (void)updateActiveStopTimes;

- (NSString *)selectedDateString;
- (BOOL)shouldShowNoMoreScheduledStops;
- (BOOL)noScheduledService;
- (BOOL)shouldShowNoMoreScheduledStops;

- (void)changeScheduleDateTo:(NSDate *)newSelectedDate;
- (void)chooseNewScheduleDateDidEndWithDate:(NSDate *)newDate;
- (void)chooseNewScheduleDate;


@end

// Delegate methods
@protocol StopViewControllerDelegate <NSObject>
@required
- (void) stopViewController:(StopViewController *)stopviewController showDatePickerWithDate:(NSDate *)date;
@end

