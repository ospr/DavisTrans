//
//  AboutViewController.h
//  DavisTrans
//
//  Created by Kip Nicol on 11/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AboutViewControllerDelegate;

@class Agency;

@interface AboutViewController : UITableViewController {
    Agency *agency;
    NSArray *aboutItems;
    
    id<AboutViewControllerDelegate> delegate;
}  

@property (nonatomic, retain) Agency *agency;
@property (nonatomic, retain) NSArray *aboutItems;
@property (nonatomic, assign) id<AboutViewControllerDelegate> delegate;

@end

// Delegate methods
@protocol AboutViewControllerDelegate <NSObject>
@required
- (void)aboutViewControllerDidFinish:(AboutViewController *)aboutViewController;
@end
