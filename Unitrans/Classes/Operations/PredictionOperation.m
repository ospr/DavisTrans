//
//  PredictionOperation.m
//  Unitrans
//
//  Created by Kip on 12/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PredictionOperation.h"
#import "Route.h"
#import "Stop.h"


@implementation PredictionOperation

@synthesize stopTag;
@synthesize routeName;
@synthesize stopId;
@synthesize predictionTimes;
@synthesize parseError;
@synthesize delegate;

#pragma mark -
#pragma mark Initializers

- (id) initWithRouteName:(NSString *)newRouteName stopTag:(NSString *)newStopTag
{
	if((self = [super init]))
	{
		[self setStopTag:newStopTag];
		[self setRouteName:newRouteName];
		predictionTimes = [[NSMutableArray alloc] init];
	}
	return self;
}

#pragma mark -
#pragma mark Memory Management

- (void) dealloc
{
    [stopTag release];
    [routeName release];
    [stopId release];
	[predictionTimes release];
    [parseError release];
    
	[super dealloc];
}

#pragma mark -
#pragma mark Convenience Methods

- (NSString *)predictionText
{        
    // Convert all 0 times to "Now"
    NSMutableArray *predictionStrings = [NSMutableArray array];
    for (NSNumber *predictionTime in predictionTimes)
    {
        if ([predictionTime integerValue] == 0)
            [predictionStrings addObject:@"Now"];
        else
            [predictionStrings addObject:[predictionTime stringValue]];
    }
    
    // Create prediction text    
    NSString *predictionText;

    if ([predictionStrings count] == 1  && [[predictionStrings objectAtIndex:0] isEqual:@"Now"])
        predictionText = @"Now";
    else if ([predictionStrings count] == 1 && [[predictionStrings objectAtIndex:0] isEqualToString:@"1"])
        predictionText = @"1 minute";
    else if ([predictionStrings count] > 0)
        predictionText = [NSString stringWithFormat:@"%@ minutes", [predictionStrings componentsJoinedByString:@", "]];
    else
        predictionText = @"No predictions at this time.";
    
    return predictionText;
}

#pragma mark -
#pragma mark ConcurrentOperation Override Methods

- (void)main
{
    [self retrievePredictions];
}

- (void)didFinishOperation
{
    // If no error call predictions delegate method
    // otherwise call fail method
    if (!parseError)
        [delegate predictionOperation:self didFinishWithPredictions:predictionTimes];
    else
        [delegate predictionOperation:self didFailWithError:parseError];
}

#pragma mark -
#pragma mark Retrieval methods

// Method to retrieve predictions from XML and store the results into the predictionTimes array
- (void) retrievePredictions
{
	// Use the stopID from GTFS to look up the correct stopID from routeConfig for prediction
	// This prevents nonexistent stopID prediction queries ie. departing stops from terminal have no prediction
	[self retrieveStopIDFromRouteConfig];
	
    // Prediction for stop does not exist (ie. stop at terminal)
	if([stopId length] == 0)
		return;
    
    // If there was a parse error while retrieving stop ids return
    if (parseError)
        return;
	
	//NSString *predictionURLstring = [NSString stringWithFormat:@"http://www.nextbus.com/s/xmlFeed?command=predictions&a=unitrans&stopId=%@&r=%@", stopId, routeName];
	NSString *predictionURLstring = [NSString stringWithFormat:@"http://webservices.nextbus.com/service/publicXMLFeed?command=predictions&a=unitrans&s=%@&r=%@", stopId, routeName];
	[self parseXMLAtURLString:predictionURLstring];
    
    // HACK: NextBus sometimes returns duplicate and out of order times, we fix that here
    // Remove duplicate times and sort
    [self setPredictionTimes:[NSMutableArray arrayWithArray:[[NSSet setWithArray:predictionTimes] allObjects]]];
    [predictionTimes sortUsingSelector:@selector(compare:)];
}

- (void) retrieveStopIDFromRouteConfig
{
	//NSString *routeConfigURLString = [NSString stringWithFormat:@"http://www.nextbus.com/s/xmlFeed?command=routeConfig&a=unitrans&r=%@", routeName];
	NSString *routeConfigURLString = [NSString stringWithFormat:@"http://webservices.nextbus.com/service/publicXMLFeed?command=routeConfig&a=unitrans&r=%@", routeName];
	[self parseXMLAtURLString:routeConfigURLString];
}

- (void) parseXMLAtURLString:(NSString *)theURLString
{
    NSError *error;
	NSURL *url = [NSURL URLWithString:theURLString];
    
    // Send synchronous request to retrieve data so we can determine if an error occurs b/c no internet
    NSURLRequest *predictionRequest = [NSURLRequest requestWithURL:url];
    NSData *predictionData = [NSURLConnection sendSynchronousRequest:predictionRequest 
                                                   returningResponse:nil 
                                                               error:&error];
    
    if (!predictionData) {
        NSLog(@"Error gathering prediction data from NSURLConnection: %@ %@", error, [error userInfo]);
        [self setParseError:error];
        return;
    }
    
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:predictionData];
	[xmlParser setDelegate:self];
	[xmlParser parse];
	[xmlParser release];
}

#pragma mark -
#pragma mark NSXMLParser Delegate Methods

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)error 
{
    // If we didn't explicitly abort the parsing, then there was a real error
    if (!parseAborted) {
        NSLog(@"Prediction manager had error while parsing predictions: %@ %@.", error, [error userInfo]);
        
        [self setParseError:error];
    }
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
			[self setStopId:[attributeDict valueForKey:@"tag"]];
            parseAborted = YES;
			[parser abortParsing];
		}
	}
	else if([elementName isEqualToString:@"prediction"])
	{
		[predictionTimes addObject:[NSNumber numberWithInteger:[[attributeDict valueForKey:@"minutes"] integerValue]]];
	}
}

@end
