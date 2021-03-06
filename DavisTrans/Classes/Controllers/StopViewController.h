//
//  StopViewController.h
//  DavisTrans
//
//  Created by Ken Zheng on 11/2/09.
//  Copyright 2009 Kip Nicol & Ken Zheng
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
	
    BOOL hasScheduledStopTimesButNoDepartingStopTimes;      // whether there are any departing stops
	NSArray *activeStopTimes;	// the stop times to display
	NSArray *allDepartingStopTimes;		// contains all the stop times
	NSArray *currentStopTimes;	// contains only the stop times which aren't expired
	
	NSDate *selectedDate;
    NSDate *temporaryDate;

	BOOL showExpiredStopTimes;
    BOOL chooseNewScheduleDateMode;
    
    // Timers
    NSTimer *expiredStopTimeTimer;
    NSTimer *nextDayTimer;
    	
	id<StopViewControllerDelegate> delegate;
}

@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, assign) BOOL hasScheduledStopTimesButNoDepartingStopTimes;
@property (nonatomic, retain) NSArray *activeStopTimes;
@property (nonatomic, retain) NSArray *allDepartingStopTimes;
@property (nonatomic, retain) NSArray *currentStopTimes;
@property (nonatomic, retain) NSDate *selectedDate;
@property (nonatomic, retain) NSDate *temporaryDate;
@property (nonatomic, assign) BOOL showExpiredStopTimes;
@property (nonatomic, readonly) BOOL isFavorite;
@property (nonatomic, assign) id<StopViewControllerDelegate> delegate;

- (void)determineIfStopHasScheduledStopTimesButNoDepartingStopTimes;
- (void)sortStopTimes;
- (void)updateStopTimes;
- (void)toggleExpiredStopTimes;
- (void)filterExpiredStopTimes;
- (void)startNextDayTimer;
- (void)stopNextDayTimer;
- (void)startExpiredStopTimeTimer;
- (void)stopExpiredStopTimeTimer;
- (void)updateActiveStopTimes;
- (void)updateFavoritesButton;

- (NSString *)stringForDate:(NSDate *)date;
- (BOOL)shouldShowNoMoreScheduledStops;
- (BOOL)noScheduledService;

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

