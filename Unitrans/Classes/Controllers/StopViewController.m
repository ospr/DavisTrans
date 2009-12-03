//
//  StopViewController.m
//  Unitrans
//
//  Created by Ken Zheng on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StopViewController.h"
#import "StopTimeViewController.h"
#import "RouteMapViewController.h"
#import "OverlayHeaderView.h"
#import "Stop.h"
#import "StopTime.h"
#import "Route.h"
#import "NSDate_Extensions.h"
#import "PredictionManager.h"
#import "DatePickerController.h"


@implementation StopViewController

@synthesize route;
@synthesize stop;
@synthesize stopTimes;
@synthesize predictions;
@synthesize selectedDate;
@synthesize selectedDateFormatter;
@synthesize referenceDateFormatter;
@synthesize referenceDateTimeFormatter;
@synthesize isLoadingPrediction;

#pragma mark -
#pragma mark Memory management

- (void)dealloc 
{
    [route release];
    [stop release];
	[stopTimes release];
    [selectedDate release];
    [selectedDateFormatter release];
	[referenceDateFormatter release];
	[referenceDateTimeFormatter release];
    
    [expiredStopTimeTimer invalidate];
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"Stop Times"];
	[self setSelectedDate:[[NSDate date] beginningOfDay]]; 
    [self updateStopTimes];
	
	[self setIsLoadingPrediction:NO];
    
    UIBarButtonItem *mapButtonItem = [[UIBarButtonItem alloc] init];
    [mapButtonItem setTitle:@"Map"];
    [mapButtonItem setTarget:self];
    [mapButtonItem setAction:@selector(showStopInMapAction:)];
    [[self navigationItem] setRightBarButtonItem:mapButtonItem];
    [mapButtonItem release];
	
	[self setSelectedDate:[[NSDate date] beginningOfDay]];
	
	// Initialize NSDateFormatter
	selectedDateFormatter = [[NSDateFormatter alloc] init];
	[selectedDateFormatter setTimeStyle:NSDateFormatterNoStyle];
	[selectedDateFormatter setDateStyle:NSDateFormatterFullStyle];
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[selectedDateFormatter setLocale:usLocale];
	[usLocale release]; 
	
	referenceDateFormatter = [[NSDateFormatter alloc] init];
	[referenceDateFormatter setDateFormat:@"yyyy-MM-dd"];
	referenceDateTimeFormatter = [[NSDateFormatter alloc] init];
	[referenceDateTimeFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
    
    // Create detail overlay view
    CGRect bounds = [[self view] bounds];
    overlayHeaderView = [[OverlayHeaderView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
    [[[overlayHeaderView detailOverlayView] textLabel] setText:[NSString stringWithFormat:@"%@", [stop name]]];
    [[[overlayHeaderView detailOverlayView] detailTextLabel] setText:[stop stopDescription]];
    [[[overlayHeaderView detailOverlayView] imageView] setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@RouteIcon_43.png", [route shortName]]]];
    
    // Create table view (detail overlay's content view)
    UITableView *newTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self setTableView:newTableView];
    [overlayHeaderView setContentView:newTableView];
    [newTableView release];
    
    // Set view
    [self setView:overlayHeaderView];
    
    // Add a timer to fire to update the table when the next stop time expires
    [self addUpdateNextStopTimeTimer];
    
    // Get predictions
    //[self updateStopTimePredictions];
	[NSThread detachNewThreadSelector:@selector(updateStopTimePredictions) toTarget:self withObject:nil];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark UITableView methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if(section == 0)
		return 1;
    else if (section == 1)
        return 1;
	else if (section == 2)
		return [stopTimes count];
    else
        return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(section == 0)
		return [NSString stringWithString:@"Schedule for date:"];
    else if (section == 1)
        return @"Predictions:";
	else if (section == 2)
		return [stop name];
    else
        return @"";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"StopTimeCell";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Set up the cell...
	if([indexPath section] == 0)
	{
        // Set string to "Today" if the date falls on today, otherwise set string using date formatter
        NSString *dateString;
        if ([[selectedDate beginningOfDay] isEqualToDate:[[NSDate date] beginningOfDay]])
            dateString = @"Today";
        else
            dateString =  [selectedDateFormatter stringFromDate:selectedDate];
        
		[[cell textLabel] setText:dateString];
		[[cell textLabel] setTextAlignment:UITextAlignmentCenter];
		[[cell textLabel] setFont:[UIFont boldSystemFontOfSize:16]];
	}
    else if ([indexPath section] == 1)
    {
        NSString *predictionString;
		if(isLoadingPrediction)
		{
			predictionString = @"Loading...";
			[self showActivity:YES atTableViewCell:cell];
		}
		else 
		{
			if (!predictions)
				predictionString = @"Error gathering predictions.";
			else if ([predictions count] > 0)
				predictionString = [NSString stringWithFormat:@"%@ minutes", [predictions componentsJoinedByString:@", "]];
			else
				predictionString = @"No predictions at this time.";
			[self showActivity:NO atTableViewCell:cell];
		}

        [[cell textLabel] setText:predictionString];
        [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:16]];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
	else if ([indexPath section] == 2)
	{
        StopTime *stopTime = [stopTimes objectAtIndex:[indexPath row]];
		[[cell textLabel] setText:[stopTime arrivalTimeString]];
		[[cell textLabel] setFont:[UIFont boldSystemFontOfSize:12]];
		[[cell textLabel] setTextAlignment:UITextAlignmentLeft];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if([indexPath section] == 0)
	{
		DatePickerController *datePickerController = [[DatePickerController alloc] initWithNibName:@"DatePickerController" bundle:nil];
		[datePickerController setStopViewController:self];
		[self presentModalViewController:datePickerController animated:YES];
	}
    else if ([indexPath section] == 1)
    {
        [self updateStopTimePredictions];
    }
	else if([indexPath section] == 2)
	{
        StopTime *stopTime = [stopTimes objectAtIndex:[indexPath row]];
        
		StopTimeViewController *stopTimeViewController = [[StopTimeViewController alloc] init];
        [stopTimeViewController setStopTime:stopTime];
		[self.navigationController pushViewController:stopTimeViewController animated:YES];
		[stopTimeViewController release];
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath section] == 2) 
	{
		NSUInteger seconds = [[[stopTimes objectAtIndex:[indexPath row]] arrivalTime] unsignedIntegerValue];
		NSDate *referenceDate = [referenceDateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ 12:00 am", [referenceDateFormatter stringFromDate:[NSDate date]]]];
		NSDate *arrivalDate = [[NSDate alloc] initWithTimeInterval:seconds sinceDate:referenceDate];
		
		if([arrivalDate earlierDate:[NSDate date]] == arrivalDate)
			cell.backgroundColor = [UIColor colorWithRed:0.82 green:0.82 blue:0.82 alpha:1.0];
        else
            cell.backgroundColor = [UIColor whiteColor];
		
		[arrivalDate release];
	}
    else {
		cell.backgroundColor = [UIColor whiteColor];
	}
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if([indexPath section] == 2)
		return 35.0;
	else
		return [tv rowHeight];
}

#pragma mark -
#pragma mark Instance methods

- (void) updateStopTimes
{
    // Get StopTimes based on route and date and sort
    NSSortDescriptor *stopTimeSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"arrivalTime" ascending:YES] autorelease];
    NSArray *sortedStopTimes = [[stop allStopTimesWithRoute:route onDate:selectedDate] sortedArrayUsingDescriptors:[NSArray arrayWithObject:stopTimeSortDescriptor]];
    [self setStopTimes:sortedStopTimes];
}

- (void) addUpdateNextStopTimeTimer
{
    NSDate *now = [NSDate date];
    NSDate *referenceDate = [referenceDateTimeFormatter dateFromString:[NSString stringWithFormat:@"%@ 12:00 am", [referenceDateFormatter stringFromDate:now]]];
    NSDate *arrivalDate;
    NSDate *fireDate = nil;
    
    // Loop through all stop times and find the first time that is later than now
    for (StopTime *stopTime in stopTimes) {
        NSUInteger seconds = [[stopTime arrivalTime] unsignedIntegerValue];
        arrivalDate = [[[NSDate alloc] initWithTimeInterval:seconds sinceDate:referenceDate] autorelease];
        
        if([arrivalDate laterDate:now] == arrivalDate) {
            fireDate = arrivalDate;
            break;
        }
    }
    
    // If there was no arrivalDate later than now, we fire and update at 12am
    if (!fireDate)
        fireDate = referenceDate;
    
    // Add a timer to fire at fireDate
    expiredStopTimeTimer = [[NSTimer alloc] initWithFireDate:fireDate interval:0 target:self selector:@selector(nextStopTimeDidFire:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:expiredStopTimeTimer forMode:NSDefaultRunLoopMode];
    [expiredStopTimeTimer release];
}

- (void) nextStopTimeDidFire:(NSTimer *)timer
{
    // Reload table to update the greyed out stop times
    [[self tableView] reloadData];
    
    // Add the next stop time timer
    [self addUpdateNextStopTimeTimer];
}

- (void) updateStopTimePredictions
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSError *error;
	[self setIsLoadingPrediction:YES];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	PredictionManager *predictionManager = [[PredictionManager alloc] init];
	NSArray *newPredictions = [predictionManager retrievePredictionInMinutesForRoute:route atStop:stop error:&error];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (!newPredictions) {
        NSString *reason = @"There was an error while loading the predictions. Make sure you are connected to the internet.";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Predictions Loading Error" message:reason
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
	
    [self setPredictions:newPredictions];
    [[self tableView] reloadData];
	[self setIsLoadingPrediction:NO];
	[predictionManager release];
	[pool release];
}

- (void) showActivity:(BOOL)show atTableViewCell:(UITableViewCell *)tableviewCell;
{
	if(show)
	{
		UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[activityIndicatorView startAnimating];
		[tableviewCell setAccessoryView:activityIndicatorView];
		[activityIndicatorView release];
	}
	else 
	{
		[tableviewCell setAccessoryView:nil];
	}
}

#pragma mark -
#pragma mark IBAction methods

- (IBAction)showStopInMapAction:(id)action
{
    RouteMapViewController *routeMapViewController = [[RouteMapViewController alloc] initWithNibName:@"RouteMapView" bundle:nil];
    [routeMapViewController setRoute:route];
    [routeMapViewController setStop:stop];
    [[self navigationController] pushViewController:routeMapViewController animated:YES];
    [routeMapViewController release];
}

@end

