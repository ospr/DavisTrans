//
//  ExtendedViewController.h
//  Unitrans
//
//  Created by Kip on 12/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SegmentedViewController;

@interface ExtendedViewController : UIViewController {
    SegmentedViewController *segmentedViewController;
}

@property (nonatomic, retain) SegmentedViewController *segmentedViewController;

@end
