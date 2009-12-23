//
//  CSRouteAnnotation.m
//  testMapp
//
//  Created by Craig on 8/18/09.
//  Copyright Craig Spitzkoff 2009. All rights reserved.
//

#import "CSRouteAnnotation.h"


@implementation CSRouteAnnotation
@synthesize coordinate = _center;
@synthesize lineColor = _lineColor;
@dynamic points;
@synthesize routeID = _routeID;

- (id)init
{
    self = [super init];
    
    if (self) {
        // create a unique ID for this route so it can be added to dictionaries by this key. 
        self.routeID = [NSString stringWithFormat:@"%p", self];
    }
    
    return self;
}

- (id)initWithPoints:(NSArray*)points
{
	self = [self init];
	
    if (self) {
        [self setPoints:points];
        [self setLineColor:[UIColor blueColor]];
    }
	
	return self;
}

- (void) dealloc
{
	[_points release];
	[_lineColor release];
    [_routeID release];
	
	[super dealloc];
}

- (void)updateRegion
{		
	// determine a logical center point for this route based on the middle of the lat/lon extents.
	double maxLat = -91;
	double minLat =  91;
	double maxLon = -181;
	double minLon =  181;
	
	for(CLLocation* currentLocation in _points)
	{
		CLLocationCoordinate2D coordinate = currentLocation.coordinate;
		
		if(coordinate.latitude > maxLat)
			maxLat = coordinate.latitude;
		if(coordinate.latitude < minLat)
			minLat = coordinate.latitude;
		if(coordinate.longitude > maxLon)
			maxLon = coordinate.longitude;
		if(coordinate.longitude < minLon)
			minLon = coordinate.longitude; 
	}
    
	_span.latitudeDelta = (maxLat + 90) - (minLat + 90);
	_span.longitudeDelta = (maxLon + 180) - (minLon + 180);
	
	// the center point is the average of the max and mins
	_center.latitude = minLat + _span.latitudeDelta / 2;
	_center.longitude = minLon + _span.longitudeDelta / 2;
}

- (MKCoordinateRegion)region
{
	MKCoordinateRegion region;
	region.center = _center;
	region.span = _span;
	
	return region;
}

- (void)setPoints:(NSArray *)newPoints
{
    [newPoints retain];
    [_points release];
    _points = newPoints;
    
    [self updateRegion];
}

- (NSArray *)points
{
    return _points;
}

@end
