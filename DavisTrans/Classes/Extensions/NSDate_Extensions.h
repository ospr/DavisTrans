//
//  NSDate_Extensions.h
//  DavisTrans
//
//  Created by Ken Zheng on 11/10/09.
//  Copyright 2009 Kip Nicol & Ken Zheng
//

#import <Foundation/Foundation.h>


@interface NSDate(NSDate_Extensions)

+ (NSDate *)beginningOfToday;
+ (NSDate *)beginningOfTomorrow;

- (NSDate *)beginningOfDay;
- (NSDate *)nextDay;
- (NSDate *)endOfDay;

@end
