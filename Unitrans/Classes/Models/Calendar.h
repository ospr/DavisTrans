//
//  Calendar.h
//  DavisTrans
//
//  Created by Kip Nicol on 10/27/09.
//  Copyright 2009  All rights reserved.
//

#import <CoreData/CoreData.h>

@class CalendarDate;
@class Trip;

@interface Calendar :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * tuesday;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * monday;
@property (nonatomic, retain) NSNumber * friday;
@property (nonatomic, retain) NSNumber * saturday;
@property (nonatomic, retain) NSNumber * thursday;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSNumber * wednesday;
@property (nonatomic, retain) NSNumber * sunday;
@property (nonatomic, retain) NSSet* trips;
@property (nonatomic, retain) NSSet* calendarDates;

- (BOOL)hasServiceOnDate:(NSDate *)date;
- (BOOL)validServiceOnDate:(NSDate *)date;

@end


@interface Calendar (CoreDataGeneratedAccessors)
- (void)addTripsObject:(Trip *)value;
- (void)removeTripsObject:(Trip *)value;
- (void)addTrips:(NSSet *)value;
- (void)removeTrips:(NSSet *)value;

- (void)addCalendarDatesObject:(CalendarDate *)value;
- (void)removeCalendarDatesObject:(CalendarDate *)value;
- (void)addCalendarDates:(NSSet *)value;
- (void)removeCalendarDates:(NSSet *)value;

@end

@interface Calendar (CoreDataGeneratedPrimitiveAccessors)

- (NSDate *)primitiveEndDate;

@end

