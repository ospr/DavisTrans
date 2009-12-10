//
//  DatePickerController.m
//  Unitrans
//
//  Created by Ken Zheng on 12/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DatePickerController.h"
#import "NSDate_Extensions.h"

@implementation DatePickerController

@synthesize stopViewController;
@synthesize datePicker;

#pragma mark -
#pragma mark Memory Management
- (void)dealloc 
{
    [stopViewController release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	// set date picker to show selected date
	[datePicker setDate:[stopViewController selectedDate]];
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
#pragma mark IBAction methods

- (IBAction) cancel
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) done
{
	[stopViewController setSelectedDate:[datePicker date]];
	[stopViewController updateStopTimes];
	[[stopViewController tableView] reloadData];
	[self dismissModalViewControllerAnimated:YES];
}

@end
