//
//  PredictionManager.h
//  Unitrans
//
//  Created by Ken Zheng on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Route.h"
#import "Stop.h"

// Prediction Manager is a single-shot class. It will only retrieve info one time per object. 
// Subsequent calls to retrieval method will return the last retrieved info.
// Release current object and allocate a new one to retrieve info again.

@interface PredictionManager : NSObject {
	NSString *stopTag;
	NSString *routeShortname;
	NSString *stopId;
	NSDateFormatter *predictionTimeFormatter;
	NSMutableArray *predictionTimes;
    NSError *parseError;
    BOOL parseAborted;
	
@private
	BOOL alreadyRetrievedPredictions;
}

@property (nonatomic, retain) NSString *stopTag;
@property (nonatomic, retain) NSString *routeShortname;
@property (nonatomic, retain) NSString *stopId;
@property (nonatomic, retain) NSDateFormatter *predictionTimeFormatter;
@property (nonatomic, retain) NSMutableArray *predictionTimes;
@property (nonatomic, retain) NSError *parseError;
@property (nonatomic, readonly) BOOL alreadyRetrievedPredictions;

- (NSArray *) retrievePredictionInMinutesForRoute:(Route *)theRoute atStop:(Stop *)theStop error:(NSError **)error;
- (NSArray *) convertMinutesToTime:(NSArray *)minutes;
- (void) retrievePrediction;
- (void) retrieveStopIDFromRouteConfig;
- (void) parseXMLAtURLString:(NSString *)theURLString;

@end
