//
//  Trip.h
//  Unitrans
//
//  Created by Kip Nicol on 10/27/09.
//  Copyright 2009  All rights reserved.
//

#import <CoreData/CoreData.h>

@class Calendar;
@class Route;
@class Shape;
@class StopTime;

@interface Trip :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * direction;
@property (nonatomic, retain) NSString * headsign;
@property (nonatomic, retain) NSNumber * block;
@property (nonatomic, retain) Route * route;
@property (nonatomic, retain) NSSet* shapes;
@property (nonatomic, retain) NSSet* stopTimes;
@property (nonatomic, retain) Calendar * calendar;
@property (nonatomic, readonly) NSSet *stops;

- (BOOL)hasServiceOnDate:(NSDate *)date;

@end


@interface Trip (CoreDataGeneratedAccessors)
- (void)addShapesObject:(Shape *)value;
- (void)removeShapesObject:(Shape *)value;
- (void)addShapes:(NSSet *)value;
- (void)removeShapes:(NSSet *)value;

- (void)addStopTimesObject:(StopTime *)value;
- (void)removeStopTimesObject:(StopTime *)value;
- (void)addStopTimes:(NSSet *)value;
- (void)removeStopTimes:(NSSet *)value;

@end

