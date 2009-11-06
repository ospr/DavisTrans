//
//  RouteViewController.h
//  Unitrans
//
//  Created by Ken Zheng on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RouteViewController : UITableViewController {
	NSArray *stops;
}

@property (nonatomic, retain) NSArray *stops;

@end
