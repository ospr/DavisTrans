//
//  RouteViewController.h
//  Unitrans
//
//  Created by Ken Zheng on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewController.h"

@class Route;
@class OverlayHeaderView;

@interface RouteViewController : TableViewController {
    Route *route;
	NSArray *stops;
    
    OverlayHeaderView *overlayHeaderView;
}

@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) NSArray *stops;

@end
