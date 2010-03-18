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
#import "Stop.h"
#import "StopTime.h"
#import "Route.h"
#import "NSDate_Extensions.h"
#import "UIColor_Extensions.h"

//CGFloat kPredictionViewHeight = 50.0;

@implementation StopViewController

@synthesize route;
@synthesize stop;
@synthesize activeStopTimes;
@synthesize allStopTimes;
@synthesize currentStopTimes;
@synthesize showExpiredStopTimes;
@synthesize selectedDate;
@synthesize delegate;

#pragma mark -
#pragma mark Init Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self setSegmentTransition:UIViewAnimationTransitionFlipFromLeft];
    }
    
    return self;
}

- (void)dealloc 
{
    [route release];
    [stop release];
	[activeStopTimes release];
	[allStopTimes release];
	[currentStopTimes release];
    [selectedDate release];

    // Invalidate current expiredStopTimeTimer and release it
    [expiredStopTimeTimer invalidate];
    [expiredStopTimeTimer release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad 
{
    [super viewDidLoad];

    [self setTitle:@"Stop Times"];
	[self setShowExpiredStopTimes:NO];
    
    // Create table view
    CGRect tableViewFrame = CGRectMake(0, 0, [[self view] frame].size.width, [[self view] frame].size.height);
    UITableView *newTableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStyleGrouped];
    [self setTableView:newTableView];
    
    // Set view
    [self setView:newTableView];
    [newTableView release];
    
    // Set default date (Today)
    [self changeScheduleDateTo:[[NSDate date] beginningOfDay]];
}

- (void)viewDidUnload 
{
	[super viewDidUnload];
	[self setRoute:nil];
	[self setStop:nil];
	[self setActiveStopTimes:nil];
	[self setAllStopTimes:nil];
	[self setCurrentStopTimes:nil];
	[self setSelectedDate:nil];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark UITableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 2;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if(section == SectionIndexSelectedDate)
		return 1;
	else if (section == SectionIndexStopTimes) 
	{
        if ([self shouldShowNoMoreScheduledStops])
            return 1 + 1; // 1 for the show/hide expired times and 1 for "no more buses" cell
        else 
            return [activeStopTimes count] + 1; // +1 for show/hide expired times cell
	}
    else
        return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(section == SectionIndexSelectedDate)
		return @"Schedule Date";
	else if (section == SectionIndexStopTimes)
		return @"Scheduled Stop Times";
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
        case SectionIndexStopTimes:    
            if ([indexPath row] == 0) {
                if ([self noScheduledService])
                    cellIdentifier = @"NoService";
                else
                    cellIdentifier = @"ExpiredCell";
            }
            else if ([self shouldShowNoMoreScheduledStops])
                cellIdentifier = @"NoBuses";
            else
                cellIdentifier = @"StopTimes";
            break;
    }
    
    UITableViewCell *cell = [[self tableView] dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // If cell was not found create a new one and set it up
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        
        // Set up the cell
        if([cellIdentifier isEqualToString:@"SelectedDate"])
        {
            [[cell textLabel] setTextAlignment:UITextAlignmentCenter];
            [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:16]];
        }
        else if ([cellIdentifier isEqualToString:@"ExpiredCell"])
        {
            [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:14]];
            [[cell textLabel] setTextAlignment:UITextAlignmentLeft];
            [[cell textLabel] setTextColor:[UIColor blueColor]];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        else if ([cellIdentifier isEqualToString:@"NoService"])
        {
            [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:14]];
            [[cell textLabel] setTextAlignment:UITextAlignmentLeft];
            [[cell textLabel] setTextColor:[UIColor blueColor]];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        else if ([cellIdentifier isEqualToString:@"NoBuses"])
        {
            [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:12]];
            [cell setBackgroundColor:[UIColor extraLightGrayColor]];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        else if ([cellIdentifier isEqualToString:@"StopTimes"])
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
	else if ([indexPath section] == SectionIndexStopTimes) 
	{
		if ([indexPath row] == 0) 
		{
            if ([self noScheduledService])
                [[cell textLabel] setText:@"No scheduled bus service."];
			else if (showExpiredStopTimes) 
				[[cell textLabel] setText:@"Hide expired times..."];
			else 
				[[cell textLabel] setText:@"Show expired times..."];
		}
        else if ([self shouldShowNoMoreScheduledStops])
        {
            [[cell textLabel] setText:@"No more scheduled stops at this time."];
        }
		else
        {
			StopTime *stopTime = [activeStopTimes objectAtIndex:[indexPath row]-1]; // -1 for show/hide expired times cell
			NSDate *arrivalDate = [[NSDate alloc] initWithTimeInterval:[[stopTime arrivalTime] unsignedIntegerValue] sinceDate:[selectedDate beginningOfDay]];
			
            // Cells with expired times are colored grey, non-expired cells are colored white
			if([arrivalDate earlierDate:[NSDate date]] == arrivalDate)
				[cell setBackgroundColor:[UIColor extraLightGrayColor]];
			else
				[cell setBackgroundColor:[UIColor whiteColor]];
			
			[arrivalDate release];
			[[cell textLabel] setText:[stopTime arrivalTimeString]];
		}
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if([indexPath section] == SectionIndexSelectedDate)
	{
        [self chooseNewScheduleDate];
	}
	else if([indexPath section] == SectionIndexStopTimes)
	{
		if ([indexPath row] == 0) 
		{
            [self toggleExpiredStopTimes];
		}
		else
		{
			StopTime *stopTime = [activeStopTimes objectAtIndex:[indexPath row]-1];
			StopTimeSegmentedViewController *stopTimeSegmentedViewController = [[StopTimeSegmentedViewController alloc] init];
            [stopTimeSegmentedViewController setRoute:route];
			[stopTimeSegmentedViewController setStopTime:stopTime];
            
			[[self navigationController] pushViewController:stopTimeSegmentedViewController animated:YES];
			[stopTimeSegmentedViewController release];
		}
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == SectionIndexStopTimes) 
    {
        // Don't allow the no more service to be selected
        if ([indexPath row] == 0 && [self noScheduledService])
            return nil;
        // Don't allow the no more scheduled stops to be selected
        else if ([indexPath row] == 1 && [self shouldShowNoMoreScheduledStops])
            return nil;
    }
    
    return indexPath;
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
    static NSDateFormatter *selectedDateFormatter = nil;
    
    if (!selectedDateFormatter) {
        selectedDateFormatter = [[NSDateFormatter alloc] init];
        [selectedDateFormatter setDateStyle:NSDateFormatterFullStyle];
    }
    
    // Set string to "Today" if the date falls on today, otherwise set string using date formatter
    if ([[selectedDate beginningOfDay] isEqualToDate:[[NSDate date] beginningOfDay]])
        return @"Today";
    
    return [selectedDateFormatter stringFromDate:selectedDate];
}

- (BOOL)shouldShowNoMoreScheduledStops
{
    // TODO: test 10:22 in Stop expiring and reloading correctly
    return !showExpiredStopTimes && [activeStopTimes count] == 0 && ![self noScheduledService];
}

- (BOOL)noScheduledService
{
    return ([allStopTimes count] == 0);
}

#pragma mark -
#pragma mark NextDay Timer Methods

- (void)startNextDayTimer
{
    // Stop previous nextDayTimer
    [self stopNextDayTimer];
    
    // Get 12AM tomorrow's date
    NSDate *nextDay = [NSDate beginningOfTomorrow];
    
    // Set timer to fire at new day
    nextDayTimer = [[NSTimer alloc] initWithFireDate:nextDay interval:0 target:self selector:@selector(nextDayTimerDidFire:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:nextDayTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopNextDayTimer
{
    [nextDayTimer invalidate];
    [nextDayTimer release];
    nextDayTimer = nil;
}

- (void)nextDayTimerDidFire:(NSTimer *)timer
{
    // Filter all stop times to remove "expired" status
    [self filterExpiredStopTimes];
    
    // Index path for schedule's selected date
    NSIndexPath *dateIndexPath = [NSIndexPath indexPathForRow:0 inSection:SectionIndexSelectedDate];
    
    // Reload date cell to reflect date change
    [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:dateIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    // Start next day and expired stopTime timer
    [self startNextDayTimer];
    [self startExpiredStopTimeTimer];
}

#pragma mark -
#pragma mark ExpiredStopTime Timer Methods

- (void) startExpiredStopTimeTimer
{
    NSDate *now = [NSDate date];
    NSDate *referenceDate = [NSDate beginningOfToday];
    NSDate *arrivalDate;
    NSDate *nextExpiredDate = nil;
    
    // Stop previous expired timer
    [self stopExpiredStopTimeTimer];
    
    // Loop through all stop times and find the first time that is later than now
    for (StopTime *stopTime in activeStopTimes) {
        NSUInteger seconds = [[stopTime arrivalTime] unsignedIntegerValue];
        arrivalDate = [[[NSDate alloc] initWithTimeInterval:seconds sinceDate:referenceDate] autorelease];
        
        if([arrivalDate laterDate:now] == arrivalDate) {
            nextExpiredDate = arrivalDate;
            break;
        }
    }
    
    // If there is no next expired date today, then don't start a new timer
    // We start the expired timer again in nextDayTimerDidFire:
    if (!nextExpiredDate)
        return;
    
    // Add a timer to fire at fireDate
    expiredStopTimeTimer = [[NSTimer alloc] initWithFireDate:nextExpiredDate interval:0 target:self selector:@selector(nextExpiredStopTimeDidFire:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:expiredStopTimeTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopExpiredStopTimeTimer
{
    [expiredStopTimeTimer invalidate];
    [expiredStopTimeTimer release];
    expiredStopTimeTimer = nil;
}

- (void)nextExpiredStopTimeDidFire:(NSTimer *)timer
{
    [self filterExpiredStopTimes];
    
    // Get index of cell to animated to expired
    NSInteger cellIndex = [activeStopTimes count] - [currentStopTimes count] - 1;
    
    // Reload table to update the greyed out stop times (+1 for the show/hide cell)
    // TODO 3.2: change animationTop to animationMiddle
    [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:cellIndex+1 inSection:SectionIndexStopTimes]] withRowAnimation:UITableViewRowAnimationTop];
    
    // Start the next expired stop time timer
    [self startExpiredStopTimeTimer];
}

#pragma mark -
#pragma mark Instance Methods

- (void)updateStopTimes
{
    // Get StopTimes based on route and date and sort
    NSSortDescriptor *stopTimeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"arrivalTime" ascending:YES];
    NSArray *sortedStopTimes = [[stop allStopTimesWithRoute:route onDate:selectedDate] sortedArrayUsingDescriptors:[NSArray arrayWithObject:stopTimeSortDescriptor]];
	[stopTimeSortDescriptor release];
    [self setAllStopTimes:sortedStopTimes];
	[self filterExpiredStopTimes];
	[self updateActiveStopTimes];
}

- (void)toggleExpiredStopTimes
{
    BOOL wasShowingNoMoreScheduledArrivals = [self shouldShowNoMoreScheduledStops];
    
    [self setShowExpiredStopTimes:!showExpiredStopTimes];
            
    // Insert stop times (show expired times)
    if (showExpiredStopTimes) {
        // Number of rows to insert
        NSUInteger insertionCount = [allStopTimes count] - [activeStopTimes count];
        
        NSMutableArray *insertIndexPaths = [NSMutableArray array];
        for (int i = 0; i < insertionCount ; i++)
            [insertIndexPaths addObject:[NSIndexPath indexPathForRow:i+1 inSection:SectionIndexStopTimes]]; // +1 for show/hide cell
        
        [self filterExpiredStopTimes];
        [self updateActiveStopTimes];
        
        // Begin animation block
        [[self tableView] beginUpdates];
            // If all stopTimes have expired, then delete the "No more stop times" cell
            if (wasShowingNoMoreScheduledArrivals)
                [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:SectionIndexStopTimes]] withRowAnimation:UITableViewRowAnimationTop];
            [[self tableView] insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
        

        [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:SectionIndexStopTimes]] withRowAnimation:UITableViewRowAnimationNone];
        [[self tableView] deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:SectionIndexStopTimes] animated:YES];
        
        [[self tableView] endUpdates];
    }
    // Remove stop times (hide expired times)
    else {
        // Number of rows to delete
        NSUInteger deletionCount = [allStopTimes count] - [currentStopTimes count];
        
        NSMutableArray *insertIndexPaths = [NSMutableArray array];
        for (int i = 0; i < deletionCount ; i++)
            [insertIndexPaths addObject:[NSIndexPath indexPathForRow:i+1 inSection:SectionIndexStopTimes]]; // +1 for show/hide cell
        
        [self filterExpiredStopTimes];
        [self updateActiveStopTimes];
        
        // Begin animation block
        [[self tableView] beginUpdates];
            [[self tableView] deleteRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
            // If all stopTimes have expired, then insert the "No more stop times" cell
            if ([self shouldShowNoMoreScheduledStops])
                [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:SectionIndexStopTimes]] withRowAnimation:UITableViewRowAnimationTop];
        
        
            [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:SectionIndexStopTimes]] withRowAnimation:UITableViewRowAnimationNone];
        [[self tableView] deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:SectionIndexStopTimes] animated:YES];
        [[self tableView] endUpdates];
    }
}

