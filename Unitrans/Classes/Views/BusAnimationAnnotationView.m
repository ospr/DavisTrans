//
//  BusAnimationAnnotationView.m
//  Unitrans
//
//  Created by Kip on 12/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BusAnimationAnnotationView.h"
#import "AnimationImageView.h"


@implementation BusAnimationAnnotationView

@synthesize imageView;

- (id)initWithAnnotation:annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self) {        
        UIImage *busImage = [UIImage imageNamed:@"BusTokenIcon.png"];
        NSArray *animationImages = [NSArray arrayWithObjects:
                                    [UIImage imageNamed:@"RedCircle8.png"],
                                    [UIImage imageNamed:@"RedCircle7.png"],
                                    [UIImage imageNamed:@"RedCircle6.png"],
                                    [UIImage imageNamed:@"RedCircle5.png"],
                                    [UIImage imageNamed:@"RedCircle4.png"],
                                    [UIImage imageNamed:@"RedCircle3.png"],
                                    nil];
        
        imageView = [[AnimationImageView alloc] initWithStaticImage:busImage animationImages:animationImages];
        [imageView setAnimationDuration:1];
        [imageView setAnimationDelay:1.5];
        [imageView startAnimating];
        [self addSubview:imageView];
    }
    
    return self;
}

@end
