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
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad 
{
    [super viewDidLoad];

    [self setTitle:@"Stop Times"];
	[self setSelectedDate:[[NSDate date] beginningOfDay]]; 
	[self setShowExpiredStopTimes:NO];
    [self updateStopTimes];
    
    // Create table view
    CGRect tableViewFrame = CGRectMake(0, 0, [[self view] frame].size.width, [[self view] frame].size.height);
    UITableView *newTableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStyleGrouped];
    [self setTableView:newTableView];
    
    // Set view
    [self setView:newTableView];
    [newTableView release];
    
    // Add a timer to fire to update the table when the next stop time expires
    [self addUpdateNextStopTimeTimer];
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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // If the view is no longer on the stack: invalidate current expiredStopTimeTimer and release it
    if(![self navigationController]) {
        [expiredStopTimeTimer invalidate];
        [expiredStopTimeTimer release];
        expiredStopTimeTimer = nil;
    }
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
        if ([self shouldShowNoMoreScheduledArrivals])
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
            if ([indexPath row] == 0)
                cellIdentifier = @"ExpiredCell";
            else if ([self shouldShowNoMoreScheduledArrivals])
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
            if ([allStopTimes count] == 0)
                [[cell textLabel] setText:@"No scheduled bus service."];
			else if (showExpiredStopTimes) 
				[[cell textLabel] setText:@"Hide expired times..."];
			else 
				[[cell textLabel] setText:@"Show expired times..."];
		}
        else if ([self shouldShowNoMoreScheduledArrivals])
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
		[delegate stopViewController:self showDatePickerWithDate:selectedDate];
		[[self tableView] setAllowsSelection:NO];
	}
	else if([indexPath section] == SectionIndexStopTimes)
	{
		if ([indexPath row] == 0) 
		{
			[self setShowExpiredStopTimes:!showExpiredStopTimes];
			[self filterExpiredStopTimes];
			[self updateActiveStopTimes];
			[[self tableView] reloadData];
		}
		else if ([self shouldShowNoMoreScheduledArrivals])
		{
			[[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
		}
		else
		{
			StopTime *stopTime = [activeStopTimes objectAtIndex:[indexPath row]-1];
			StopTimeSegmentedViewController *stopTimeSegmentedViewController = [[StopTimeSegmentedViewController alloc] init];
            [stopTimeSegmentedViewController setRoute:route];
			[stopTimeSegmentedViewController setStopTime:stopTime];
            
			[self.navigationController pushViewController:stopTimeSegmentedViewController animated:YES];
			[stopTimeSegmentedViewController release];
		}
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

- (BOOL)shouldShowNoMoreScheduledArrivals
{
    return !showExpiredStopTimes && [currentStopTimes count] == 0 && [allStopTimes count] != 0;
}

#pragma mark -
#pragma mark Instance Methods

- (void) updateStopTimes
{
    // Get StopTimes based on route and date and sort
    NSSortDescriptor *stopTimeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"arrivalTime" ascending:YES];
    NSArray *sortedStopTimes = [[stop allStopTimesWithRoute:route onDate:selectedDate] sortedArrayUsingDescriptors:[NSArray arrayWithObject:stopTimeSortDescriptor]];
	[stopTimeSortDescriptor release];
    [self setAllStopTimes:sortedStopTimes];
	[self filterExpiredStopTimes];
	[self updateActiveStopTimes];
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

- (void) addUpdateNextStopTimeTimer
{
    NSDate *now = [NSDate date];
    NSDate *referenceDate = [NSDate beginningOfToday];
    NSDate *arrivalDate;
    NSDate *fireDate = nil;
    
    // Loop through all stop times and find the first time that is later than now
    for (StopTime *stopTime in activeStopTimes) {
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

- (void) updateActiveStopTimes
{
	if (showExpiredStopTimes)
		[self setActiveStopTimes:allStopTimes];
	else 
		[self setActiveStopTimes:currentStopTimes];
}

- (void) nextStopTimeDidFire:(NSTimer *)timer
{
    // Reload table to update the greyed out stop times
    [[self tableView] reloadData];
    
    // Add the next stop time timer
    [self addUpdateNextStopTimeTimer];
}

- (void) dateChangedTo:(NSDate *)newDate
{
	if(newDate)
	{
		[self setSelectedDate:newDate];
		[self updateStopTimes];
	}
	
	[[self tableView] setAllowsSelection:YES];
	
	// Deslect date table cell
	NSUInteger dateIndexPath[] = {0, 0};
	[[self tableView] deselectRowAtIndexPath:[NSIndexPath indexPathWithIndexes:dateIndexPath length:2] animated:YES];
	[[self tableView] reloadData];
}

@end

