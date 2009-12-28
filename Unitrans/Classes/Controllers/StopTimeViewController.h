//
//  StopTimeViewController.h
//  Unitrans
//
//  Created by Ken Zheng on 11/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewController.h"

typedef enum _StopTimeViewDataType {
    kStopTimeViewDataTypeArrivalTimes,
    kStopTimeViewDataTypeDepartureTimes
} StopTimeViewDataType;

@class StopTime;
@class OverlayHeaderView;

@interface StopTimeViewController : TableViewController {
    StopTime *stopTime;
	NSArray *arrivalTimes;
    
    OverlayHeaderView *overlayHeaderView;
    
    StopTimeViewDataType dataType;
}

@property (nonatomic, retain) StopTime *stopTime;
@property (nonatomic, retain) NSArray *arrivalTimes;
@property (nonatomic, assign) StopTimeViewDataType dataType;

- (void)updateStopTimes;

@end
