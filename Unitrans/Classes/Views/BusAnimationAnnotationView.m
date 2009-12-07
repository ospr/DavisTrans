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
        [imageView setAnimationDelay:0.0]; // No delay needed since we create a new annotationview everytime we update the bus location
        [imageView startAnimating];
        [self addSubview:imageView];
        
        // Now set the frame so that it just encloses the imageView
        [self setFrame:CGRectMake(0, 0, [imageView frame].size.width, [imageView frame].size.height)];
    }
    
    return self;
}

@end
