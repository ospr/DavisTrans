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
	NSInteger predictionInMinutes;
	NSDateFormatter *predictionTimeFormatter;
}

@property (nonatomic, retain) NSString *stopTag;
@property (nonatomic, retain) NSString *routeShortname;
@property (nonatomic, retain) NSString *stopId;
@property (nonatomic, assign) NSInteger predictionInMinutes;
@property (nonatomic, retain) NSDateFormatter *predictionTimeFormatter;

+ (PredictionManager *)sharedPredictionManager;

- (NSString *) retrievePredictionInMinutesForRoute:(Route *)theRoute atStop:(Stop *)theStop;
- (NSString *) retrievePredictionAsTimeForRoute:(Route *)theRoute atStop:(Stop *)theStop;
- (void) retrievePrediction;
- (void) retrieveStopIDFromRouteConfig;
- (void) parseXMLAtURLString:(NSString *)theURLString;

@end
