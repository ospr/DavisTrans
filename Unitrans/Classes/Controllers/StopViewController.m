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


@implementation StopViewController

@synthesize route;
@synthesize stop;
@synthesize stopTimes;
@synthesize selectedDate;
@synthesize datePicker;
@synthesize datePickerSheet;
@synthesize datePickerToolbar;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)dealloc 
{
    [route release];
    [stop release];
	[stopTimes release];
    [selectedDate release];
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"Stop Times"];
	[self setSelectedDate:[NSDate date]];
    [self updateStopTimes];
}

- (void)updateStopTimes
{
    // Get StopTimes based on route and date and sort
    NSSortDescriptor *stopTimeSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"arrivalTime" ascending:YES] autorelease];
    NSArray *sortedStopTimes = [[stop allStopTimesWithRoute:route onDate:selectedDate] sortedArrayUsingDescriptors:[NSArray arrayWithObject:stopTimeSortDescriptor]];
    [self setStopTimes:sortedStopTimes];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

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
		return [NSString string];
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
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		[dateFormatter setLocale:usLocale];
		[[cell textLabel] setText:[dateFormatter stringFromDate:selectedDate]];
		[[cell textLabel] setTextAlignment:UITextAlignmentCenter];
		
		[dateFormatter release];
		[usLocale release];
	}
	else 
	{
        StopTime *stopTime = [stopTimes objectAtIndex:[indexPath row]];
		[[cell textLabel] setText:[stopTime arrivalTimeString]];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	if([indexPath indexAtPosition:0] == 0)
	{
		// Create the UIDatePicker
		datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 44.0, 0.0, 0.0)];
		[datePicker setDatePickerMode:UIDatePickerModeDate];
		[datePicker setDate:selectedDate];
		
		// Create the UIToolbar to go above the UIDatePicker
		datePickerToolbar = [[UIToolbar alloc] init];
		datePickerToolbar.barStyle = UIBarStyleBlackOpaque;
		[datePickerToolbar sizeToFit];
		
		// Create and add UIBarButtons "Done" and "Cancel" buttons to UIToolbar
		NSMutableArray *barItems = [[NSMutableArray alloc] init];
		UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(datePickerCancelClicked:)];
		UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
		UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(datePickerDoneClicked:)];
		[barItems addObject:cancelBtn];
		[barItems addObject:flexSpace];
		[barItems addObject:doneBtn];
		[datePickerToolbar setItems:barItems animated:YES];
		
		// Add views to action sheet
		datePickerSheet = [[UIActionSheet alloc] init];
		[datePickerSheet addSubview:datePickerToolbar];
		[datePickerSheet addSubview:datePicker];
		[datePickerSheet showInView:self.view];
		[datePickerSheet setBounds:CGRectMake(0,0,320, 464)]; // TODO: hardcode bounds?? use screen to get current bounds?
		
		[cancelBtn release];
		[doneBtn release];
		[flexSpace release];
		[barItems release];
		[datePicker release];
		[datePickerToolbar release];
	}
	else 
	{
		StopTimeViewController *stopTimeViewController = [[StopTimeViewController alloc] initWithStyle:UITableViewStyleGrouped];
		[self.navigationController pushViewController:stopTimeViewController animated:YES];
		[stopTimeViewController release];
	}
}

- (IBAction) datePickerDoneClicked:(id)sender
{
    [self setSelectedDate:[datePicker date]];
    [self updateStopTimes];
	[[self tableView] reloadData];
	[datePickerSheet dismissWithClickedButtonIndex:1 animated:YES];
}

- (IBAction) datePickerCancelClicked:(id)sender
{
	[datePickerSheet dismissWithClickedButtonIndex:0 animated:YES];
	[datePicker release]; // TODO: why are we releasing here?
	[datePickerToolbar release]; // TODO: why are we releasing here? (and why not in datePickerDoneClicked??)
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

@end

