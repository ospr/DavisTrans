//
//  StopViewController.m
//  Unitrans
//
//  Created by Ken Zheng on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StopViewController.h"
#import "StopTimeSegmentedViewController.h"
#import "RouteMapViewController.h"
#import "OverlayHeaderView.h"
#import "Stop.h"
#import "StopTime.h"
#import "Route.h"
#import "NSDate_Extensions.h"
#import "DatePickerController.h"


@implementation StopViewController

@synthesize route;
@synthesize stop;
@synthesize stopTimes;
@synthesize predictions;
@synthesize predictionOperation;
@synthesize selectedDate;

#pragma mark -
#pragma mark Memory management

- (void)dealloc 
{
    // End continuous updates if still running
    if (predictionsContinuousUpdatesRunning)
        [self endContinuousPredictionsUpdates];
    
    [route release];
    [stop release];
	[stopTimes release];
    [predictions release];
    [selectedDate release];

    // Invalidate current expiredStopTimeTimer and release it
    [expiredStopTimeTimer invalidate];
    [expiredStopTimeTimer release];
    
    [predictionOperation release];
    [predictionLoadingIndicatorView release];
    [overlayHeaderView release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"Stop Times"];
	[self setSelectedDate:[[NSDate date] beginningOfDay]]; 
    [self updateStopTimes];
    [self setPredictions:[NSArray array]];
		    
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self beginContinuousPredictionsUpdates];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (predictionsContinuousUpdatesRunning)
        [self endContinuousPredictionsUpdates];
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
    if(section == SectionIndexSelectedDate)
		return 1;
    else if (section == SectionIndexPredictions)
        return 1;
	else if (section == SectionIndexStopTimes)
		return [stopTimes count];
    else
        return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(section == SectionIndexSelectedDate)
		return [NSString stringWithString:@"Schedule for date:"];
    else if (section == SectionIndexPredictions)
        return @"Predictions:";
	else if (section == SectionIndexStopTimes)
		return [stop name];
    else
        return @"";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSString *cellIdentifier = nil;
    
    // Get cellIdentifier based on current section
    switch ([indexPath section]) {
        case SectionIndexSelectedDate: cellIdentifier = @"SelectedDate"; break;
        case SectionIndexPredictions:  cellIdentifier = @"Prediction"; break;
        case SectionIndexStopTimes:    cellIdentifier = @"StopTimes"; break;
    }
    
    UITableViewCell *cell = [[self tableView] dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // If cell was not found create a new one and set it up
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        
        // Set up the cell
        if([indexPath section] == SectionIndexSelectedDate)
        {
            [[cell textLabel] setTextAlignment:UITextAlignmentCenter];
            [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:16]];
        }
        else if ([indexPath section] == SectionIndexPredictions)
        {
            // Add activity indicator to spin while gathering prediction data
            predictionLoadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [cell setAccessoryView:predictionLoadingIndicatorView];
            
            [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:16]];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        else if ([indexPath section] == SectionIndexStopTimes)
        {
            [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:12]];
            [[cell textLabel] setTextAlignment:UITextAlignmentLeft];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
    }

    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == SectionIndexSelectedDate) 
    {
        [[cell textLabel] setText:[self selectedDateString]];
    }
    else if ([indexPath section] == SectionIndexPredictions) 
    {
        [[cell textLabel] setText:[self predictionString]];
    }
	else if ([indexPath section] == SectionIndexStopTimes) 
	{
        StopTime *stopTime = [stopTimes objectAtIndex:[indexPath row]];
        
		NSUInteger seconds = [[stopTime arrivalTime] unsignedIntegerValue];
		NSDate *referenceDate = [NSDate beginningOfToday];
		NSDate *arrivalDate = [[NSDate alloc] initWithTimeInterval:seconds sinceDate:referenceDate];
		
		if([arrivalDate earlierDate:[NSDate date]] == arrivalDate)
			cell.backgroundColor = [UIColor colorWithRed:0.82 green:0.82 blue:0.82 alpha:1.0];
        else
            cell.backgroundColor = [UIColor whiteColor];
		
		[arrivalDate release];
        
        [[cell textLabel] setText:[stopTime arrivalTimeString]];
	}
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if([indexPath section] == SectionIndexSelectedDate)
	{
		DatePickerController *datePickerController = [[DatePickerController alloc] initWithNibName:@"DatePickerController" bundle:nil];
		[datePickerController setStopViewController:self];
		[self presentModalViewController:datePickerController animated:YES];
	}
    else if ([indexPath section] == SectionIndexPredictions)
    {
        // If the continuous updates aren't running, start them up again
        // otherwise just call the single update method
        if (!predictionsContinuousUpdatesRunning)
            [self beginContinuousPredictionsUpdates];
        else
            [self updateStopTimePredictions];
    }
	else if([indexPath section] == SectionIndexStopTimes)
	{
        StopTime *stopTime = [stopTimes objectAtIndex:[indexPath row]];
        
        StopTimeSegmentedViewController *stopTimeViewController = [[StopTimeSegmentedViewController alloc] init];
        [stopTimeViewController setStopTime:stopTime];
		[self.navigationController pushViewController:stopTimeViewController animated:YES];
		[stopTimeViewController release];
	}
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if([indexPath section] == SectionIndexStopTimes)
		return 35.0;
	else
		return [[self tableView] rowHeight];
}

