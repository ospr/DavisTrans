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
@synthesize busArrowImageView;

- (id)initWithAnnotation:annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self) {    
		UIImage *busArrowImage = [UIImage imageNamed:@"BusArrow.png"];
		busArrowImageView = [[UIImageView alloc] initWithImage:busArrowImage];
		
		// Position the arrow correctly with the BusTokenIcon
		[busArrowImageView setFrame:CGRectMake(3, 4, busArrowImage.size.width, busArrowImage.size.height)];
		
        UIImage *busImage = [UIImage imageNamed:@"BusTokenIcon.png"];
        
        // Add circle pulses
        NSMutableArray *animationImages = [NSMutableArray array];
        for (int red_index = 24; red_index <= 100 ; red_index += 4) {
            [animationImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png", red_index]]];
        }
        
        imageView = [[AnimationImageView alloc] initWithStaticImage:busImage animationImages:animationImages];
        [imageView setAnimationDuration:0.75];
        [imageView setAnimationDelay:0.0]; // No delay needed since we create a new annotationview everytime we update the bus location
        [imageView startAnimating];
        [self addSubview:imageView];
		[self addSubview:busArrowImageView];
        
        // Now set the frame so that it just encloses the imageView
        [self setFrame:CGRectMake(0, 0, [imageView frame].size.width, [imageView frame].size.height)];
    }
    
    return self;
}

- (void)animate
{
    [imageView startAnimating];
}

- (void)dealloc
{
	[busArrowImageView release];
	[super dealloc];
}

@end
