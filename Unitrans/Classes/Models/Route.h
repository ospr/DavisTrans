//
//  Route.h
//  Unitrans
//
//  Created by Kip Nicol on 10/27/09.
//  Copyright 2009  All rights reserved.
//

#import <CoreData/CoreData.h>

@class Agency;
@class Trip;
@class RoutePattern;

@interface Route :  NSManagedObject  
{
    NSArray *orderedRoutePatterns;
}

@property (nonatomic, retain) NSString * routeDescription;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * textColor;
@property (nonatomic, retain) NSNumber * color;
@property (nonatomic, retain) NSString * shortName;
@property (nonatomic, retain) NSString * longName;
@property (nonatomic, retain) NSSet* trips;
@property (nonatomic, retain) Agency * agency;
@property (nonatomic, retain) Trip * primaryTrip;
@property (nonatomic, retain) NSSet* routePatterns;
@property (nonatomic, retain) NSArray *orderedRoutePatterns;

- (NSSet *)allStops;
- (NSArray *)orderedRoutePatterns;

@end

@interface Route (CoreDataGeneratedAccessors)
- (void)addTripsObject:(Trip *)value;
- (void)removeTripsObject:(Trip *)value;
- (void)addTrips:(NSSet *)value;
- (void)removeTrips:(NSSet *)value;

- (void)addRoutePatternsObject:(RoutePattern *)value;
- (void)removeRoutePatternsObject:(RoutePattern *)value;
- (void)addRoutePatterns:(NSSet *)value;
- (void)removeRoutePatterns:(NSSet *)value;

@end

