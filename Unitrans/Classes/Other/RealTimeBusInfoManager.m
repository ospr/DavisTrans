//
//  RealTimeBusInfoXMLManager.m
//  Unitrans
//
//  Created by Ken Zheng on 11/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RealTimeBusInfoManager.h"
#import "RealTimeBusInfo.h"


@implementation RealTimeBusInfoManager

@synthesize realTimeBusInfo;
@synthesize currentElement;
@synthesize xmlParser;
@synthesize lastTime;

#pragma mark -
#pragma mark Singleton Methods

static RealTimeBusInfoManager *sharedRealTimeBusInfoManager = nil;

+ (RealTimeBusInfoManager *)sharedRealTimeBusInfoManager
{
    if (sharedRealTimeBusInfoManager == nil) {
        sharedRealTimeBusInfoManager = [[super allocWithZone:NULL] init];
    }
    return sharedRealTimeBusInfoManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedRealTimeBusInfoManager] retain];
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

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

#pragma mark -
#pragma mark Initializers

- (id) init
{
	if(self = [super init])
	{
		realTimeBusInfo = [[NSMutableArray alloc] init];
		[self setLastTime:-1];
	}
	return self;
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc
{
	[realTimeBusInfo release];
	[super dealloc];
}

#pragma mark -
#pragma mark Retrieval Methods

- (NSArray *) retrieveRealTimeBusInfo
{
	NSString *url = @"http://www.nextbus.com/s/xmlFeed?command=vehicleLocations&a=unitrans&t=0";
	[self retrieveRealTimeBusInfoFromURL:url];
	return [NSArray arrayWithArray:realTimeBusInfo];
}

- (NSArray *) retrieveRealTimeBusInfoFromLastTime
{
	if(lastTime == -1)
	{
		NSLog(@"First time getting info. Returning nil.");
		return nil;
    }
	
	NSString *url = [NSString stringWithFormat:@"http://www.nextbus.com/s/xmlFeed?command=vehicleLocations&a=unitrans&t=%d", lastTime];
	[self retrieveRealTimeBusInfoFromURL:url];
	return [NSArray arrayWithArray:realTimeBusInfo];
}

- (NSArray *) retrieveRealTimeBusInfoWithRoute:(NSString *)theRoute
{
	NSString *url = [NSString stringWithFormat:@"http://www.nextbus.com/s/xmlFeed?command=vehicleLocations&a=unitrans&t=0&r=%@", theRoute];
	[self retrieveRealTimeBusInfoFromURL:url];
	return [NSArray arrayWithArray:realTimeBusInfo];
}

- (void) retrieveRealTimeBusInfoFromURL:(NSString *)theURL
{
	NSLog(@"parse at url: %@", theURL);
	[realTimeBusInfo removeAllObjects];
	NSURL *xmlURL = [NSURL URLWithString:theURL];
	xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
	[xmlParser setDelegate:self];
	[xmlParser parse];
	[xmlParser release];
}

#pragma mark -
#pragma mark NSXMLParser Delegate Methods
// TODO: Need to do something with error
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError 
{
	NSString * errorString = [NSString stringWithFormat:@"Unable to download XML file from web site (Error code %i )", [parseError code]];
	NSLog(@"ERROR parsing XML: %@", errorString);
}

- (void)parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict
{
	currentElement = [elementName copy];
	
	if([elementName isEqualToString:@"vehicle"])
	{
		RealTimeBusInfo *vehicle = [[RealTimeBusInfo alloc] initWithVehicleID:[attributeDict valueForKey:@"id"] 
																 withRouteTag:[attributeDict valueForKey:@"routeTag"]
																   withDirTag:[attributeDict valueForKey:@"dirTag"]
																	  withLat:[[attributeDict valueForKey:@"lat"] floatValue]
																	  withLon:[[attributeDict valueForKey:@"lon"] floatValue]
														  withSecsSinceReport:[[attributeDict valueForKey:@"secsSinceReport"] intValue]
																  withHeading:[[attributeDict valueForKey:@"heading"] intValue]
															  withPredictable:[[attributeDict valueForKey:@"predictable"] boolValue]];
		[realTimeBusInfo addObject:vehicle];
		[vehicle release];
	}
	else if([elementName isEqualToString:@"lastTime"])
	{
		[self setLastTime:[[attributeDict valueForKey:@"lastTime"] intValue]];
	}
}

@end
