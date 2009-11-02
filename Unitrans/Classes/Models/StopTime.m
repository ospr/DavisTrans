// 
//  StopTime.m
//  Unitrans
//
//  Created by Kip Nicol on 10/27/09.
//  Copyright 2009  All rights reserved.
//

#import "StopTime.h"

#import "Stop.h"
#import "Trip.h"

@implementation StopTime 

@dynamic sequence;
@dynamic arrivalTime;
@dynamic departureTime;
@dynamic pickupType;
@dynamic dropOffType;
@dynamic trip;
@dynamic stop;

- (NSString *)timeStringFromSeconds:(NSUInteger)seconds
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"hh:mm a"];
    
    NSDate *dummyDate = [NSDate dateWithTimeIntervalSinceReferenceDate:seconds];
    
    return [dateFormatter stringFromDate:dummyDate];
}

- (NSUInteger)secondsFromTimeString:(NSString *)timeString
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    
    NSDate *referenceDate = [dateFormatter dateFromString:@"00:00:00"];
    NSDate *dummyDate = [dateFormatter dateFromString:timeString];
    
    return [dummyDate timeIntervalSinceDate:referenceDate];
}

- (void)setArrivalTimeFromTimeString:(NSString *)timeString
{
    [self setArrivalTime:[NSNumber numberWithUnsignedInteger:[self secondsFromTimeString:timeString]]];
}

- (void)setDepartureTimeFromTimeString:(NSString *)timeString
{
    [self setDepartureTime:[NSNumber numberWithUnsignedInteger:[self secondsFromTimeString:timeString]]];
}

- (NSString *)arrivalTimeString
{
    return [self timeStringFromSeconds:[[self arrivalTime] unsignedIntegerValue]];
}

- (NSString *)departureTimeString
{
    return [self timeStringFromSeconds:[[self departureTime] unsignedIntegerValue]];
}

@end
