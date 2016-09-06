//
//  DatabaseManager.m
//  DavisTrans
//
//  Created by Kip Nicol on 10/28/09.
//  Copyright 2009 Kip Nicol & Ken Zheng
//

#import "DatabaseManager.h"
#import "AppDelegate.h"
#import "Agency.h"
#import "Calendar.h"
#import "CalendarDate.h"
#import "RoutePattern.h"
#import "Route.h"
#import "Shape.h"
#import "Stop.h"
#import "StopTime.h"
#import "Trip.h"
#import "Service.h"


@implementation DatabaseManager

@synthesize currentService;

#pragma mark -
#pragma mark Singleton Methods

static DatabaseManager *sharedDatabaseManager = nil;

+ (DatabaseManager *)sharedDatabaseManager
{
    if (sharedDatabaseManager == nil) {
        sharedDatabaseManager = [[super allocWithZone:NULL] init];
    }
    return sharedDatabaseManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedDatabaseManager] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

#pragma mark -
#pragma mark Memory management

/*- (id)init
{
    self = [super init];
    
    if (self) {
        // Set default service to the first service
        [self setCurrentService:[[self allServices] objectAtIndex:0]];
    }
    
    return self;
}*/

- (void)dealloc 
{	
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
    [currentService release];
    
	[super dealloc];
}

#pragma mark -
#pragma mark Retrieval Methods

- (Agency *)retrieveUnitransAgency:(NSError **)error
{   
    // Create request
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    
    // Set Route entity
    [request setEntity:[NSEntityDescription entityForName:@"Agency" inManagedObjectContext:[self managedObjectContext]]];
    
    // Filter out only the unitrans agency
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", @"Unitrans (Davis)"];
    [request setPredicate:predicate];
    
    // Execute fetch
    NSArray *agencyArray = [[self managedObjectContext] executeFetchRequest:request error:error];
    if (!agencyArray)
        return nil;
    
    // Return Unitrans agency
    return [agencyArray lastObject];
}

#pragma mark -
#pragma mark Service Methods

/*- (Service *)defaultService
{
    NSArray *services = [self allServices];
    
    for (Service *service in services)
        if 
}*/

- (NSArray *)allServices
{
    // Hardcode these for now until a better way is determined
    // IDEA: Move these to a service entity in each GTFS schedule and access them thru there
    Service *spring = [[[Service alloc] init] autorelease];
    [spring setShortName:@"Spring"];
    [spring setLongName:@"Spring '13"];
    [spring setResourceName:@"UnitransSchedule_20130331"];
    [spring setResourceKind:@"sqlite"];
    
    // Return the sorted array of services
    return [NSArray arrayWithObjects:spring, nil];
}

- (void)useService:(Service *)newService
{
    // If new service is the same as the old, then don't update
    if ([newService isEqual:currentService])
        return;
    
    // Set to new service
    [self setCurrentService:newService];
    
    // Release all core data stack and set to nil
    [managedObjectModel release]; managedObjectModel = nil;
    [managedObjectContext release]; managedObjectContext = nil;
    [persistentStoreCoordinator release]; persistentStoreCoordinator = nil;
}

#pragma mark -
#pragma mark Create Database Methods

- (BOOL)createDatabaseFromGoogleTransitFeed:(NSString *)feedDirectory
{
    NSError *error;
    
    // Prepare GTF file paths
    NSString *agencyFile = [feedDirectory stringByAppendingPathComponent:@"agency.txt"];
    NSString *calendarFile = [feedDirectory stringByAppendingPathComponent:@"calendar.txt"];
    NSString *calendarDateFile = [feedDirectory stringByAppendingPathComponent:@"calendar_dates.txt"];
    NSString *routeFile = [feedDirectory stringByAppendingPathComponent:@"routes.txt"];
    NSString *shapeFile = [feedDirectory stringByAppendingPathComponent:@"shapes.txt"];
    NSString *stopsFile = [feedDirectory stringByAppendingPathComponent:@"stops.txt"];
    NSString *stopTimesFile = [feedDirectory stringByAppendingPathComponent:@"stop_times.txt"];
    NSString *tripsFile = [feedDirectory stringByAppendingPathComponent:@"trips.txt"];
    
    // Create ordered array for processing
    NSArray *files = [NSArray arrayWithObjects:agencyFile, routeFile, shapeFile, stopsFile, calendarFile, calendarDateFile, tripsFile, stopTimesFile, nil];
    
    // Initialize dictionaries
    agencies = [[NSMutableDictionary alloc] init];
    calendars = [[NSMutableDictionary alloc] init];
    routes = [[NSMutableDictionary alloc] init];
    shapes = [[NSMutableDictionary alloc] init];
    stops = [[NSMutableDictionary alloc] init];
    trips = [[NSMutableDictionary alloc] init];

    // Process files
    for (int i = 0; i < [files count]; i += 1) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        processStep = i;
        if (![self processFile:[files objectAtIndex:i] error:&error])
            return NO;
        [pool drain];
    }
    
    [self removeRoutesWithZeroTrips];
    [self derivePrimaryTrips];
    [self deriveRoutePatterns];
    
    // Clean up dictionaries
    [agencies release];
    [calendars release];
    [routes release];
    [shapes release];
    [stops release];
    [trips release];
    
    // Save core data file
    if (![[self managedObjectContext] save:&error]) {
        NSLog(@"Error when trying to save core data file: %@", error);
        return NO;
    }
    
    return YES;
}

