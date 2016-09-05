//
//  CalendarDate.h
//  DavisTrans
//
//  Created by Kip Nicol on 10/27/09.
//  Copyright 2009  All rights reserved.
//

#import <CoreData/CoreData.h>

@class Calendar;

@interface CalendarDate :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * exceptionType;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) Calendar * calendar;

@end



