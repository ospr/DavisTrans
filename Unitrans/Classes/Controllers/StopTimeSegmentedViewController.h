//
//  StopTimeSegmentedViewController.h
//  Unitrans
//
//  Created by Kip on 12/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SegmentedViewController.h"

@class StopTime;
@class StopTimeViewController;

@interface StopTimeSegmentedViewController : SegmentedViewController {
    StopTime *stopTime;
    
    StopTimeViewController *stopTimeViewController;
}

@property (nonatomic, retain) StopTime *stopTime;

@end