- (BOOL)processFile:(NSString *)path error:(NSError **)error
{
    //NSLog(@"========================= PROCESSING FILE: %@ ==========================", path);
    
    // Read in all text, split by newline, and extract header line
    NSString *text = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:error];
    NSArray *lines = [text componentsSeparatedByString:@"\r\n"];
    NSArray *headers = [[lines objectAtIndex:0] componentsSeparatedByString:@","];
    
    [text release];
    
    // Loop through value lines and process them
    for (int i = 1; i < [lines count]; i += 1)
    {
        NSString *valuesString = [lines objectAtIndex:i];
        if ([valuesString isEqualToString:@""])
            continue;
        
        NSArray *values = [valuesString componentsSeparatedByString:@","];
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        BOOL ret = [self processValues:values withHeaders:headers error:error];
        [pool drain];

        if (!ret) return NO;
    }
    
    return YES;
}

- (BOOL)processValues:(NSArray *)values withHeaders:(NSArray *)headers error:(NSError **)error
{
    switch (processStep) {
        case kProcessAgencyStep:       return [self addEntity:@"Agency" withValues:values headers:headers error:error]; 
        case kProcessCalendarStep:     return [self addEntity:@"Calendar" withValues:values headers:headers error:error];
        case kProcessCalendarDateStep: return [self addEntity:@"CalendarDate" withValues:values headers:headers error:error];
        case kProcessRouteStep:        return [self addEntity:@"Route" withValues:values headers:headers error:error];
        case kProcessShapeStep:        return [self addEntity:@"Shape" withValues:values headers:headers error:error];
        case kProcessStopStep:         return [self addEntity:@"Stop" withValues:values headers:headers error:error];
        case kProcessStopTimeStep:     return [self addEntity:@"StopTime" withValues:values headers:headers error:error];
        case kProcessTripStep:         return [self addEntity:@"Trip" withValues:values headers:headers error:error];
            
        // TODO: create error
        default:
            NSLog(@"Error: unknown process step %d", processStep);
            return NO;
    }
}

- (BOOL)addEntity:(NSString *)entityString withValues:(NSArray *)values headers:(NSArray *)headers error:(NSError **)error
{
    NSUInteger valuesCount  = [values count];
    NSUInteger headersCount = [headers count];
    
    // TODO: create error here
    if (valuesCount != headersCount) {
        NSLog(@"Error: header count (%lu) doesn not match value count (%lu)", (unsigned long)headersCount, (unsigned long)valuesCount);
        NSLog(@"Headers:\n%@\n\nValues:\n%@\n", headers, values);
        return NO;
    }
    
    // Create new entity
    id entity = [self insertNewObjectForEntityForName:entityString];
    
    // Set entity's properties based on header using value
    for (int i = 0; i < headersCount; i += 1) {
        NSString *header = [headers objectAtIndex:i];
        NSString *value  = [values objectAtIndex:i];
        
        // Strip away any leading/trailing whitespace (shapes.txt)
        value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        [self setEntity:entity propertyWithValue:value header:header];
    }
    
    //NSLog(@"New %@: %@", entityString, entity);
        
    return YES;
}

