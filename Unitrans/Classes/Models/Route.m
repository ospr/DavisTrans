// 
//  Route.m
//  Unitrans
//
//  Created by Kip Nicol on 10/27/09.
//  Copyright 2009  All rights reserved.
//

#import "Route.h"

#import "Agency.h"
#import "Trip.h"
#import "StopTime.h"

@implementation Route 

@dynamic routeDescription;
@dynamic type;
@dynamic textColor;
@dynamic color;
@dynamic shortName;
@dynamic longName;
@dynamic trips;
@dynamic agency;

// TODO: this does not work since not all trips have the same stops
- (NSArray *)allStops
{    
    // Retrieve any trip from the route
    Trip *trip = [[self trips] anyObject];
    
    // Retrieve all stopTimes for the trip
    NSSet *stopTimes = [trip stopTimes];
    
    // Add all stops to stop array
    NSMutableArray *stops = [NSMutableArray array];
    for (StopTime *stopTime in stopTimes)
        [stops addObject:[stopTime stop]];
    
    // Return all corresponding stops
    return [NSArray arrayWithArray:stops];
}

@end
