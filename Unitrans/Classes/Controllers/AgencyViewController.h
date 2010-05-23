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

typedef enum _AgencyViewSectionIndex {
    SectionIndexFavorites = 0,
    SectionIndexRoutes = 1
} AgencyViewSectionIndex;

@class Agency;
@class Route;
@class Stop;

@interface AgencyViewController : TableViewController <AboutViewControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
    Agency *agency;
	NSArray *routes;
    
    NSArray *favorites;
    
    BOOL outOfDate;
    
    UIBarButtonItem *serviceButtonItem;
}

@property (nonatomic, retain) Agency *agency;
@property (nonatomic, retain) NSArray *routes;
@property (nonatomic, retain) NSArray *favorites;

- (void)serviceChanged;
- (BOOL)favoritesSectionVisible;
- (void)showWelcomeMessage;

@end
