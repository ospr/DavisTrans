//
//  AboutViewController.h
//  Unitrans
//
//  Created by Kip Nicol on 11/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Agency;

@interface AboutViewController : UITableViewController {
    Agency *agency;
    NSArray *aboutItems;
    
    NSMutableArray *sections;
}  

@property (nonatomic, retain) Agency *agency;

@end
