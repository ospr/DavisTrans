//
//  DatabaseManager.h
//  Unitrans
//
//  Created by Kip Nicol on 10/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum _ProcessStep {
    kProcessAgencyStep = 0, 
    kProcessRouteStep = 1,
    kProcessShapeStep = 2, 
    kProcessStopStep = 3,       
    kProcessCalendarStep = 4,    
    kProcessCalendarDateStep = 5,
    kProcessTripStep = 6,
    kProcessStopTimeStep = 7
} ProcessStep;

@class Agency;

@interface DatabaseManager : NSObject {
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    
    NSMutableDictionary *agencies;
    NSMutableDictionary *calendars;
    NSMutableDictionary *routes;
    NSMutableDictionary *shapes;
    NSMutableDictionary *stops;
    NSMutableDictionary *trips;
    
    ProcessStep processStep;
}

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (DatabaseManager *)sharedDatabaseManager;

- (Agency *)retrieveUnitransAgency:(NSError **)error;

- (BOOL)createDatabaseFromGoogleTransitFeed:(NSString *)feedDirectory;
- (id)insertNewObjectForEntityForName:(NSString *)entityName;
- (BOOL)addEntity:(NSString *)entityString withValues:(NSArray *)values headers:(NSArray *)headers error:(NSError **)error;
- (BOOL)setEntity:(id)entity propertyWithValue:(NSString *)value header:(NSString *)header;

- (BOOL)processFile:(NSString *)path error:(NSError **)error;
- (BOOL)processValues:(NSArray *)values withHeaders:(NSArray *)headers error:(NSError **)error;

- (NSNumber *)processHexNumberString:(NSString *)value;
- (NSNumber *)processDoubleNumberString:(NSString *)value;
- (NSNumber *)processUnsignedIntegerNumberString:(NSString *)value;
- (NSNumber *)processShortNumberString:(NSString *)value;
- (NSNumber *)processBoolNumberString:(NSString *)value;
- (NSDate *)processDateString:(NSString *)value;

- (NSString *)applicationDocumentsDirectory;

@end
