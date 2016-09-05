//
//  StopTimeSegmentedViewController.h
//  DavisTrans
//
//  Created by Kip on 12/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SegmentedViewController.h"

@class Route;
@class StopTime;
@class StopTimeViewController;

@interface StopTimeSegmentedViewController : SegmentedViewController {
    Route *route;
    StopTime *stopTime;
    
    StopTimeViewController *stopTimeViewController;
}

@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) StopTime *stopTime;
@property (nonatomic, retain) StopTimeViewController *stopTimeViewController;

@end