#pragma mark -
#pragma mark Convenience Methods

- (NSString *)selectedDateString
{
    NSDateFormatter *selectedDateFormatter = nil;
    
    if (!selectedDateFormatter) {
        selectedDateFormatter = [[NSDateFormatter alloc] init];
        [selectedDateFormatter setDateStyle:NSDateFormatterFullStyle];
    }
    
    // Set string to "Today" if the date falls on today, otherwise set string using date formatter
    if ([[selectedDate beginningOfDay] isEqualToDate:[[NSDate date] beginningOfDay]])
        return @"Today";
    
    return [selectedDateFormatter stringFromDate:selectedDate];
}

- (NSString *)predictionString
{
    if(loadingPredictions)
        return @"Loading...";
    else if (!predictions)
        return @"Error gathering predictions.";
    else if ([predictions count] > 0)
        return [NSString stringWithFormat:@"%@ minutes", [predictions componentsJoinedByString:@", "]];
    else
        return @"No predictions at this time.";
}

#pragma mark -
#pragma mark Instance methods

- (void)beginContinuousPredictionsUpdates
{
    predictionsContinuousUpdatesRunning = YES;
    
    [self updateStopTimePredictions];
    
    // If we are still updating after the first update, start a timer to updated every 20 seconds
    if (predictionsContinuousUpdatesRunning)
        predictionTimer = [[NSTimer scheduledTimerWithTimeInterval:20.0
                                                            target:self
                                                          selector:@selector(updateStopTimePredictions) 
                                                          userInfo:nil
                                                           repeats:YES] retain];
}

- (void)endContinuousPredictionsUpdates
{
    predictionsContinuousUpdatesRunning = NO;
    
    [predictionTimer invalidate];
    [predictionTimer release];
    predictionTimer = nil;
}

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
    NSDate *referenceDate = [NSDate beginningOfToday];
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
        fireDate = [referenceDate addTimeInterval:24*60*60];
    
    // Add a timer to fire at fireDate
    [expiredStopTimeTimer release]; // Release previous timer
    expiredStopTimeTimer = [[NSTimer alloc] initWithFireDate:fireDate interval:0 target:self selector:@selector(nextStopTimeDidFire:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:expiredStopTimeTimer forMode:NSDefaultRunLoopMode];
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
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [predictionLoadingIndicatorView startAnimating];
    loadingPredictions = YES;
    
    [self setPredictionOperation:[[[PredictionOperation alloc] initWithRouteName:[route shortName] stopTag:[[stop code] stringValue]] autorelease]];
    [predictionOperation setDelegate:self];
    [predictionOperation start];
    [tableView reloadData];
}

#pragma mark PredictionOperation Delegate Methods
#pragma mark -

- (void)predictionOperation:(PredictionOperation *)predictionOperation didFinishWithPredictions:(NSArray *)newPredictions
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [predictionLoadingIndicatorView stopAnimating];
    loadingPredictions = NO;
	
    [self setPredictions:newPredictions];
    [[self tableView] reloadData];
}

- (void)predictionOperation:(PredictionOperation *)predictionOperation didFailWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [predictionLoadingIndicatorView stopAnimating];
    loadingPredictions = NO;
    
    NSString *reason = @"There was an error while loading the predictions. Make sure you are connected to the internet.";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Predictions Loading Error" message:reason
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    [self endContinuousPredictionsUpdates];
    
    [self setPredictions:nil];
    [[self tableView] reloadData];
}

@end

