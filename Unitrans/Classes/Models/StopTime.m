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

+ (NSString *)timeStringFromSeconds:(NSUInteger)seconds
{
    static NSDateFormatter *dateFormatter = nil;
    static NSDate *referenceDate = nil;

    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm a"];
    }
    if (!referenceDate)
        referenceDate = [[dateFormatter dateFromString:@"12:00 am"] retain];
        
    NSDate *dummyDate = [[[NSDate alloc] initWithTimeInterval:seconds sinceDate:referenceDate] autorelease];
    
    return [dateFormatter stringFromDate:dummyDate];
}

+ (NSUInteger)secondsFromTimeString:(NSString *)timeString
{
    static NSDateFormatter *dateFormatter = nil;
    static NSDate *referenceDate = nil;

    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
    }
    if (!referenceDate)
        referenceDate = [[dateFormatter dateFromString:@"00:00:00"] retain];

    NSDate *dummyDate = [dateFormatter dateFromString:timeString];
    
    return [dummyDate timeIntervalSinceDate:referenceDate];
}

- (void)setArrivalTimeFromTimeString:(NSString *)timeString
{
    [self setArrivalTime:[NSNumber numberWithUnsignedInteger:[StopTime secondsFromTimeString:timeString]]];
}

- (void)setDepartureTimeFromTimeString:(NSString *)timeString
{
    [self setDepartureTime:[NSNumber numberWithUnsignedInteger:[StopTime secondsFromTimeString:timeString]]];
}

- (NSString *)arrivalTimeString
{
    return [StopTime timeStringFromSeconds:[[self arrivalTime] unsignedIntegerValue]];
}

- (NSString *)departureTimeString
{
    return [StopTime timeStringFromSeconds:[[self departureTime] unsignedIntegerValue]];
}

@end
