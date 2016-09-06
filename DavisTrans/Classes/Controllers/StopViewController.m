//
//  StopViewController.m
//  DavisTrans
//
//  Created by Ken Zheng on 11/2/09.
//  Copyright 2009 Kip Nicol & Ken Zheng
//

#import "StopViewController.h"
#import "StopTimeSegmentedViewController.h"
#import "RouteMapViewController.h"
#import "FavoritesController.h"
#import "Stop.h"
#import "StopTime.h"
#import "Route.h"
#import "Calendar.h"
#import "NSDate_Extensions.h"
#import "UIColor_Extensions.h"

#import "DatabaseManager.h"

//CGFloat kPredictionViewHeight = 50.0;

@implementation StopViewController

@synthesize route;
@synthesize stop;
@synthesize hasScheduledStopTimesButNoDepartingStopTimes;
@synthesize activeStopTimes;
@synthesize allDepartingStopTimes;
@synthesize currentStopTimes;
@synthesize showExpiredStopTimes;
@dynamic isFavorite;
@synthesize selectedDate;
@synthesize temporaryDate;
@synthesize delegate;

#pragma mark -
#pragma mark Init Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self setSegmentTransition:UIViewAnimationTransitionFlipFromLeft];
        
        // Observe when the application becomes active, so we can update the expired times
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(applicationDidBecomeActive:) 
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        // Get notifications when favorites change so we can reload the table
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(favoritesChanged:)
                                                     name:@"FavoritesChanged" object:nil];
    }
    
    return self;
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [route release];
    [stop release];
	[activeStopTimes release];
	[allDepartingStopTimes release];
	[currentStopTimes release];
    [selectedDate release];

    [expiredStopTimeTimer release];
    [nextDayTimer release];
    
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
    
    // Set default date (date closest to Today in current service)
    NSDate *defaultDate = [NSDate beginningOfToday];
    if ([[(Calendar *)[[[route trips] anyObject] calendar] startDate] earlierDate:defaultDate] == defaultDate)
    {
        defaultDate = [(Calendar *)[[[route trips] anyObject] calendar] startDate];
    }    
    else if ([[(Calendar *)[[[route trips] anyObject] calendar] endDate] laterDate:defaultDate] == defaultDate) 
    {
        defaultDate = [(Calendar *)[[[route trips] anyObject] calendar] endDate];
    }   
    [self changeScheduleDateTo:defaultDate];
	
    // Create favorites button
	UIBarButtonItem *favoritesButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"FavoriteStarNoFill.png"] 
																		style:UIBarButtonItemStyleBordered 
																	   target:self 
																	   action:@selector(favoritesButtonPressed:)];
    [favoritesButton setAccessibilityLabel:@"Favorite"];
    // If stop is a favorite, then set to filled star
	if([self isFavorite])
		[favoritesButton setImage:[UIImage imageNamed:@"FavoriteStarFilled.png"]];
	
    // Add favorites button
	[self setRightSegmentedBarButtonItem:favoritesButton];
	[favoritesButton release];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateFavoritesButton];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (![self navigationController]) {
        [self stopNextDayTimer];
        [self stopExpiredStopTimeTimer];
    }
}

- (void)viewDidUnload 
{
	[super viewDidUnload];
	[self setRoute:nil];
	[self setStop:nil];
	[self setActiveStopTimes:nil];
	[self setAllDepartingStopTimes:nil];
	[self setCurrentStopTimes:nil];
	[self setSelectedDate:nil];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    // Filter and reload table data when application becomes active
    // so that if device went to sleep we can update the expired times here
    [self filterExpiredStopTimes];
    [[self tableView] reloadData];
}

