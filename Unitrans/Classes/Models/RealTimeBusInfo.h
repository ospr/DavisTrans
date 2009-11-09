//
//  RealTimeBusInfo.h
//  Unitrans
//
//  Created by Ken Zheng on 11/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RealTimeBusInfo : NSObject {
	NSString *vehicleID;
	NSString *routeTag;
	NSString *dirTag;
	float lat;
	float lon;
	NSInteger secsSinceReport;
	NSInteger heading;
	BOOL predictable;
}

@property (nonatomic, retain) NSString *vehicleID;
@property (nonatomic, retain) NSString *routeTag;
@property (nonatomic, retain) NSString *dirTag;
@property (nonatomic, assign) float lat;
@property (nonatomic, assign) float lon;
@property (nonatomic, assign) NSInteger secsSinceReport;
@property (nonatomic, assign) NSInteger heading;
@property (nonatomic, assign) BOOL predictable;

- (id) initWithVehicleID:(NSString *)theVehicleID 
			withRouteTag:(NSString *)theRouteTag 
			  withDirTag:(NSString *)theDirTag 
				 withLat:(float)theLat withLon:(float)theLon 
	 withSecsSinceReport:(NSInteger)theSecsSinceReport 
			 withHeading:(NSInteger)theHeading 
		 withPredictable:(BOOL)thePredictable;

- (void) printInfo;

@end