- (BOOL)setEntity:(id)entity propertyWithValue:(NSString *)value header:(NSString *)header
{
    if (processStep == kProcessAgencyStep)
    {
        Agency *agency = entity;
        if ([header isEqualToString:@"agency_id"])
            [agencies setObject:agency forKey:value];
        else if ([header isEqualToString:@"agency_name"])
            [agency setName:value];
        else if ([header isEqualToString:@"agency_url"])
            [agency setUrl:value];
        else if ([header isEqualToString:@"agency_phone"])
            [agency setPhone:value];
    }
    else if (processStep == kProcessCalendarStep)
    {
        Calendar *calendar = entity;
        if ([header isEqualToString:@"service_id"])
            [calendars setObject:calendar forKey:value];
        else if ([header isEqualToString:@"sunday"])
            [calendar setSunday:[self processBoolNumberString:value]];
        else if ([header isEqualToString:@"monday"])
            [calendar setMonday:[self processBoolNumberString:value]];
        else if ([header isEqualToString:@"tuesday"])
            [calendar setTuesday:[self processBoolNumberString:value]];
        else if ([header isEqualToString:@"wednesday"])
            [calendar setWednesday:[self processBoolNumberString:value]];
        else if ([header isEqualToString:@"thursday"])
            [calendar setThursday:[self processBoolNumberString:value]];
        else if ([header isEqualToString:@"friday"])
            [calendar setFriday:[self processBoolNumberString:value]];
        else if ([header isEqualToString:@"saturday"])
            [calendar setSaturday:[self processBoolNumberString:value]];
        else if ([header isEqualToString:@"start_date"])
            [calendar setStartDate:[self processDateString:value]];
        else if ([header isEqualToString:@"end_date"])
            [calendar setEndDate:[self processDateString:value]];
    }
    else if (processStep == kProcessCalendarDateStep)
    {
        CalendarDate *calendarDate = entity;
        if ([header isEqualToString:@"service_id"])
            [calendarDate setCalendar:[calendars objectForKey:value]];
        else if ([header isEqualToString:@"date"])
            [calendarDate setDate:[self processDateString:value]];
        else if ([header isEqualToString:@"exception_type"])
            [calendarDate setExceptionType:[self processShortNumberString:value]];
    }
    else if (processStep == kProcessRouteStep) 
    {
        Route *route = entity;
        if ([header isEqualToString:@"route_id"])
            [routes setObject:route forKey:value];
        else if ([header isEqualToString:@"agency_id"])
            [route setAgency:[agencies objectForKey:value]];
        else if ([header isEqualToString:@"route_short_name"])
            [route setShortName:value];
        else if ([header isEqualToString:@"route_long_name"])
            [route setLongName:value];
        else if ([header isEqualToString:@"route_type"])
            [route setType:[self processShortNumberString:value]];
        else if ([header isEqualToString:@"route_color"])
            [route setColor:[self processHexNumberString:value]];
        else if ([header isEqualToString:@"route_text_color"])
            [route setTextColor:[self processHexNumberString:value]];
    }
    else if (processStep == kProcessShapeStep)
    {
        Shape *shape = entity;
        if ([header isEqualToString:@"shape_id"]) {
            // Create new shape set if shape_id is not found
            NSMutableSet *shapeSet = [shapes objectForKey:value];
            if (!shapeSet) {
                shapeSet = [NSMutableSet set];
                [shapes setObject:shapeSet forKey:value];
            }
            [shapeSet addObject:shape];
        }
        else if ([header isEqualToString:@"shape_pt_lat"])
            [shape setPointLatitude:[self processDoubleNumberString:value]];
        else if ([header isEqualToString:@"shape_pt_lon"])
            [shape setPointLongitude:[self processDoubleNumberString:value]];
        else if ([header isEqualToString:@"shape_pt_sequence"])
            [shape setPointSequence:[self processUnsignedIntegerNumberString:value]];
    }
    else if (processStep == kProcessStopStep)
    {
        Stop *stop = entity;
        if ([header isEqualToString:@"stop_id"])
            [stops setObject:stop forKey:value];
        else if ([header isEqualToString:@"stop_name"]) {
            [stop setName:[self processStopName:value]];
            [stop setHeading:[self processHeading:value]];
        }
        else if ([header isEqualToString:@"stop_desc"])
            [stop setStopDescription:value];
        else if ([header isEqualToString:@"stop_lat"])
            [stop setLatitude:[self processDoubleNumberString:value]];
        else if ([header isEqualToString:@"stop_lon"])
            [stop setLongitude:[self processDoubleNumberString:value]];
        else if ([header isEqualToString:@"stop_code"])
            [stop setCode:[self processUnsignedIntegerNumberString:value]];
    }
    else if (processStep == kProcessStopTimeStep)
    {        
        StopTime *stopTime = entity;
        if ([header isEqualToString:@"trip_id"])
            [stopTime setTrip:[trips objectForKey:value]];
        else if ([header isEqualToString:@"arrival_time"])
            [stopTime setArrivalTimeFromTimeString:value];
        else if ([header isEqualToString:@"departure_time"])
            [stopTime setDepartureTimeFromTimeString:value];
        else if ([header isEqualToString:@"stop_id"])
            [stopTime setStop:[stops objectForKey:value]];
        else if ([header isEqualToString:@"stop_sequence"])
            [stopTime setSequence:[self processShortNumberString:value]];
        else if ([header isEqualToString:@"pickup_type"])
            [stopTime setPickupType:[self processShortNumberString:value]];
        else if ([header isEqualToString:@"drop_off_type"])
            [stopTime setDropOffType:[self processShortNumberString:value]];        
    }
    else if (processStep == kProcessTripStep)
    {
        Trip *trip = entity;
        if ([header isEqualToString:@"route_id"])
            [trip setRoute:[routes objectForKey:value]];
        else if ([header isEqualToString:@"service_id"])       
            [trip setCalendar:[calendars objectForKey:value]];
        else if ([header isEqualToString:@"trip_id"])
            [trips setObject:trip forKey:value];
        else if ([header isEqualToString:@"trip_headsign"])
            [trip setHeadsign:value];
        else if ([header isEqualToString:@"shape_id"])
            [trip setShapes:[shapes objectForKey:value]];
        else if ([header isEqualToString:@"direction_id"])
            [trip setDirection:[self processShortNumberString:value]];
        else if ([header isEqualToString:@"block_id"])
            [trip setBlock:[self processShortNumberString:value]];
    }
    
    return YES;
}