#pragma mark -
#pragma mark UITableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    // Only show the date cell when choosing a new schedule date
    if (chooseNewScheduleDateMode)
        return 1;
    
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
    // HACK: Using DataBaseMan here to get the current service name
	if(section == SectionIndexSelectedDate)
    {
        NSString *serviceName = [[[DatabaseManager sharedDatabaseManager] currentService] longName];
        return [NSString stringWithFormat:@"Schedule Date for %@", serviceName];
    }
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
            [[cell textLabel] setTextAlignment:NSTextAlignmentCenter];
            [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:16]];
            [[cell textLabel] setTextColor:[[[self navigationController] navigationBar] tintColor]];
        }
        else if ([cellIdentifier isEqualToString:@"ExpiredCell"])
        {
            [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:14]];
            [[cell textLabel] setTextAlignment:NSTextAlignmentLeft];
            [[cell textLabel] setTextColor:[[[self navigationController] navigationBar] tintColor]];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        else if ([cellIdentifier isEqualToString:@"NoService"])
        {
            [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:14]];
            [[cell textLabel] setTextAlignment:NSTextAlignmentLeft];
            [[cell textLabel] setTextColor:[UIColor grayColor]];
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
            [[cell textLabel] setTextAlignment:NSTextAlignmentLeft];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
    }

    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == SectionIndexSelectedDate) 
    {
        if (!chooseNewScheduleDateMode)
            [[cell textLabel] setText:[self stringForDate:selectedDate]];
        else 
            [[cell textLabel] setText:[self stringForDate:temporaryDate]];
    }
	else if ([indexPath section] == SectionIndexStopTimes) 
	{
		if ([indexPath row] == 0) 
		{
            if ([self hasScheduledStopTimesButNoDepartingStopTimes])
                [[cell textLabel] setText:@"No departing trips."];
            else if ([self noScheduledService])
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
			
            // Cells with expired times are colored grey, non-expired cells are colored white
            if ([currentStopTimes containsObject:stopTime])
				[cell setBackgroundColor:[UIColor whiteColor]];
			else
				[cell setBackgroundColor:[UIColor extraLightGrayColor]];
			
			[[cell textLabel] setText:[stopTime arrivalTimeString]];
		}
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if([indexPath section] == SectionIndexSelectedDate)
	{
        if (!chooseNewScheduleDateMode)
            [self chooseNewScheduleDate];
        else
            [delegate dismissDatePickerWithDate:[self temporaryDate]];
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

- (NSString *)stringForDate:(NSDate *)date
{
    static NSDateFormatter *selectedDateFormatter = nil;
    
    if (!selectedDateFormatter) {
        selectedDateFormatter = [[NSDateFormatter alloc] init];
        [selectedDateFormatter setDateStyle:NSDateFormatterFullStyle];
    }
    
    // Set string to "Today" if the date falls on today, otherwise set string using date formatter
    if ([[date beginningOfDay] isEqualToDate:[[NSDate date] beginningOfDay]])
        return @"Today";
    
    return [selectedDateFormatter stringFromDate:date];
}

- (BOOL)shouldShowNoMoreScheduledStops
{
    return !showExpiredStopTimes && [activeStopTimes count] == 0 && ![self noScheduledService] && ![self hasScheduledStopTimesButNoDepartingStopTimes];
}

- (BOOL)noScheduledService
{
    return (![self hasScheduledStopTimesButNoDepartingStopTimes] && ([allDepartingStopTimes count] == 0));
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
    // Only filter and reload cell if the user isn't currently selecting a new date
    if (!chooseNewScheduleDateMode) {
        // Filter all stop times to remove "expired" status
        [self filterExpiredStopTimes];
        
        // Index path for schedule's selected date
        NSIndexPath *dateIndexPath = [NSIndexPath indexPathForRow:0 inSection:SectionIndexSelectedDate];
        
        // Reload date cell to reflect date change
        [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:dateIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
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
    // Only reload stop time row when the user isn't currently selecting a new date
    if (!chooseNewScheduleDateMode) {
        [self filterExpiredStopTimes];
        
        // Get index of cell to animated to expired
        NSInteger cellIndex = [activeStopTimes count] - [currentStopTimes count] - 1;
        
        // Reload table to update the greyed out stop times (+1 for the show/hide cell)
        // TODO 3.2: change animationTop to animationMiddle
        [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:cellIndex+1 inSection:SectionIndexStopTimes]] withRowAnimation:UITableViewRowAnimationBottom];
    }    
    
    // Start the next expired stop time timer
    [self startExpiredStopTimeTimer];
}

#pragma mark -
#pragma mark Updating StopTimes Methods

- (void)updateStopTimes
{
    // Determine departing stops, sort stopTimes, filter expired stopTimes, update active stopTimes
    [self determineIfStopHasScheduledStopTimesButNoDepartingStopTimes];
    [self sortStopTimes];
	[self filterExpiredStopTimes];
	[self updateActiveStopTimes];
}

- (void)determineIfStopHasScheduledStopTimesButNoDepartingStopTimes
{
    NSArray *allStopTimes = [stop allStopTimesWithRoute:route onDate:[self selectedDate]];
    NSArray *departingStopTimes = [stop allDepartingStopTimesWithRoute:route onDate:[self selectedDate]];
    
    NSUInteger allStopTimesCount = [allStopTimes count];
    NSUInteger allDepartingStopTimesCount = [departingStopTimes count];
    
    // There are no departing stop times if there are 
    [self setHasScheduledStopTimesButNoDepartingStopTimes:((allStopTimesCount > 0) && (allDepartingStopTimesCount == 0))];
}

- (void)sortStopTimes
{
    // TODO: use new method for this
    NSSortDescriptor *stopTimeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"arrivalTime" ascending:YES];
    NSArray *sortedStopTimes = [[stop allDepartingStopTimesWithRoute:route onDate:selectedDate] sortedArrayUsingDescriptors:[NSArray arrayWithObject:stopTimeSortDescriptor]];
	[stopTimeSortDescriptor release];
    [self setAllDepartingStopTimes:sortedStopTimes];
}

- (void)filterExpiredStopTimes
{    
	// Filter out expired times
	NSInteger index = 0;
	
	for (index = 0; index < [allDepartingStopTimes count]; index++) 
	{
		NSDate *arrivalDate = [[NSDate alloc] initWithTimeInterval:[[[allDepartingStopTimes objectAtIndex:index] arrivalTime] unsignedIntValue] sinceDate:[selectedDate beginningOfDay]];
		if([arrivalDate earlierDate:[NSDate date]] != arrivalDate)
		{
			[arrivalDate release];
			break;
		}
		[arrivalDate release];
	}
	
	NSRange range = NSMakeRange(index, [allDepartingStopTimes count] - index);
	[self setCurrentStopTimes:[allDepartingStopTimes objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]]];	
}

