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

@interface StopViewController : TableViewController <UIActionSheetDelegate> {
    Route *route;
    Stop *stop;
	
	NSArray *activeStopTimes;	// the stop times to display
	NSArray *allStopTimes;		// contains all the stop times
	NSArray *currentStopTimes;	// contains only the stop times which aren't expired
	
	NSDate *selectedDate;
    NSDate *temporaryDate;

	BOOL showExpiredStopTimes;
    BOOL chooseNewScheduleDateMode;
	BOOL isFavorite;
    
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
@property (nonatomic, retain) NSDate *temporaryDate;
@property (nonatomic, assign) BOOL showExpiredStopTimes;
@property (nonatomic, assign) BOOL isFavorite;
@property (nonatomic, assign) id<StopViewControllerDelegate> delegate;

- (void)sortStopTimes;
- (void)updateStopTimes;
- (void)toggleExpiredStopTimes;
- (void)filterExpiredStopTimes;
- (void)startNextDayTimer;
- (void)stopNextDayTimer;
- (void)startExpiredStopTimeTimer;
- (void)stopExpiredStopTimeTimer;
- (void)updateActiveStopTimes;

- (NSString *)stringForDate:(NSDate *)date;
- (BOOL)shouldShowNoMoreScheduledStops;
- (BOOL)noScheduledService;
- (BOOL)shouldShowNoMoreScheduledStops;

- (void)changeScheduleDateTo:(NSDate *)newSelectedDate;
- (void)chooseNewScheduleDateDidEndWithDate:(NSDate *)newDate;
- (void)chooseNewScheduleDate;
- (void)datePickerValueDidChangeWithDate:(NSDate *)newDate;

@end

// Delegate methods
@protocol StopViewControllerDelegate <NSObject>
@required
- (void) stopViewController:(StopViewController *)stopviewController showDatePickerWithDate:(NSDate *)date;
- (void) dismissDatePickerWithDate:(NSDate *)date;
@end

