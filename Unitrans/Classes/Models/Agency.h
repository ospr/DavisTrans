//
//  Agency.h
//  DavisTrans
//
//  Created by Kip Nicol on 10/27/09.
//  Copyright 2009  All rights reserved.
//

#import <CoreData/CoreData.h>

@class Route;

@interface Agency :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSSet* routes;

- (BOOL)transitDataUpToDate;

@end


@interface Agency (CoreDataGeneratedAccessors)
- (void)addRoutesObject:(Route *)value;
- (void)removeRoutesObject:(Route *)value;
- (void)addRoutes:(NSSet *)value;
- (void)removeRoutes:(NSSet *)value;

@end

