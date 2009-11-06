//
//  AgencyViewController.h
//  Unitrans
//
//  Created by Ken Zheng on 11/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AgencyViewController : UITableViewController {
	NSArray *routes;
}

@property (nonatomic, retain) NSArray *routes;

@end
