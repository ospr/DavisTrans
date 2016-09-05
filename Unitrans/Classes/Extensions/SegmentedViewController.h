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
    ExtendedViewController *selectedViewController;
    
    UIView *contentView;
    UISegmentedControl *segmentedControl;
    UIBarButtonItem *segmentedButtonItem;
    UIBarButtonItem *flexibleSpaceItem;
    UIBarButtonItem *fixedSpaceItem;
    
    NSArray *segmentItems;
    
    CGFloat segmentWidth;
    NSTimeInterval viewTransitionDuration;
    NSMutableSet *transitionContexts;
}

@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, retain) ExtendedViewController *selectedViewController;
@property (nonatomic, readonly) UISegmentedControl *segmentedControl;
@property (nonatomic, retain) NSArray *segmentItems;

- (ExtendedViewController *)viewControllerForSelectedSegmentIndex:(NSInteger)index;
- (void)segmentIndexWasSelected:(NSInteger)index;

- (void)animateViewTransitionFromViewController:(UIViewController *)fromViewCtl toViewController:(UIViewController *)toViewCtl;
- (void)finishAnimateViewTransitionFromViewController:(ExtendedViewController *)fromViewCtl toViewController:(ExtendedViewController *)toViewCtl;

- (void)setMainView:(UIView *)newMainView;

@end

@protocol SegmentedViewControllerProtocol



@end
