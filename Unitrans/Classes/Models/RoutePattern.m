// 
//  Pattern.m
//  DavisTrans
//
//  Created by Kip on 12/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RoutePattern.h"

#import "Trip.h"
#import "Route.h"

@implementation RoutePattern 

@dynamic name;
@dynamic trips;
@dynamic route;
@dynamic sequenceNumber;
@dynamic stops;
@dynamic shapes;

- (Trip *)trip
{
    return [[self trips] anyObject];
}

- (NSSet *)stops
{
    return [[self trip] stops];
}

- (NSSet *)shapes
{
    return [[self trip] shapes];
}

@end
