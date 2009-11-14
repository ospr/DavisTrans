//
//  StopViewController.m
//  Unitrans
//
//  Created by Ken Zheng on 11/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StopViewController.h"
#import "StopTimeViewController.h"
#import "Stop.h"
#import "StopTime.h"
#import "Route.h"
#import "NSDate_Extensions.h"


@implementation StopViewController

@synthesize route;
@synthesize stop;
@synthesize stopTimes;
@synthesize selectedDate;
@synthesize selectedDateFormatter;
@synthesize referenceDateFormatter;
@synthesize referenceDateTimeFormatter;
@synthesize datePicker;
@synthesize datePickerSheet;

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
	[datePicker release];
	[datePickerSheet release];
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"Stop Times"];
	[self setSelectedDate:[NSDate beginningOfDay:[NSDate date]]]; 
    [self updateStopTimes];
	
	// Initialize NSDateFormatter
	selectedDateFormatter = [[NSDateFormatter alloc] init];
	[selectedDateFormatter setTimeStyle:NSDateFormatterNoStyle];
	[selectedDateFormatter setDateStyle:NSDateFormatterMediumStyle];
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[selectedDateFormatter setLocale:usLocale];
	[usLocale release]; 
	
	referenceDateFormatter = [[NSDateFormatter alloc] init];
	[referenceDateFormatter setDateFormat:@"yyyy-MM-dd"];
	referenceDateTimeFormatter = [[NSDateFormatter alloc] init];
	[referenceDateTimeFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
	
	// Initialize UIDatePicker
	datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 44.0, 0.0, 0.0)];
	[datePicker setDatePickerMode:UIDatePickerModeDate];
	[datePicker setDate:selectedDate];
	
	// Create UIToolBar to go above the UIDatePicker and add "Done" and "Cancel" UIBarButtonItems
	UIToolbar *datePickerToolbar = [[UIToolbar alloc] init];
	datePickerToolbar.barStyle = UIBarStyleBlackOpaque;
	[datePickerToolbar sizeToFit];
	UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(datePickerCancelClicked:)];
	UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(datePickerDoneClicked:)];
	[datePickerToolbar setItems:[NSArray arrayWithObjects:cancelBtn, flexSpace, doneBtn, nil] animated:YES];
	
	[cancelBtn release];
	[flexSpace release];
	[doneBtn release];
	
	// Initialize UIActionSheet and add UIDatePicker and UIToolbar
	datePickerSheet = [[UIActionSheet alloc] init];
	[datePickerSheet addSubview:datePickerToolbar];
	[datePickerSheet addSubview:datePicker];
	
	[datePickerToolbar release];
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
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if(section == 0)
		return 1;
	else
		return [stopTimes count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(section == 0)
		return [NSString stringWithString:@"Schedule for date:"];
	else
		return [stop name];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier = @"StopTimeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
        
    // Set up the cell...
	if([indexPath section] == 0)
	{
		[[cell textLabel] setText:[selectedDateFormatter stringFromDate:selectedDate]];
		[[cell textLabel] setTextAlignment:UITextAlignmentCenter];
	}
	else 
	{
        StopTime *stopTime = [stopTimes objectAtIndex:[indexPath row]];
		[[cell textLabel] setText:[stopTime arrivalTimeString]];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if([indexPath indexAtPosition:0] == 0)
	{
		// Reselect the selected date (cancel on the date picker can make the picker to show different date
		[datePicker setDate:selectedDate animated:YES];
		// Show UIActionSheet
		[datePickerSheet showInView:self.view];
		[datePickerSheet setBounds:CGRectMake(0.0, 0.0, [[self view] frame].size.width , [[self view] frame].size.height)];
	}
	else 
	{
        StopTime *stopTime = [stopTimes objectAtIndex:[indexPath row]];
        
		StopTimeViewController *stopTimeViewController = [[StopTimeViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [stopTimeViewController setStopTime:stopTime];
		[self.navigationController pushViewController:stopTimeViewController animated:YES];
		[stopTimeViewController release];
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath section] == 1) 
	{
	//	NSString *referenceDateString = [NSString stringWithFormat:@"%@ 12:00 am", [referenceDateFormatter stringFromDate:[NSDate date]]];
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

#pragma mark -
#pragma mark Instance methods

- (void)updateStopTimes
{
    // Get StopTimes based on route and date and sort
    NSSortDescriptor *stopTimeSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"arrivalTime" ascending:YES] autorelease];
    NSArray *sortedStopTimes = [[stop allStopTimesWithRoute:route onDate:selectedDate] sortedArrayUsingDescriptors:[NSArray arrayWithObject:stopTimeSortDescriptor]];
    [self setStopTimes:sortedStopTimes];
}

#pragma mark -
#pragma mark IBAction methods
- (IBAction) datePickerDoneClicked:(id)sender
{
    [self setSelectedDate:[datePicker date]];
    [self updateStopTimes];
	[[self tableView] reloadData];
	[datePickerSheet dismissWithClickedButtonIndex:1 animated:YES];
}

- (IBAction) datePickerCancelClicked:(id)sender
{
	[[self tableView] reloadData];
	[datePickerSheet dismissWithClickedButtonIndex:0 animated:YES];
}

@end

