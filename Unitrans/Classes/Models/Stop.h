//
//  Stop.h
//  Unitrans
//
//  Created by Kip Nicol on 10/27/09.
//  Copyright 2009  All rights reserved.
//

#import <CoreData/CoreData.h>

#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
    #import <MapKit/MapKit.h>
    #define USING_MAP_KIT 1
#else
    #define USING_MAP_KIT 0
#endif

typedef enum _StopHeadingType {
    kStopHeadingTypeNorthBound,
    kStopHeadingTypeSouthBound,
    kStopHeadingTypeWestBound,
    kStopHeadingTypeEastBound
} StopHeadingType;

@class StopTime;
@class Route;

#if USING_MAP_KIT
    @interface Stop :  NSManagedObject <MKAnnotation>
#else
    @interface Stop :  NSManagedObject
#endif
{
    NSNumber *sequence;
}

@property (nonatomic, retain) NSNumber * code;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * heading;
@property (nonatomic, retain) NSString * stopDescription;
@property (nonatomic, retain) NSSet* stopTimes;
@property (nonatomic, retain) NSNumber *sequence;
#if USING_MAP_KIT
    @property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
#endif

- (NSArray *)allStopTimesWithRoute:(Route *)route onDate:(NSDate *)date;
- (NSNumber *)stopID;
- (NSString *)headingString;

@end


@interface Stop (CoreDataGeneratedAccessors)
- (void)addStopTimesObject:(StopTime *)value;
- (void)removeStopTimesObject:(StopTime *)value;
- (void)addStopTimes:(NSSet *)value;
- (void)removeStopTimes:(NSSet *)value;

@end

