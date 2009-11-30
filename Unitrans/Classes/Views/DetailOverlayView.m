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
        [self addSubview:imageView];
        
        // Init textLabel
        textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [textLabel setFont:[UIFont boldSystemFontOfSize:17]];
        [textLabel setTextColor:[UIColor whiteColor]];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:textLabel];
        
        // Init detailTextLabel
        detailTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [detailTextLabel setFont:[UIFont boldSystemFontOfSize:10]];
        [detailTextLabel setTextColor:[UIColor whiteColor]];
        [detailTextLabel setBackgroundColor:[UIColor clearColor]];
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
    [imageView setFrame:CGRectMake(10, 7, 43, 43)];
    [textLabel setFrame:CGRectMake(61, 7, 229, 21)];
    [detailTextLabel setFrame:CGRectMake(61, 29, 229, 21)];
}

- (void)drawRect:(CGRect)rect 
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGRect bounds = [self bounds];
    CGRect boundsOffset = CGRectOffset(bounds, 0, -shadowOffset);
    CGSize myShadowOffset = CGSizeMake(0, -shadowOffset);
    
    CGContextSetShadow(context, myShadowOffset, 20);

    CGContextSetRGBFillColor(context, 163/255.0, 50/255.0, 52/255.0, 1);
    CGContextFillRect(context, boundsOffset);
    
    CGContextRestoreGState(context);
}

@end
