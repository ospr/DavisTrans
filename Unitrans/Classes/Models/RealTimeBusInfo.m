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
@synthesize secsSinceReport;
@synthesize heading;
@synthesize predictable;
@synthesize coordinate;

- (id) init
{
	if(self = [super init])
	{
		[self setVehicleID:@"NIL"];
		[self setRouteTag:@"NIL"];
		[self setDirTag:@"NIL"];
        [self setCoordinate:CLLocationCoordinate2DMake(0.0, 0.0)];
		[self setSecsSinceReport:-1];
		[self setHeading:0];
		[self setPredictable:NO];
	}
	return self;
}

- (id) initWithVehicleID:(NSString *)theVehicleID
			withRouteTag:(NSString *)theRouteTag
			  withDirTag:(NSString *)theDirTag
				 withLat:(CLLocationDegrees)theLat
				 withLon:(CLLocationDegrees)theLon
	 withSecsSinceReport:(NSInteger)theSecsSinceReport
			 withHeading:(NSInteger)theHeading
		 withPredictable:(BOOL)thePredictable
{
	if(self = [super init])
	{
		[self setVehicleID:theVehicleID];
		[self setRouteTag:theRouteTag];
		[self setDirTag:theDirTag];
        [self setCoordinate:CLLocationCoordinate2DMake(theLat, theLon)];
		[self setSecsSinceReport:theSecsSinceReport];
		[self setHeading:theHeading];
		[self setPredictable:thePredictable];
	}
	return self;
}

- (void)updateWithBusInfo:(RealTimeBusInfo *)bus
{
    [self setCoordinate:[bus coordinate]];
    [self setSecsSinceReport:[bus secsSinceReport]];
    [self setHeading:[bus heading]];
    [self setPredictable:[bus predictable]];
}

- (void) printInfo
{
	NSLog(@"id: %@, routeTag: %@, dirTag: %@, lat: %f, lon: %f, secsSinceReport: %d, heading: %d, predictable: %d.", vehicleID, routeTag, dirTag, [self coordinate].latitude, [self coordinate].longitude, secsSinceReport, heading, predictable);
}

@end
