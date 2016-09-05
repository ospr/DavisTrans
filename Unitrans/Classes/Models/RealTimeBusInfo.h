//
//  RealTimeBusInfo.h
//  DavisTrans
//
//  Created by Ken Zheng on 11/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface RealTimeBusInfo : NSObject <MKAnnotation> {
	NSString *vehicleID;
	NSString *routeTag;
	NSString *dirTag;
	NSInteger secsSinceReport;
	NSInteger heading;
	BOOL predictable;
}

@property (nonatomic, retain) NSString *vehicleID;
@property (nonatomic, retain) NSString *routeTag;
@property (nonatomic, retain) NSString *dirTag;
@property (nonatomic, assign) NSInteger secsSinceReport;
@property (nonatomic, assign) NSInteger heading;
@property (nonatomic, assign) BOOL predictable;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

- (id) initWithVehicleID:(NSString *)theVehicleID 
			withRouteTag:(NSString *)theRouteTag 
			  withDirTag:(NSString *)theDirTag 
				 withLat:(CLLocationDegrees)theLat withLon:(CLLocationDegrees)theLon 
	 withSecsSinceReport:(NSInteger)theSecsSinceReport 
			 withHeading:(NSInteger)theHeading 
		 withPredictable:(BOOL)thePredictable;

- (void)updateWithBusInfo:(RealTimeBusInfo *)bus;
- (void) printInfo;

@end
