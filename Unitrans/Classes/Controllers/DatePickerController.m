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

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

#pragma mark -
#pragma mark Memory Management
- (void)dealloc 
{
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController methods

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	// set date picker to show selected date
	[datePicker setDate:[stopViewController selectedDate]];
}

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
