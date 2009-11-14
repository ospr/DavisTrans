//
//  StopViewController.h
//  Unitrans
//
//  Created by Ken Zheng on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Stop;
@class Route;

@interface StopViewController : UITableViewController {
    Route *route;
    Stop *stop;
	NSArray *stopTimes;
	NSDate *selectedDate; // defaults to today
	NSDateFormatter *selectedDateFormatter;
	NSDateFormatter *referenceDateFormatter;
	NSDateFormatter *referenceDateTimeFormatter;
	UIDatePicker *datePicker;
	UIActionSheet *datePickerSheet;
}

@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) NSArray *stopTimes;
@property (nonatomic, retain) NSDate *selectedDate;
@property (nonatomic, retain) NSDateFormatter *selectedDateFormatter;
@property (nonatomic, retain) NSDateFormatter *referenceDateFormatter;
@property (nonatomic, retain) NSDateFormatter *referenceDateTimeFormatter;
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic, retain) UIActionSheet *datePickerSheet;

- (IBAction) datePickerDoneClicked:(id)sender;
- (IBAction) datePickerCancelClicked:(id)sender;

- (void)updateStopTimes;

@end
