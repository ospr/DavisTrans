//
//  Pattern.h
//  DavisTrans
//
//  Created by Kip on 12/21/09.
//  Copyright 2009 Kip Nicol & Ken Zheng
//

#import <CoreData/CoreData.h>

@class Trip;
@class Route;

@interface RoutePattern :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* trips;
@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) NSNumber *sequenceNumber;
@property (nonatomic, readonly) NSSet *stops;
@property (nonatomic, readonly) NSSet *shapes;

@end

@interface RoutePattern (CoreDataGeneratedAccessors)
- (void)addTripsObject:(Trip *)value;
- (void)removeTripsObject:(Trip *)value;
- (void)addTrips:(NSSet *)value;
- (void)removeTrips:(NSSet *)value;

@end
