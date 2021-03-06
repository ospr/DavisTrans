//
//  AppDelegate.h
//  DavisTrans
//
//  Created by Kip Nicol on 10/21/09.
//  Copyright 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgencyViewController.h"

void criticalLoadingErrorAlert(void);

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UINavigationController *navigationController;
	
	IBOutlet AgencyViewController *agencyViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
