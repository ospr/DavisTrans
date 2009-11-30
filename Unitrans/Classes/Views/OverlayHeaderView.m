//
//  DetailOverlayView.m
//  Unitrans
//
//  Created by Kip Nicol on 11/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DetailOverlayView.h"
#import "OverlayHeaderView.h"


@implementation OverlayHeaderView

@synthesize detailOverlayView;
@dynamic contentView;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    
    if (self) {        
        [self setBackgroundColor:[UIColor clearColor]];
        
        detailOverlayView = [[DetailOverlayView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 57)];
        //[detailOverlayView setBackgroundColor:[UIColor colorWithRed:(163/255.0) green:(50/255.0) blue:(52/255.0) alpha:1.0]];
        [self addSubview:detailOverlayView];
    }
    
    return self;
}

- (void)dealloc 
{
    [detailOverlayView release];
    [contentView release];
    
    [super dealloc];
}

- (void)layoutSubviews
{
    CGRect bounds = [self bounds];
    
    CGFloat detailViewHeight = 57.0;
    CGFloat shadowOffset = [detailOverlayView shadowOffset];
    [detailOverlayView setFrame:CGRectMake(0, 0, bounds.size.width, detailViewHeight)];
    
    [contentView setFrame:CGRectMake(0, detailViewHeight-shadowOffset, bounds.size.width, bounds.size.height-(detailViewHeight-shadowOffset))];
}

- (void)drawRect:(CGRect)rect 
{
    // Drawing code
}

- (void)setContentView:(UIView *)view
{
    [view retain];
    [contentView release];
    [contentView removeFromSuperview];
    contentView = view;
    
    [self insertSubview:contentView atIndex:0];
}


@end
