//
//  SegmentedViewController.h
//  Unitrans
//
//  Created by Kip on 12/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ExtendedViewController;

@interface SegmentedViewController : UIViewController {
    UIViewController *selectedViewController;
    
    UISegmentedControl *segmentedControl;
    UIBarButtonItem *segmentedButtonItem;
    UIBarButtonItem *flexibleSpaceItem;
    
    NSArray *segmentItems;
    
    CGFloat segmentWidth;
    NSTimeInterval viewTransitionDuration;
}

@property (nonatomic, retain) UIViewController *selectedViewController;
@property (nonatomic, readonly) UISegmentedControl *segmentedControl;
@property (nonatomic, retain) NSArray *segmentItems;

- (ExtendedViewController *)viewControllerForSelectedSegmentIndex:(NSInteger)index;
- (void)segmentIndexWasSelected:(NSInteger)index;

- (void)animateViewTransition:(UIViewAnimationTransition)transition fromViewController:(UIViewController *)fromViewCtl toViewController:(UIViewController *)toViewCtl;

@end

@protocol SegmentedViewControllerProtocol



@end
