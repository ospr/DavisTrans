// 
//  Agency.m
//  Unitrans
//
//  Created by Kip Nicol on 10/27/09.
//  Copyright 2009  All rights reserved.
//

#import "Agency.h"

#import "Route.h"
#import "Calendar.h"

@implementation Agency 

@dynamic name;
@dynamic phone;
@dynamic url;
@dynamic routes;

- (BOOL)transitDataUpToDate
{
    // Pick a random calendar since all of them have the same end/start dates
    // And determine if the current date falls within the range or not
    Calendar *calendar = (Calendar *)[[[[[self routes] anyObject] trips] anyObject] calendar];
    
    return [calendar validServiceOnDate:[NSDate date]];
}

@end
