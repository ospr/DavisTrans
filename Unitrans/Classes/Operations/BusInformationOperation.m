//
//  BusInformationOperation.m
//  Unitrans
//
//  Created by Kip on 12/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BusInformationOperation.h"
#import "RealTimeBusInfo.h"


@implementation BusInformationOperation

@synthesize busInformation;
@synthesize routeName;
@synthesize currentElement;
@synthesize parseError;
@synthesize delegate;

#pragma mark -
#pragma mark Initializers

- (id) initWithRouteName:(NSString *)newRouteName
{
	if(self = [super init])
	{
        [self setRouteName:newRouteName];
		busInformation = [[NSMutableArray alloc] init];
	}
	return self;
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc
{
	[busInformation release];
    [routeName release];
    [currentElement release];
    [parseError release];
    
	[super dealloc];
}

#pragma mark -
#pragma mark ConcurrentOperation Override Methods

- (void)main
{
    [self retrieveBusInformation];
}

- (void)didFinishOperation
{
    // If no error, call bus information delegate method,
    // otherwise call error method
    if (!parseError)
        [delegate busInformation:self didFinishWithBusInformation:busInformation];
    else
        [delegate busInformation:self didFailWithError:parseError];
}

#pragma mark -
#pragma mark Retrieval Methods

- (void) retrieveBusInformation
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.nextbus.com/s/xmlFeed?command=vehicleLocations&a=unitrans&t=0&r=%@", routeName]];
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	[xmlParser setDelegate:self];
	[xmlParser parse];
	[xmlParser release];
}

#pragma mark -
#pragma mark NSXMLParser Delegate Methods
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)error 
{
	NSString * errorString = [NSString stringWithFormat:@"Unable to download XML file from web site error: %@", error];
	NSLog(@"ERROR parsing XML: %@", errorString);
    
    [self setParseError:error];
}

- (void)parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict
{	
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
		[busInformation addObject:vehicle];
		[vehicle release];
	}
}

@end
