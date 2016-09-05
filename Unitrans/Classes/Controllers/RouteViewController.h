//
//  RouteViewController.h
//  DavisTrans
//
//  Created by Ken Zheng on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewController.h"

@class Route;

@interface RouteViewController : TableViewController <UISearchDisplayDelegate, UISearchBarDelegate> {
    Route *route;
    
	NSArray *stops;
    NSArray *filteredStops;
        
    UISearchDisplayController *searchDisplayController;
    UISearchBar *searchBar;
    
    BOOL hasAppeared;
}

@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) NSArray *stops;
@property (nonatomic, retain) NSArray *filteredStops;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) UISearchDisplayController *searchDisplayController;

@end
