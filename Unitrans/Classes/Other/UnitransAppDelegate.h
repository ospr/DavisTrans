//
//  UnitransAppDelegate.h
//  Unitrans
//
//  Created by Kip Nicol on 10/21/09.
//  Copyright Apple Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

void criticalLoadingErrorAlert();

@interface UnitransAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
