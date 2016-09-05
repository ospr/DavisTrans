//
//  PredictionsView.h
//  DavisTrans
//
//  Created by Kip on 2/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PredictionOperation.h"

@class Route;
@class Stop;

@interface PredictionsView : UIButton <PredictionOperationDelegate> {
    NSArray *predictions;
    NSOperationQueue *operationQueue;
    NSTimer *predictionTimer;
    
    BOOL loading;
    BOOL runningContinuousPredictionUpdates;
    
    Route *route;
    Stop *stop;
    NSError *predictionLoadError;
    
    UIActivityIndicatorView *loadingIndicatorView;
    
    CGFloat shadowOffset;
}

@property (nonatomic, retain) NSArray *predictions;
@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, retain) NSError *predictionLoadError;
@property (nonatomic, assign) BOOL isRunningContinuousPredictionUpdates;

- (void)beginContinuousPredictionsUpdates;
- (void)endContinuousPredictionsUpdates;

- (void)updatePredictionWithText:(NSString *)text;
- (void)updatePredictions;

@end
