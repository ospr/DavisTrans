//
//  OverlayHeaderView.h
//  Unitrans
//
//  Created by Kip Nicol on 11/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailOverlayView;

@interface OverlayHeaderView : UIView {
    DetailOverlayView *detailOverlayView;
    UIView *contentView;
}

@property (nonatomic, retain) DetailOverlayView *detailOverlayView;
@property (nonatomic, retain) UIView *contentView;

@end
