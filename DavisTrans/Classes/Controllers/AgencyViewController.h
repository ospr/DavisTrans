//
//  AgencyViewController.h
//  DavisTrans
//
//  Created by Ken Zheng on 11/1/09.
//  Copyright 2009 Kip Nicol & Ken Zheng
//

#import <UIKit/UIKit.h>

#import "TableViewController.h"
#import "AboutViewController.h"
#import "PredictionOperation.h"

typedef enum _AgencyViewSectionIndex {
    SectionIndexFavorites = 0,
    SectionIndexRoutes = 1
} AgencyViewSectionIndex;

@class Agency;
@class Route;
@class Stop;

@interface AgencyViewController : TableViewController <AboutViewControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate, PredictionOperationDelegate> {
    Agency *agency;
	NSArray *routes;
    
    NSArray *favorites;
	NSMutableArray *favoritePredictions;
	NSOperationQueue *operationQueue;
	NSTimer *predictionTimer;
    
    BOOL showOutOfDateNotification;
    BOOL runningContinuousPredictionUpdates;
	
    UIBarButtonItem *serviceButtonItem;
}

@property (nonatomic, retain) Agency *agency;
@property (nonatomic, retain) NSArray *routes;
@property (nonatomic, retain) NSArray *favorites;
@property (nonatomic, retain) NSMutableArray *favoritePredictions;
@property (nonatomic, assign) BOOL isRunningContinuousPredictionUpdates;

- (void)serviceChanged;
- (BOOL)favoritesSectionVisible;
- (void)showWelcomeMessage;
- (void)updatePredictions;

- (void)beginContinuousPredictionUpdates;
- (void)endContinuousPredictionUpdates;

@end
