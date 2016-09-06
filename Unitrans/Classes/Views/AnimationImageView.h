//
//  AnimationImageView.h
//  DavisTrans
//
//  Created by Kip on 12/4/09.
//  Copyright 2009 Kip Nicol & Ken Zheng
//

#import <UIKit/UIKit.h>


@interface AnimationImageView : UIImageView {
    UIImageView *staticImageView;
    
    CGFloat animationDelay;
}

@property (nonatomic, retain) UIImageView *staticImageView;
@property (nonatomic, assign) CGFloat animationDelay;

- (id)initWithStaticImage:(UIImage *)staticImage animationImages:(NSArray *)animationImages;

@end
