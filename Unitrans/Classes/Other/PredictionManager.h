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

@interface PredictionManager : NSObject {
	NSString *stopTag;
	NSString *routeShortname;
	NSString *stopId;
	NSDateFormatter *predictionTimeFormatter;
	NSMutableArray *predictionTimes;
}

@property (nonatomic, retain) NSString *stopTag;
@property (nonatomic, retain) NSString *routeShortname;
@property (nonatomic, retain) NSString *stopId;
@property (nonatomic, retain) NSDateFormatter *predictionTimeFormatter;
@property (nonatomic, retain) NSMutableArray *predictionTimes;

+ (PredictionManager *)sharedPredictionManager;

- (NSArray *) retrievePredictionInMinutesForRoute:(Route *)theRoute atStop:(Stop *)theStop;
- (NSArray *) retrievePredictionAsTimeForRoute:(Route *)theRoute atStop:(Stop *)theStop;
- (NSArray *) retrievePredictionInMinutesAndAsTimeForRoute:(Route *)theRoute atStop:(Stop *)theStop;
- (NSArray *) convertMinutesToTime;
- (void) initializeRetrieve:(Route *)theRoute atStop:(Stop *)theStop;
- (void) retrievePrediction;
- (void) retrieveStopIDFromRouteConfig;
- (void) parseXMLAtURLString:(NSString *)theURLString;

@end
