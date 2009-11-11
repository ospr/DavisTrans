//
//  StopTimeViewController.h
//  Unitrans
//
//  Created by Ken Zheng on 11/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StopTime;

@interface StopTimeViewController : UITableViewController {
    StopTime *stopTime;
    
	NSArray *arrivalTimes;
}

@property (nonatomic, retain) StopTime *stopTime;
@property (nonatomic, retain) NSArray *arrivalTimes;

@end
