//
//  PredictionOperation.h
//  Unitrans
//
//  Created by Kip on 12/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConcurrentOperation.h"

@class Route;
@class Stop;

@protocol PredictionOperationDelegate;

@interface PredictionOperation : ConcurrentOperation {
	NSString *stopTag;
	NSString *routeName;
	NSString *stopId;
	NSMutableArray *predictionTimes;
    
    NSError *parseError;
    BOOL parseAborted;
    
    id<PredictionOperationDelegate> delegate;
}

@property (nonatomic, retain) NSString *stopTag;
@property (nonatomic, retain) NSString *routeName;
@property (nonatomic, retain) NSString *stopId;
@property (nonatomic, retain) NSMutableArray *predictionTimes;
@property (nonatomic, retain) NSError *parseError;
@property (nonatomic, retain) id<PredictionOperationDelegate> delegate;

- (id) initWithRouteName:(NSString *)newRouteName stopTag:(NSString *)newStopTag;

- (void) retrievePredictions;
- (void) retrieveStopIDFromRouteConfig;
- (void) parseXMLAtURLString:(NSString *)theURLString;

@end

// Delegate methods
@protocol PredictionOperationDelegate <NSObject>
@required
- (void)predictionOperation:(PredictionOperation *)predictionOperation didFinishWithPredictions:(NSArray *)predictions;
- (void)predictionOperation:(PredictionOperation *)predictionOperation didFailWithError:(NSError *)error;
@end