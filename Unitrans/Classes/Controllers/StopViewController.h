//
//  StopViewController.h
//  Unitrans
//
//  Created by Ken Zheng on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewController.h"

@class Stop;
@class Route;
@class OverlayHeaderView;

@interface StopViewController : TableViewController {
    Route *route;
    Stop *stop;
	NSArray *stopTimes;
    NSArray *predictions;
	NSDate *selectedDate; // defaults to today
    NSTimer *expiredStopTimeTimer;
	NSDateFormatter *selectedDateFormatter;
	NSDateFormatter *dayOfWeekFormatter;
	NSDateFormatter *referenceDateFormatter;
	NSDateFormatter *referenceDateTimeFormatter;
	BOOL isLoadingPrediction;
    
    OverlayHeaderView *overlayHeaderView;
}

@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) NSArray *stopTimes;
@property (nonatomic, retain) NSArray *predictions;
@property (nonatomic, retain) NSDate *selectedDate;
@property (nonatomic, retain) NSDateFormatter *selectedDateFormatter;
@property (nonatomic, retain) NSDateFormatter *referenceDateFormatter;
@property (nonatomic, retain) NSDateFormatter *referenceDateTimeFormatter;
@property (nonatomic, assign) BOOL isLoadingPrediction;

- (void) updateStopTimes;
- (void) addUpdateNextStopTimeTimer;
- (void) updateStopTimePredictions;
- (void) showActivity:(BOOL)show atTableViewCell:(UITableViewCell *)tableviewCell;

@end
