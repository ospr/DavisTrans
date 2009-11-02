// 
//  Stop.m
//  Unitrans
//
//  Created by Kip Nicol on 10/27/09.
//  Copyright 2009  All rights reserved.
//

#import "Stop.h"

#import "StopTime.h"
#import "Route.h"
#import "Trip.h"

@implementation Stop 

@dynamic code;
@dynamic name;
@dynamic longitude;
@dynamic latitude;
@dynamic stopDescription;
@dynamic stopTimes;

- (NSArray *)allStopTimesWithRoute:(Route *)route onDate:(NSDate *)date
{
    NSMutableArray *routeStopTimes = [NSMutableArray array];
    
    // Iterate through stopTimes and find times with given Route and date
    for (StopTime *stopTime in [self stopTimes])
    {
        if ([[[stopTime trip] route] isEqual:route] && [[stopTime trip] hasServiceOnDate:date])
            [routeStopTimes addObject:stopTime];
    }
    
    return [NSArray arrayWithArray:routeStopTimes];
}

@end
