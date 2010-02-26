//
//  AgencyViewController.h
//  Unitrans
//
//  Created by Ken Zheng on 11/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TableViewController.h"
#import "AboutViewController.h"

@class Agency;

@interface AgencyViewController : TableViewController <AboutViewControllerDelegate> {
    Agency *agency;
	NSArray *routes;
}

@property (nonatomic, retain) Agency *agency;
@property (nonatomic, retain) NSArray *routes;

@end
