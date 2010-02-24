// 
//  Trip.m
//  Unitrans
//
//  Created by Kip Nicol on 10/27/09.
//  Copyright 2009  All rights reserved.
//

#import "Trip.h"

#import "Calendar.h"
#import "Route.h"
#import "Shape.h"
#import "StopTime.h"
#import "Stop.h"

@implementation Trip 

@dynamic direction;
@dynamic headsign;
@dynamic block;
@dynamic route;
@dynamic shapes;
@dynamic stopTimes;
@dynamic calendar;
@dynamic stops;

- (BOOL)hasServiceOnDate:(NSDate *)date
{
    return [[self calendar] hasServiceOnDate:date];
}

- (NSSet *)stops
{
    return [[self stopTimes] valueForKey:@"stop"];
}

- (NSNumber *)sequenceForStop:(Stop *)stop
{
    for (StopTime *stopTime in [self stopTimes])
    {
        if ([[stopTime stop] isEqual:stop])
            return [stopTime sequence];
    }
    
    return [NSNumber numberWithInteger:-1];
}

@end