- (void) filterExpiredStopTimes
{    
	// Filter out expired times
	NSInteger index = 0;
	
	for (index = 0; index < [allStopTimes count]; index++) 
	{
		NSDate *arrivalDate = [[NSDate alloc] initWithTimeInterval:[[[allStopTimes objectAtIndex:index] arrivalTime] unsignedIntValue] sinceDate:[selectedDate beginningOfDay]];
		if([arrivalDate earlierDate:[NSDate date]] != arrivalDate)
		{
			[arrivalDate release];
			break;
		}
		[arrivalDate release];
	}
	
	NSRange range = NSMakeRange(index, [allStopTimes count] - index);
	[self setCurrentStopTimes:[allStopTimes objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]]];	
}

- (void) updateActiveStopTimes
{
	if (showExpiredStopTimes)
		[self setActiveStopTimes:allStopTimes];
	else 
		[self setActiveStopTimes:currentStopTimes];
}

#pragma mark -
#pragma mark Change Schedule Date Methods

- (void)changeScheduleDateTo:(NSDate *)newSelectedDate
{
    NSDate *todayBeginning = [NSDate beginningOfToday];
    NSDate *tomorrowBeginning = [NSDate beginningOfTomorrow];
    NSDate *newSelectedDateBeginning = [newSelectedDate beginningOfDay];
    
    [self setSelectedDate:newSelectedDateBeginning];
    [self updateStopTimes];
    
    // If new date is today or tomorrow, add a 12am timer (if today, the date will change to full date, if tomorrow, the date will change to Today)
    // Else invalidate 12am timer if there is one already (yesterday will stay full date, and dates after tomorrow will stay full dates)
    if ([newSelectedDateBeginning isEqualToDate:todayBeginning] || [newSelectedDateBeginning isEqualToDate:tomorrowBeginning])
    {
        [self startNextDayTimer];
    }
    else
    {
        [self stopNextDayTimer];
    }
    
    // If new date is today, add nextStopTime timer (we want to animate changes to the table only when the date is today)
    // Else invalidate current nextStopTime timer
    if ([newSelectedDateBeginning isEqualToDate:todayBeginning])
    {
        [self startExpiredStopTimeTimer];
    }
    else
    {
        [self stopExpiredStopTimeTimer];
    }
    
    [[self tableView] reloadData];
}

- (void)chooseNewScheduleDateDidEndWithDate:(NSDate *)newDate
{
	if(newDate)
	{
		[self changeScheduleDateTo:newDate];
	}
	
	[[self tableView] setAllowsSelection:YES];
	
	// Deselect date table cell
	NSUInteger dateCellIndexPath[] = {0, 0};
	[[self tableView] deselectRowAtIndexPath:[NSIndexPath indexPathWithIndexes:dateCellIndexPath length:2] animated:YES];
	[[self tableView] reloadData];
}

- (void)chooseNewScheduleDate
{
    [delegate stopViewController:self showDatePickerWithDate:selectedDate];
    [[self tableView] setAllowsSelection:NO];
}

@end
