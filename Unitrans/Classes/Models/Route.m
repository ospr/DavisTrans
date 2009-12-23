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
@dynamic primaryTrip;
@dynamic routePatterns;
@dynamic orderedRoutePatterns;

- (void)dealloc
{
    [orderedRoutePatterns release];
    
    [super dealloc];
}

// TODO: this does not work since not all trips have the same stops
- (NSSet *)allStops
{    
    // Return all stops in primary trip
    return [[[self primaryTrip] stopTimes] valueForKey:@"stop"];
}

- (NSArray *)orderedRoutePatterns
{
    if (!orderedRoutePatterns) {
        // Sort routePatterns by sequenceNumber
        NSSortDescriptor *routePatternDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"sequenceNumber" ascending:YES] autorelease];
        [self setOrderedRoutePatterns:[[[self routePatterns] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:routePatternDescriptor]]];
    }
    
    return orderedRoutePatterns;
}

- (void)setOrderedRoutePatterns:(NSArray *)newOrderedRoutePatterns
{
    [newOrderedRoutePatterns retain];
    [orderedRoutePatterns release];
    orderedRoutePatterns = newOrderedRoutePatterns;
}

@end
