//
//  PredictionOperation.h
//  DavisTrans
//
//  Created by Kip on 12/6/09.
//  Copyright 2009 Kip Nicol & Ken Zheng
//

#import <Foundation/Foundation.h>
#import "ConcurrentOperation.h"

@class Route;
@class Stop;

@protocol PredictionOperationDelegate;

@interface PredictionOperation : ConcurrentOperation <NSXMLParserDelegate> {
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
@property (nonatomic, assign) id<PredictionOperationDelegate> delegate;

- (id) initWithRouteName:(NSString *)newRouteName stopTag:(NSString *)newStopTag;

- (NSString *)predictionText;

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