- (void)updateActiveStopTimes
{
	if (showExpiredStopTimes)
		[self setActiveStopTimes:allDepartingStopTimes];
	else 
		[self setActiveStopTimes:currentStopTimes];
}

- (void)toggleExpiredStopTimes
{
    BOOL wasShowingNoMoreScheduledArrivals = [self shouldShowNoMoreScheduledStops];
    
    [self setShowExpiredStopTimes:!showExpiredStopTimes];
            
    // Insert stop times (show expired times)
    if (showExpiredStopTimes) {
        // Number of rows to insert
        NSUInteger insertionCount = [allDepartingStopTimes count] - [activeStopTimes count];
        
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
            [[self tableView] insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
        

        [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:SectionIndexStopTimes]] withRowAnimation:UITableViewRowAnimationNone];
        [[self tableView] deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:SectionIndexStopTimes] animated:YES];
        
        [[self tableView] endUpdates];
    }
    // Remove stop times (hide expired times)
    else {
        // Number of rows to delete
        NSUInteger deletionCount = [allDepartingStopTimes count] - [currentStopTimes count];
        
        NSMutableArray *insertIndexPaths = [NSMutableArray array];
        for (int i = 0; i < deletionCount ; i++)
            [insertIndexPaths addObject:[NSIndexPath indexPathForRow:i+1 inSection:SectionIndexStopTimes]]; // +1 for show/hide cell
        
        [self filterExpiredStopTimes];
        [self updateActiveStopTimes];
        
        // Begin animation block
        [[self tableView] beginUpdates];
            [[self tableView] deleteRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
            // If all stopTimes have expired, then insert the "No more stop times" cell
            if ([self shouldShowNoMoreScheduledStops])
                [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:SectionIndexStopTimes]] withRowAnimation:UITableViewRowAnimationTop];
        
        
            [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:SectionIndexStopTimes]] withRowAnimation:UITableViewRowAnimationNone];
        [[self tableView] deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:SectionIndexStopTimes] animated:YES];
        [[self tableView] endUpdates];
    }
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
}

