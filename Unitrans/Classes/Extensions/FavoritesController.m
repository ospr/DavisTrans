//
//  FavoritesController.m
//  Unitrans
//
//  Created by Kip on 4/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FavoritesController.h"
#import "Route.h"
#import "Stop.h"

static FavoritesController *sharedFavorites = nil;

@implementation FavoritesController

@synthesize favorites;

+ (FavoritesController *)sharedFavorites
{
    if (sharedFavorites == nil) {
        sharedFavorites = [[super allocWithZone:NULL] init];
    }
    
    return sharedFavorites;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedFavorites] retain];
}

- (id)init
{
    self = [super init];
    
    if (self) {
        favorites = [[NSMutableArray alloc] init];
    }
    
    return self;
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
    return NSUIntegerMax;
}

- (void)release
{
    // Do nothing
}

- (id)autorelease
{
    return self;
}

#pragma mark -
#pragma mark Favorites Methods

- (NSDictionary *)stopInfoForStop:(Stop *)stop andRoute:(Route *)route
{
    return [NSDictionary dictionaryWithObjectsAndKeys:route, @"route",
                                                      stop,  @"stop", nil];
}

- (void)sortFavorites
{	
	// Sort the favorite stops by route, stop name, and stop heading
	NSSortDescriptor *stopsSortDescriptor1 = [[[NSSortDescriptor alloc] initWithKey:@"route" ascending:YES] autorelease];
	NSSortDescriptor *stopsSortDescriptor2 = [[[NSSortDescriptor alloc] initWithKey:@"stop" ascending:YES] autorelease];
	[favorites sortUsingDescriptors:[NSArray arrayWithObjects:stopsSortDescriptor1, stopsSortDescriptor2, nil]];
}

- (BOOL)isFavoriteStop:(Stop *)stop forRoute:(Route *)route
{
    NSDictionary *stopInfo = [self stopInfoForStop:stop andRoute:route];
    
    return [favorites containsObject:stopInfo];
}

- (void)addFavoriteStop:(Stop *)stop forRoute:(Route *)route
{
    NSDictionary *stopInfo = [self stopInfoForStop:stop andRoute:route];
    
	if(![favorites containsObject:stopInfo])
		[favorites addObject:stopInfo];
	else
		NSLog(@"Failed to add favorite stop with name: %@ for route: %@.", [[stopInfo valueForKey:@"stop"] shortName], [[stopInfo valueForKey:@"route"] shortName]);
    
    [self sortFavorites];
    
    [self saveFavoritesData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FavoritesChanged" object:self userInfo:stopInfo];
}

- (void)removeFavoriteStop:(Stop *)stop forRoute:(Route *)route
{
    NSDictionary *stopInfo = [self stopInfoForStop:stop andRoute:route];
    
	if([favorites containsObject:stopInfo])
		[favorites removeObject:stopInfo];
	else
		NSLog(@"Failed to remove favorite stop with name: %@ for route: %@.", [[stopInfo valueForKey:@"stop"] shortName], [[stopInfo valueForKey:@"route"] shortName]);
    
    [self saveFavoritesData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FavoritesChanged" object:self userInfo:stopInfo];
}

- (NSArray *)allFavoriteStopsForRoute:(Route *)route
{
	NSMutableArray *stopsForRoute = [NSMutableArray array];
	
	for(NSDictionary *dict in favorites)
		if([[[dict valueForKey:@"route"] shortName] isEqual:[route shortName]])
			[stopsForRoute addObject:[dict valueForKey:@"stop"]];
	
	return [NSArray arrayWithArray:stopsForRoute];
}

- (NSString *)pathForFavoritesData
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *folderPath = [NSString stringWithFormat:@"%@/Unitrans/", documentsDirectory];
	
	// Check if save path exists
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:folderPath]) 
		[fileManager createDirectoryAtPath:folderPath attributes:nil];
	
	NSString *filename = @"Favorites.data";
	
	return [folderPath stringByAppendingPathComponent:filename];
}

- (void)saveFavoritesData
{
	NSMutableArray *favoritesSaveData = [[NSMutableArray alloc] init];
	
	// Save only the route shortName and stop codes
	for(NSDictionary *dict in favorites)
	{
		NSArray *keys = [NSArray arrayWithObjects:@"routeShortName", @"stopCode", nil];
		NSArray *objects = [NSArray arrayWithObjects:[[dict valueForKey:@"route"] shortName], [[dict valueForKey:@"stop"] code], nil];
		[favoritesSaveData addObject:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
	}
	
	NSString *path = [self pathForFavoritesData];
	
	if ([NSKeyedArchiver archiveRootObject:favoritesSaveData toFile:path])
		NSLog(@"Saved favorites data at: %@", path);
	else
		NSLog(@"Failed to save favorites data at: %@", path);
	
	[favoritesSaveData release];
}

- (void)loadFavoritesDataWithRoutes:(NSArray *)routes
{
    // Remove all old favorites
    [favorites removeAllObjects];
    
	NSString *path = [self pathForFavoritesData];
	NSArray *favoritesSaveData = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
	
	// Find and store appropriate route and stop objects for route shortName and stopCode
	for(NSDictionary *dict in favoritesSaveData)
	{
		Route *route = [self routeObjectForShortName:[dict valueForKey:@"routeShortName"] fromRoutes:routes];
		Stop *stop = [self stopObjectForRoute:route withStopCode:[dict valueForKey:@"stopCode"]];
		
		if(route && stop)
		{
			NSArray *keys = [NSArray arrayWithObjects:@"route", @"stop", nil];
			NSArray *objects = [NSArray arrayWithObjects:route, stop, nil];
			[favorites addObject:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
		}
	}
}

- (Route *)routeObjectForShortName:(NSString *)shortName fromRoutes:(NSArray *)routes
{
	for(Route *route in routes)
		if([[route shortName] isEqual:shortName])
			return route;
    
	return nil;
}

- (Stop *)stopObjectForRoute:(Route *)route withStopCode:(NSNumber *)stopCode
{
	if (!route) {
		NSLog(@"stopObjectForRoute: route is nil.");
		return nil;
	}
	
	NSArray *allStopsForRoute = [[route allStops] allObjects];
	
	for(Stop *stop in allStopsForRoute)
		if([[stop code] isEqual:stopCode])
			return stop;
    
	return nil;
}

@end