- (void)deriveRoutePatterns
{
    for (Route *route in [routes allValues])
    {
        NSMutableSet *usedTrips = [[NSMutableSet alloc] init];
        for (Trip *currentTrip in [route trips])
        {
            // If the trip was already assigned a pattern just skip it
            if ([usedTrips containsObject:currentTrip])
                continue;
            
            NSMutableSet *patternTrips = [[NSMutableSet alloc] init];
            for (Trip *trip in [route trips])
            {
                // If trip has the same stops and shape it belongs in the same pattern
                if ([[trip stops] isEqualToSet:[currentTrip stops]] && [[trip shapes] isEqualToSet:[currentTrip shapes]]) {
                    [patternTrips addObject:trip];
                    [usedTrips addObject:trip];
                }
            }
            
            // Create new pattern and set trips
            RoutePattern *pattern = [self insertNewObjectForEntityForName:@"RoutePattern"];
            [pattern setTrips:patternTrips];
            
            // Add pattern to route
            [route addRoutePatternsObject:pattern];
            [patternTrips release];
        }
        [usedTrips release];
    }
}

- (void)derivePrimaryTrips
{
    [[routes objectForKey:@"A"] setPrimaryTrip:[trips objectForKey:@"256163"]];
    [[routes objectForKey:@"B"] setPrimaryTrip:[trips objectForKey:@"256265"]];
    [[routes objectForKey:@"C"] setPrimaryTrip:[trips objectForKey:@"256346"]];
    [[routes objectForKey:@"D"] setPrimaryTrip:[trips objectForKey:@"256449"]];
    [[routes objectForKey:@"E"] setPrimaryTrip:[trips objectForKey:@"256593"]];
    [[routes objectForKey:@"F"] setPrimaryTrip:[trips objectForKey:@"256695"]];
    [[routes objectForKey:@"G"] setPrimaryTrip:[trips objectForKey:@"256836"]];
    [[routes objectForKey:@"H"] setPrimaryTrip:[trips objectForKey:@"265080"]];
    [[routes objectForKey:@"J"] setPrimaryTrip:[trips objectForKey:@"256986"]];
    [[routes objectForKey:@"K"] setPrimaryTrip:[trips objectForKey:@"257166"]];
    [[routes objectForKey:@"L"] setPrimaryTrip:[trips objectForKey:@"257268"]];
    [[routes objectForKey:@"M"] setPrimaryTrip:[trips objectForKey:@"257371"]];
    [[routes objectForKey:@"P"] setPrimaryTrip:[trips objectForKey:@"257520"]];
    [[routes objectForKey:@"Q"] setPrimaryTrip:[trips objectForKey:@"257615"]];
    [[routes objectForKey:@"S"] setPrimaryTrip:[trips objectForKey:@"257683"]];
    [[routes objectForKey:@"T"] setPrimaryTrip:[trips objectForKey:@"257695"]];
    [[routes objectForKey:@"U"] setPrimaryTrip:[trips objectForKey:@"273061"]];
    [[routes objectForKey:@"W"] setPrimaryTrip:[trips objectForKey:@"257789"]];
}

- (void)removeRoutesWithZeroTrips
{
    for (Route *route in [routes allValues])
        if ([[route trips] count] == 0)
            [[self managedObjectContext] deleteObject:route];
}

