//
//  TableViewController.h
//  Unitrans
//
//  Created by Kip Nicol on 11/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *tableView;
}

@property (nonatomic, retain) UITableView *tableView;

@end
