//
//  Stop.h
//  Unitrans
//
//  Created by Kip Nicol on 10/27/09.
//  Copyright 2009  All rights reserved.
//

#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

typedef enum _StopHeadingType {
    kStopHeadingTypeNorthBound,
    kStopHeadingTypeSouthBound,
    kStopHeadingTypeWestBound,
    kStopHeadingTypeEastBound
} StopHeadingType;

@class StopTime;
@class Route;

@interface Stop :  NSManagedObject <MKAnnotation>
{
}

@property (nonatomic, retain) NSNumber * code;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * heading;
@property (nonatomic, retain) NSString * stopDescription;
@property (nonatomic, retain) NSSet* stopTimes;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (NSArray *)allStopTimesWithRoute:(Route *)route onDate:(NSDate *)date;
- (NSString *)headingString;

@end


@interface Stop (CoreDataGeneratedAccessors)
- (void)addStopTimesObject:(StopTime *)value;
- (void)removeStopTimesObject:(StopTime *)value;
- (void)addStopTimes:(NSSet *)value;
- (void)removeStopTimes:(NSSet *)value;

@end

