//
//  DetailOverlayView.m
//  Unitrans
//
//  Created by Kip Nicol on 11/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DetailOverlayView.h"


@implementation DetailOverlayView

@synthesize imageView;
@synthesize textLabel;
@synthesize detailTextLabel;
@synthesize shadowOffset;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setShadowOffset:3.0];
        [self setBackgroundColor:[UIColor clearColor]];
        
        // Init imageview
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [imageView setIsAccessibilityElement:NO];
        [self addSubview:imageView];
        
        // Init textLabel
        textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [textLabel setFont:[UIFont boldSystemFontOfSize:17]];
        [textLabel setTextColor:[UIColor blackColor]];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setIsAccessibilityElement:NO];
        [self addSubview:textLabel];
        
        // Init detailTextLabel
        detailTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [detailTextLabel setFont:[UIFont boldSystemFontOfSize:10]];
        [detailTextLabel setTextColor:[UIColor blackColor]];
        [detailTextLabel setBackgroundColor:[UIColor clearColor]];
        [detailTextLabel setIsAccessibilityElement:NO];
        [self addSubview:detailTextLabel];
    }
    
    return self;
}

- (void)dealloc 
{
    [imageView release];
    [textLabel release];
    [detailTextLabel release];
    
    [super dealloc];
}
                     
- (void)layoutSubviews
{    
    // Padding between text and image
    CGFloat textImagePadding = 5.0;
    
    // ImageViewFrame
    // Size: Size of image
    // Origin: x = 0, y = point where image is centered horizontally
    CGRect imageViewFrame;
    imageViewFrame.size = [[imageView image] size];
    imageViewFrame.origin = CGPointMake(0, ([self bounds].size.height - imageViewFrame.size.height) / 2.0);
    [imageView setFrame:imageViewFrame];
    
    // TextLabelFrame
    // Size: width = bound's width - imageView's furthest x value + padding, height = font height
    // Origin: x = imageView's furthest x value + padding, y = bottom label rests on center line
    CGRect textLabelFrame;
    CGSize textLabelFontSize = [[textLabel text] sizeWithAttributes:@{NSFontAttributeName: [textLabel font]}];
    textLabelFrame.origin = CGPointMake(imageViewFrame.origin.x + imageViewFrame.size.width + textImagePadding, ([self bounds].size.height / 2.0) - textLabelFontSize.height);
    textLabelFrame.size = CGSizeMake([self bounds].size.width - textLabelFrame.origin.x, textLabelFontSize.height);
    [textLabel setFrame:textLabelFrame];
    [textLabel setAdjustsFontSizeToFitWidth:YES];
    
    // DetailTextLabelFrame
    // Size: width = width of textLabelFrame, height = font height
    // Origin: x = x origin of textLabelFrame, y = 2 points below bounds center
    CGRect detailTextLabelFrame;
    CGSize detailTextLabelFontSize = [[detailTextLabel text] sizeWithAttributes:@{NSFontAttributeName: [detailTextLabel font]}];
    detailTextLabelFrame.size = CGSizeMake(textLabelFrame.size.width, detailTextLabelFontSize.height);
    detailTextLabelFrame.origin = CGPointMake(textLabelFrame.origin.x, ([self bounds].size.height / 2.0) + 2.0);
    [detailTextLabel setFrame:detailTextLabelFrame];
    [detailTextLabel setAdjustsFontSizeToFitWidth:YES];
}

- (BOOL)isAccessibilityElement {
    return YES;
}

@end
