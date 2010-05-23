//
//  NSDate_Extensions.m
//  Unitrans
//
//  Created by Ken Zheng on 11/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSDate_Extensions.h"


@implementation NSDate(NSDate_Extensions)

+ (NSDate *)beginningOfToday
{
    return [[NSDate date] beginningOfDay];
}

+ (NSDate *)beginningOfTomorrow
{
    return [[[NSDate date] nextDay] beginningOfDay];
}

- (NSDate *)beginningOfDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
	
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *comp = [calendar components:unitFlags fromDate:self];
	
    return [calendar dateFromComponents:comp];
}

- (NSDate *)nextDay
{
    return [self addTimeInterval:24*60*60];
}

- (NSDate *)endOfDay
{
    return [[[self nextDay] beginningOfDay] addTimeInterval:-1];
}

@end
