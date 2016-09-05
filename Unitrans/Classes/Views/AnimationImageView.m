//
//  AnimationImageView.m
//  DavisTrans
//
//  Created by Kip on 12/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AnimationImageView.h"


@implementation AnimationImageView

@synthesize staticImageView;
@synthesize animationDelay;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        // Only animate once so we can pause (delay) for a period of time before resetting
        [self setAnimationRepeatCount:1];
        
        staticImageView = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:staticImageView];
    }
    return self;
}

- (id)initWithStaticImage:(UIImage *)staticImage animationImages:(NSArray *)animationImages
{
    CGRect frame = CGRectZero;
    frame.size = [[animationImages objectAtIndex:0] size];
    
    self = [self initWithFrame:frame];
    
    if (self) {
        // Set image and center in view
        [staticImageView setImage:staticImage];
        [staticImageView setFrame:CGRectMake(0, 0, [staticImage size].width, [staticImage size].height)];
        [staticImageView setCenter:[self center]];
        [self addSubview:staticImageView];
        
        [self setAnimationImages:animationImages];
    }
    
    return self;
}

- (void)dealloc 
{
    [staticImageView release];
    
    [super dealloc];
}

- (void)startAnimating
{    
    // Fire off the animation after animationDuration+animationDelay time if it's not zero
    if (animationDelay > 0.00001)
        [NSTimer scheduledTimerWithTimeInterval:([self animationDuration] + animationDelay)
                                         target:self 
                                       selector:@selector(resetAnimation:) 
                                       userInfo:nil
                                        repeats:NO];
    
    [super startAnimating];
}

- (void)resetAnimation:(NSTimer *)timer
{
    [self startAnimating];
}

@end
