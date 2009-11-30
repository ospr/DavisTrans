//
//  DetailOverlayView.h
//  Unitrans
//
//  Created by Kip Nicol on 11/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DetailOverlayView : UIView {
    UIImageView *imageView;
    UILabel *textLabel;
    UILabel *detailTextLabel;
    
    CGFloat shadowOffset;
}

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UILabel *textLabel;
@property (nonatomic, retain) UILabel *detailTextLabel;
@property (nonatomic, assign) CGFloat shadowOffset;

@end
