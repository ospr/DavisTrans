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

@synthesize initialDate;
@synthesize datePicker;
@synthesize delegate;

#pragma mark -
#pragma mark Memory Management
- (void)dealloc 
{
	[initialDate release];
    [datePicker release];
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	// set date picker to show selected date
	[datePicker setDate:initialDate];
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

- (IBAction) cancel:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) done:(id)sender
{
	if (![[datePicker date] isEqualToDate:initialDate]) 
		[delegate datePickerController:self dateChangedTo:[datePicker date]];
	[self dismissModalViewControllerAnimated:YES];
}

@end
