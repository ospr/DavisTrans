//
//  RealTimeBusInfo.m
//  Unitrans
//
//  Created by Ken Zheng on 11/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RealTimeBusInfo.h"


@implementation RealTimeBusInfo

@synthesize vehicleID;
@synthesize routeTag;
@synthesize dirTag;
@synthesize lat;
@synthesize lon;
@synthesize secsSinceReport;
@synthesize heading;
@synthesize predictable;
@dynamic coordinate;

- (id) init
{
	if(self = [super init])
	{
		[self setVehicleID:@"NIL"];
		[self setRouteTag:@"NIL"];
		[self setDirTag:@"NIL"];
		[self setLat:0];
		[self setLon:0];
		[self setSecsSinceReport:-1];
		[self setHeading:0];
		[self setPredictable:NO];
	}
	return self;
}

- (id) initWithVehicleID:(NSString *)theVehicleID
			withRouteTag:(NSString *)theRouteTag
			  withDirTag:(NSString *)theDirTag
				 withLat:(float)theLat
				 withLon:(float)theLon
	 withSecsSinceReport:(NSInteger)theSecsSinceReport
			 withHeading:(NSInteger)theHeading
		 withPredictable:(BOOL)thePredictable
{
	if(self = [super init])
	{
		[self setVehicleID:theVehicleID];
		[self setRouteTag:theRouteTag];
		[self setDirTag:theDirTag];
		[self setLat:theLat];
		[self setLon:theLon];
		[self setSecsSinceReport:theSecsSinceReport];
		[self setHeading:theHeading];
		[self setPredictable:thePredictable];
	}
	return self;
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = lat;
    coordinate.longitude = lon;
    return coordinate;
}

- (void) printInfo
{
	NSLog(@"id: %@, routeTag: %@, dirTag: %@, lat: %f, lon: %f, secsSinceReport: %d, heading: %d, predictable: %d.", vehicleID, routeTag, dirTag, lat, lon, secsSinceReport, heading, predictable);
}

@end
