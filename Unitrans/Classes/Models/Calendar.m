// 
//  Calendar.m
//  Unitrans
//
//  Created by Kip Nicol on 10/27/09.
//  Copyright 2009  All rights reserved.
//

#import "Calendar.h"

#import "CalendarDate.h"
#import "Trip.h"

#import "NSDate_Extensions.h"

@implementation Calendar 

@dynamic tuesday;
@dynamic endDate;
@dynamic monday;
@dynamic friday;
@dynamic saturday;
@dynamic thursday;
@dynamic startDate;
@dynamic wednesday;
@dynamic sunday;
@dynamic trips;
@dynamic calendarDates;

- (BOOL)hasServiceOnDate:(NSDate *)date
{
    // Iterate through calendarDates and check whether the
    // given date has an exception
    for (CalendarDate *calendarDate in [self calendarDates]) {
        if ([[calendarDate date] isEqualToDate:date]) {
            switch ([[calendarDate exceptionType] integerValue]) {
                case 1: return YES; // Service has been added
                case 2: return NO; // Service has been dropped
                default:
                    NSLog(@"%@ - %@ - Error: unknown calendarDate exception type %d", self, NSStringFromSelector(_cmd), [[calendarDate exceptionType] integerValue]);
                    return NO;
            }
        }
    }
    
    // If there was no exception we check to see if 
    // there is service on the date's weekday
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
    NSInteger weekday = [components weekday];
    
    switch (weekday) {
        case 1: return [[self sunday] boolValue];
        case 2: return [[self monday] boolValue];
        case 3: return [[self tuesday] boolValue];
        case 4: return [[self wednesday] boolValue];
        case 5: return [[self thursday] boolValue];
        case 6: return [[self friday] boolValue];
        case 7: return [[self saturday] boolValue];
            
        default:
            NSLog(@"%@ - %@ - Error: unknown weekday component %d", self, NSStringFromSelector(_cmd), weekday);
    }
    
    return NO;
}

- (BOOL)validServiceOnDate:(NSDate *)date
{    
    // Return whether the current date falls withing start and end date range
    if ([[self startDate] earlierDate:date] == date || [[self endDate] laterDate:date] == date) {
        return NO;
    }
    
    return YES;
}

- (NSDate *)endDate 
{
    NSDate * dateValue;
    
    [self willAccessValueForKey:@"endDate"];
    dateValue = [[self primitiveEndDate] endOfDay];
    [self didAccessValueForKey:@"endDate"];
    
    return dateValue;
}
@end
