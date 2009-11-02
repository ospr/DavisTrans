//
//  StopTime.h
//  Unitrans
//
//  Created by Kip Nicol on 10/27/09.
//  Copyright 2009  All rights reserved.
//

#import <CoreData/CoreData.h>

@class Stop;
@class Trip;

@interface StopTime :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * sequence;
@property (nonatomic, retain) NSNumber * arrivalTime;
@property (nonatomic, retain) NSNumber * departureTime;
@property (nonatomic, retain) NSNumber * pickupType;
@property (nonatomic, retain) NSNumber * dropOffType;
@property (nonatomic, retain) Trip * trip;
@property (nonatomic, retain) Stop * stop;

- (void)setArrivalTimeFromTimeString:(NSString *)timeString;
- (void)setDepartureTimeFromTimeString:(NSString *)timeString;

- (NSString *)arrivalTimeString;
- (NSString *)departureTimeString;

@end



