//
//  BusAnimationAnnotationView.h
//  Unitrans
//
//  Created by Kip on 12/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class AnimationImageView;

@interface BusAnimationAnnotationView : MKAnnotationView {
    AnimationImageView *imageView;
	UIImageView *busArrowImageView;
}

@property (nonatomic, retain) AnimationImageView *imageView;
@property (nonatomic, retain) UIImageView *busArrowImageView;

@end
