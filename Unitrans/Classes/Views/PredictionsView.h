//
//  PredictionsView.h
//  Unitrans
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
    PredictionOperation *predictionOperation;
    NSTimer *predictionTimer;
    
    BOOL loading;
    BOOL runningContinuousPredictionUpdates;
    
    Route *route;
    Stop *stop;
    
    UIActivityIndicatorView *loadingIndicatorView;
    
    CGFloat shadowOffset;
}

@property (nonatomic, retain) NSArray *predictions;
@property (nonatomic, retain) PredictionOperation *predictionOperation;
@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) Stop *stop;
@property (nonatomic, assign) BOOL isRunningContinuousPredictionUpdates;

- (void)beginContinuousPredictionsUpdates;
- (void)endContinuousPredictionsUpdates;

- (void)updatePredictionText;
- (void)updatePredictions;


@end