- (void)chooseNewScheduleDateDidEndWithDate:(NSDate *)newDate
{
    NSDate *today = [NSDate beginningOfToday];
    chooseNewScheduleDateMode = NO;
    
    // If the newDate isn't nil and both the original date and newDate aren't Today,
    // then change the scheduled date
	if (newDate && !([[selectedDate beginningOfDay] isEqualToDate:today] && [[newDate beginningOfDay] isEqualToDate:today]))
	{
		[self changeScheduleDateTo:newDate];
	}

    // Allow user to scroll table again
    [[self tableView] setScrollEnabled:YES];
    
    // Reload and deselect date cell and reinsert stopTimes section
    [[self tableView] beginUpdates];
    [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:SectionIndexSelectedDate]] withRowAnimation:UITableViewRowAnimationNone];
    [[self tableView] deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:SectionIndexSelectedDate] animated:YES];
    [[self tableView] insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    [[self tableView] endUpdates];
}

- (void)chooseNewScheduleDate
{    
    chooseNewScheduleDateMode = YES;
    
    // Allow user to scroll table, then deselect date cell, then delete stopTimes section to clean up UI
    [[self tableView] setScrollEnabled:NO];
    [[self tableView] deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:SectionIndexSelectedDate] animated:YES];
    [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    
    // Tell stopSegmentedViewController to show date picker
    [delegate stopViewController:self showDatePickerWithDate:selectedDate];
}

- (void)datePickerValueDidChangeWithDate:(NSDate *)newDate
{
    // Set temporary date and reload date cell
    [self setTemporaryDate:newDate];
    [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:SectionIndexSelectedDate]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -
#pragma mark Favorites Methods

- (BOOL)isFavorite
{
    return [[FavoritesController sharedFavorites] isFavoriteStop:stop forRoute:route];
}

- (void)updateFavoritesButton
{
    if([self isFavorite])
        [[self rightSegmentedBarButtonItem] setImage:[UIImage imageNamed:@"FavoriteStarFilled.png"]];
	else
        [[self rightSegmentedBarButtonItem] setImage:[UIImage imageNamed:@"FavoriteStarNoFill.png"]];
}

- (IBAction)favoritesButtonPressed:(id)sender
{
    NSString *title = [self isFavorite] ? @"Remove from Favorites?" : @"Add to Favorites?";
    NSString *otherButton = [self isFavorite] ? @"Remove" : @"Add";
    
    UIActionSheet *favoriteSheet = [[UIActionSheet alloc] initWithTitle:title
                                                               delegate:self 
                                                      cancelButtonTitle:@"Cancel"
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:otherButton, nil];
    
    [favoriteSheet showFromToolbar:[[self navigationController] toolbar]];
    [favoriteSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Ignore cancels
    if (buttonIndex == [actionSheet cancelButtonIndex])
        return;
    
    if([self isFavorite])
        [[FavoritesController sharedFavorites] removeFavoriteStop:stop forRoute:route];
	else
        [[FavoritesController sharedFavorites] addFavoriteStop:stop forRoute:route];
        
    [self updateFavoritesButton];
}

- (void)favoritesChanged:(NSNotification *)notification
{    
    [self updateFavoritesButton];
}

@end