- (NSNumber *)processHexNumberString:(NSString *)value
{    
    unsigned intValue = 0;

    NSScanner *scanner = [NSScanner scannerWithString:value];
    [scanner scanHexInt:&intValue];
    
    return [NSNumber numberWithUnsignedInt:intValue];
}

- (NSNumber *)processDoubleNumberString:(NSString *)value
{   
    return [NSNumber numberWithDouble:[value doubleValue]];
}
                                     
- (NSNumber *)processUnsignedIntegerNumberString:(NSString *)value
{
    return [NSNumber numberWithUnsignedInteger:[value intValue]];
}

- (NSNumber *)processShortNumberString:(NSString *)value
{
    return [NSNumber numberWithShort:[value intValue]];
}
             
- (NSNumber *)processBoolNumberString:(NSString *)value
{
    return [NSNumber numberWithBool:[value boolValue]];
}

- (NSDate *)processDateString:(NSString *)value
{
    static NSDateFormatter *dateFormatter = nil;
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
    }
    
    return [dateFormatter dateFromString:value];
}

- (NSString *)processStopName:(NSString *)value
{
    // If stop name begins with 'Memorial Union'
    if ([value hasPrefix:@"Memorial Union"]) {
        if ([value rangeOfString:@"Arrival"].location != NSNotFound)
            return @"Memorial Union (Arrival)";
        else
            return @"Memorial Union (Departure)";
    }
    // If stop name begins with 'Silo Terminal'
    if ([value hasPrefix:@"Silo Terminal"])
        return @"Silo Terminal";
    // If stop name begins with 'Hutchison & California'
    if ([value hasPrefix:@"Hutchison & California"])
        return @"Hutchison & California (Silo)";
    
    // Create array of strings to remove from the stop names
    NSArray *streetSuffixes = [NSArray arrayWithObjects:@"Dr", @"St", @"Blvd", @"Rd", @"Ln", @"Ave", 
                                                        @"Loop", @"Way", @"Street", @"Ct", 
                                                        @"(NB)", @"(SB)", @"(WB)", @"(EB)", @"", nil];
    
    // Remove street suffixes and headings
    NSMutableArray *stopNameComponents = [NSMutableArray arrayWithArray:[value componentsSeparatedByString:@" "]];
    [stopNameComponents removeObjectsInArray:streetSuffixes];
    
    // If the last component is '&', then remove it
    if ([[stopNameComponents lastObject] isEqualToString:@"&"])
        [stopNameComponents removeLastObject];
    
    return [stopNameComponents componentsJoinedByString:@" "];
}

- (NSNumber *)processHeading:(NSString *)value
{
    if ([value hasSuffix:@"(NB)"])
        return [NSNumber numberWithInt:kStopHeadingTypeNorthBound];
    if ([value hasSuffix:@"(SB)"])
        return [NSNumber numberWithInt:kStopHeadingTypeSouthBound];
    if ([value hasSuffix:@"(WB)"])
        return [NSNumber numberWithInt:kStopHeadingTypeWestBound];
    if ([value hasSuffix:@"(EB)"])
        return [NSNumber numberWithInt:kStopHeadingTypeEastBound];
    
    NSLog(@"Could not find heading for value: '%@'.", value);
    
    return nil;
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext 
{	
    if (managedObjectContext != nil)
        return managedObjectContext;
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel 
{	
    if (managedObjectModel != nil)
        return managedObjectModel;

    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{	
    if (persistentStoreCoordinator != nil)
        return persistentStoreCoordinator;
	
    //NSURL *storeUrl = [NSURL fileURLWithPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"TestDB10.sqlite"]];
    //NSString *resourcePath = [NSString stringWithFormat:@"%@_%@", kUnitransSchedulePrefix, kUnitransScheduleDate];
    NSString *serviceStorePath = [[NSBundle mainBundle] pathForResource:[currentService resourceName] ofType:[currentService resourceKind]];
    NSURL *storeUrl = [NSURL fileURLWithPath:serviceStorePath];
    
//    NSLog(@"store url = %@", storeUrl);
    
    // TODO: remove this/modify before production
    //NSError *rmError;
    //if (![[NSFileManager defaultManager] removeItemAtPath:[storeUrl path] error:&rmError])
    //    NSLog(@"Error removing store '%@': %@", [storeUrl path], rmError);
            
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
	/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error when loading core data file %@, %@", error, [error userInfo]);
		
        criticalLoadingErrorAlert();
    }    
	
    return persistentStoreCoordinator;
}

- (id)insertNewObjectForEntityForName:(NSString *)entityName
{
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[self managedObjectContext]];
}

#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory 
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


@end
