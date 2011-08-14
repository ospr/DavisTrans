//
//  Service.m
//  Unitrans
//
//  Created by Kip on 5/20/10.
//  Copyright 2010 All rights reserved.
//

#import "Service.h"
#import "NSDate_Extensions.h"

@implementation Service

@synthesize shortName;
@synthesize longName;
@synthesize resourceName;
@synthesize resourceKind;

- (BOOL)validServiceOnDate:(NSDate *)date
{
    NSDateComponents *endDateComponents = [[NSDateComponents alloc] init];
    NSDateComponents *startDateComponents = [[NSDateComponents alloc] init];
    
    if ([shortName isEqualToString:@"Summer1"])
    {
        // Set start date
        [startDateComponents setYear:2010];
        [startDateComponents setMonth:6];
        [startDateComponents setDay:11];
        // Set end date
        [endDateComponents setYear:2010];
        [endDateComponents setMonth:8];
        [endDateComponents setDay:1];
    }
    else if ([shortName isEqualToString:@"Summer2"])
    {
        // Set start date
        [startDateComponents setYear:2010];
        [startDateComponents setMonth:8];
        [startDateComponents setDay:2];
        // Set end date
        [endDateComponents setYear:2010];
        [endDateComponents setMonth:9];
        [endDateComponents setDay:22];
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *endDate = [gregorian dateFromComponents:endDateComponents];
    NSDate *startDate = [gregorian dateFromComponents:startDateComponents];
    
    [startDateComponents release];
    [endDateComponents release];
    [gregorian release];
    
    date = [date beginningOfDay];
    
    if ([startDate earlierDate:date] == date || [endDate laterDate:date] == date) {
        return NO;
    }
    
    return YES;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]] && 
        [[object shortName] isEqualToString:shortName] &&
        [[object resourceName] isEqualToString:resourceName])
        return YES;
        
    return NO;
}

- (NSUInteger)hash
{
    return [shortName hash];
}

@end
