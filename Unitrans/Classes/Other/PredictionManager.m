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
@synthesize predictionTimeFormatter;
@synthesize predictionTimes;

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
		predictionTimes = [[NSMutableArray alloc] init];
		
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
	[predictionTimes release];
	[predictionTimeFormatter release];
	[super dealloc];
}

#pragma mark -
#pragma mark Retrieval methods

// Returns an array strings in minutes
- (NSArray *) retrievePredictionInMinutesForRoute:(Route *)theRoute atStop:(Stop *)theStop
{
	[self initializeRetrieve:theRoute atStop:theStop];
	return predictionTimes;
}

// Returns an array of strings in format 'HH:MM am/pm'
- (NSArray *) retrievePredictionAsTimeForRoute:(Route *)theRoute atStop:(Stop *)theStop
{
	[self initializeRetrieve:theRoute atStop:theStop];

	return [self convertMinutesToTime];
}

// Returns an array of dictionaries with keys 'minutes' and 'time'
- (NSArray *) retrievePredictionInMinutesAndAsTimeForRoute:(Route *)theRoute atStop:(Stop *)theStop
{
	[self initializeRetrieve:theRoute atStop:theStop];
	
	NSArray *predictionTimeStrings = [self convertMinutesToTime];
	NSMutableArray *predictionInMinutesAndTime = [[[NSMutableArray alloc] init] autorelease];
	
	NSInteger predictionCount = [predictionTimes count];
	
	for(int i = 0; i < predictionCount; i++)
	{
		NSDictionary *minAndTime = [[NSDictionary alloc] initWithObjectsAndKeys:[predictionTimes objectAtIndex:i], @"minutes", [predictionTimeStrings objectAtIndex:i], @"time", nil];
		[predictionInMinutesAndTime addObject:minAndTime];
		[minAndTime release];
	}
	
	return predictionInMinutesAndTime;
}

- (NSArray *) convertMinutesToTime
{
	NSTimeInterval predictionInSeconds;
	NSMutableArray *predictionTimeStrings = [[[NSMutableArray alloc] init] autorelease];
	
	for(NSString *minutes in predictionTimes)
	{
		predictionInSeconds = [minutes intValue] * 60;
		[predictionTimeStrings addObject:[predictionTimeFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:predictionInSeconds]]];
	}
	
	return [NSArray arrayWithArray:predictionTimeStrings];
}

// Takes care of pre-retrieval tasks
- (void) initializeRetrieve:(Route *)theRoute atStop:(Stop *)theStop
{
	[predictionTimes removeAllObjects];
	[self setStopTag:[[theStop code] stringValue]];
	[self setRouteShortname:[theRoute shortName]];
	[self retrievePrediction];
}

// Method to retrieve predictions from XML and store the results into the predictionTimes array
- (void) retrievePrediction
{	
	// Use the stopID from GTFS to look up the correct stopID from routeConfig for prediction
	// This prevents nonexistent stopID prediction queries ie. departing stops from terminal have no prediction
	[self retrieveStopIDFromRouteConfig];
	
	if([stopId length] == 0)
	{
		// Prediction for stop does not exist (ie. stop at terminal)
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
		[predictionTimes addObject:[attributeDict valueForKey:@"minutes"]];
	}
}

@end
