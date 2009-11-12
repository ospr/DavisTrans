//
//  PredictionManager.m
//  Unitrans
//
//  Created by Ken Zheng on 11/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PredictionManager.h"

@implementation PredictionManager

@synthesize stopTag;
@synthesize routeShortname;
@synthesize stopId;
@synthesize predictionInMinutes;
@synthesize predictionTimeFormatter;

#pragma mark -
#pragma mark Singleton Methods

static PredictionManager *sharedPredictionManager = nil;

+ (PredictionManager *)sharedPredictionManager
{
    if (sharedPredictionManager == nil) {
        sharedPredictionManager = [[super allocWithZone:NULL] init];
    }
    return sharedPredictionManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedPredictionManager] retain];
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
		[self setStopTag:@""];
		[self setRouteShortname:@""];
		[self setStopId:@""];
		[self setPredictionInMinutes:0];
		
		// Initialize NSDateFormatter
		predictionTimeFormatter = [[NSDateFormatter alloc] init];
		[predictionTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
		[predictionTimeFormatter setDateStyle:NSDateFormatterNoStyle];
		NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		[predictionTimeFormatter setLocale:usLocale];
		[usLocale release];
	}
	return self;
}

#pragma mark -
#pragma mark Memory Management

- (void) dealloc
{
	[predictionTimeFormatter release];
	[super dealloc];
}

#pragma mark -
#pragma mark Retrieval methods

- (NSString *) retrievePredictionInMinutesForRoute:(Route *)theRoute atStop:(Stop *)theStop
{
	[self setStopTag:[[theStop code] stringValue]];
	[self setRouteShortname:[theRoute shortName]];
	[self retrievePrediction];
	return [NSString stringWithFormat:@"%d", predictionInMinutes];
}

- (NSString *) retrievePredictionAsTimeForRoute:(Route *)theRoute atStop:(Stop *)theStop
{
	[self setStopTag:[[theStop code] stringValue]];
	[self setRouteShortname:[theRoute shortName]];
	[self retrievePrediction];
	
	NSTimeInterval predictionInSeconds = predictionInMinutes * 60;
	NSDate *predictionTime = [[[NSDate alloc] initWithTimeIntervalSinceNow:predictionInSeconds] autorelease];
	
	return [predictionTimeFormatter stringFromDate:predictionTime];
}

- (void) retrievePrediction
{	
	// Use the stopID from GTFS to look up the correct stopID from routeConfig for prediction
	// This prevents nonexistent stopID prediction queries ie. departing stops from terminal have no prediction
	[self retrieveStopIDFromRouteConfig];
	
	if([stopId length] == 0)
	{
		[self setPredictionInMinutes:-1];
		return;
	}
	
	NSString *predictionURLstring = [NSString stringWithFormat:@"http://www.nextbus.com/s/xmlFeed?command=predictions&a=unitrans&stopId=%@&r=%@", stopId, routeShortname];
	[self parseXMLAtURLString:predictionURLstring];
}

- (void) retrieveStopIDFromRouteConfig
{
	NSString *routeConfigURLString = [NSString stringWithFormat:@"http://www.nextbus.com/s/xmlFeed?command=routeConfig&a=unitrans&r=%@", routeShortname];
	[self setStopId:@""];
	[self parseXMLAtURLString:routeConfigURLString];
}

- (void) parseXMLAtURLString:(NSString *)theURLString
{
	NSURL *url = [NSURL URLWithString:theURLString];
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	[xmlParser setDelegate:self];
	[xmlParser parse];
	[xmlParser release];
}

#pragma mark -
#pragma mark NSXMLParser Delegate Methods

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError 
{
	//NSLog(@"Parse manually aborted or aborted due to parse error.");
}

- (void)parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict
{
	if([elementName isEqualToString:@"stop"])
	{
		if([stopTag isEqualToString:[attributeDict valueForKey:@"tag"]] && ([attributeDict objectForKey:@"stopId"] != nil))
		{
			[self setStopId:[attributeDict valueForKey:@"stopId"]];
			[parser abortParsing];
		}
	}
	else if([elementName isEqualToString:@"prediction"])
	{
		[self setPredictionInMinutes:[[attributeDict valueForKey:@"minutes"] intValue]];
		[parser abortParsing];
	}
}

@end
