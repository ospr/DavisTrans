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
    return [[self calendar] hasServiceDate:date];
}

- (NSSet *)stops
{
    return [[self stopTimes] valueForKey:@"stop"];
}

@end
