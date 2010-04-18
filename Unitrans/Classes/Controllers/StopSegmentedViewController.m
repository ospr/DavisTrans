//
//  StopSegmentedViewController.m
//  Unitrans
//
//  Created by Kip on 12/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StopSegmentedViewController.h"

#import "Route.h"
#import "Stop.h"
#import "StopViewController.h"
#import "RouteMapViewController.h"
#import "ExtendedViewController.h"
#import "DetailOverlayView.h"
#import "PredictionsView.h"
#import "Calendar.h"

CGFloat kPredictionViewHeight = 50.0;

@implementation StopSegmentedViewController

@synthesize route;
@synthesize stop;
@synthesize stopViewController;
@synthesize routeMapViewController;
@synthesize predictionsView;
@synthesize detailOverlayView;
@synthesize datePicker;
@synthesize datePickerDone;
@synthesize datePickerCancel;
@synthesize backButton;
@synthesize isFavorite;

CGFloat kDetailedOverlayViewHeight = 40.0;
CGFloat kDetailedOverlayViewWidth = 255.0;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self setSegmentItems:[NSArray arrayWithObjects:@"Schedule", @"Map", nil]];
    }
    
    return self;
}

- (void)dealloc 
{
    [route release];
    [stop release];
    
    [stopViewController release];
    [routeMapViewController release];
    
    // End continuous updates if they are still running
    if ([predictionsView isRunningContinuousPredictionUpdates])
        [predictionsView endContinuousPredictionsUpdates];
    [predictionsView release];
    [detailOverlayView release];
	
	[datePicker release];
	[datePickerDone release];
	[datePickerCancel release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[[self navigationController] setToolbarHidden:NO animated: YES];
    
    // Create detail overlay view
    detailOverlayView = [[DetailOverlayView alloc] initWithFrame:CGRectMake(0, 0, kDetailedOverlayViewWidth, kDetailedOverlayViewHeight)];
    [[detailOverlayView textLabel] setText:[stop name]];
    [[detailOverlayView detailTextLabel] setText:[NSString stringWithFormat:@"#%@ %@", [stop stopID], [stop headingString]]];
    [[detailOverlayView imageView] setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@RouteToolbarIcon_43.png", [route shortName]]]];
    [[self navigationItem] setTitleView:detailOverlayView];
    
    // Create tableBackground image view to fill in space behind prediction view
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TableBackground.png"]];
    [imageView setFrame:CGRectMake(0, 0, [[self view] frame].size.width, kPredictionViewHeight)];
    [[self view] addSubview:imageView];
    [imageView release];    
    
    // Create predictions view
    // Start view off screen (above) so we can animate it moving down later
    predictionsView = [[PredictionsView alloc] initWithFrame:CGRectMake(0, -kPredictionViewHeight, [[self view] frame].size.width, kPredictionViewHeight)];
    [predictionsView setRoute:route];
    [predictionsView setStop:stop];
    [[self view] addSubview:predictionsView];
    
    // Resize contentView to fit between predictionView and toolbar
    [contentView setFrame:CGRectMake(0, kPredictionViewHeight, [[self view] frame].size.width, [[self view] frame].size.height-kPredictionViewHeight)];
	
	// Init datepicker and its navigation buttons
	datePicker = [[UIDatePicker alloc] init];
	[datePicker setDatePickerMode:UIDatePickerModeDate];
    [datePicker addTarget:self action:@selector(datePickerValueDidChange) forControlEvents:UIControlEventValueChanged];
	
	[datePicker setMinimumDate:[(Calendar *)[[[route trips] anyObject] calendar] startDate]];
	[datePicker setMaximumDate:[(Calendar *)[[[route trips] anyObject] calendar] endDate]];
	
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGSize datePickerSize = [datePicker sizeThatFits:CGSizeZero];
	CGRect startRect = CGRectMake(0.0,
								  screenRect.origin.y + screenRect.size.height,
								  datePickerSize.width, 
								  datePickerSize.height);
	[datePicker setFrame:startRect];
	
	datePickerDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(datePickerDone:)];
	datePickerCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(datePickerCancel:)];
}

- (void)viewDidUnload 
{
	[super viewDidUnload];
	[self setRoute:nil];
	[self setStop:nil];
	[self setStopViewController:nil];
	[self setRouteMapViewController:nil];
    [self setDetailOverlayView:nil];
	[self setPredictionsView:nil];
	[self setDatePicker:nil];
	[self setDatePickerDone:nil];
	[self setDatePickerCancel:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Start loading predictions
    [predictionsView beginContinuousPredictionsUpdates];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Animate sliding prediction view down
	[self showPredictionViewWithAnimation];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Stop updating predictions
    [predictionsView endContinuousPredictionsUpdates];
}

#pragma mark -
#pragma mark SegmentedViewController Methods

- (ExtendedViewController *)viewControllerForSelectedSegmentIndex:(NSInteger)index
{    
    ExtendedViewController *viewController = nil;
    
    NSString *segmentIdentifier = [[self segmentItems] objectAtIndex:index];
    
    // Load RouteViewController
    if ([segmentIdentifier isEqualToString:@"Schedule"]) 
    {
        if (!stopViewController) {
            stopViewController = [[StopViewController alloc] init];
			[stopViewController setDelegate:self];
            [stopViewController setRoute:route];
            [stopViewController setStop:stop];
        }
        
        viewController = stopViewController;
    }
    // Load RouteMapViewController
    else if ([segmentIdentifier isEqualToString:@"Map"])
    {
        if (!routeMapViewController) {
            routeMapViewController = [[RouteMapViewController alloc] init];
            [routeMapViewController setRoute:route];
            [routeMapViewController setStop:stop];
        }
        
        viewController = routeMapViewController;
    }
    
    return viewController;
}

#pragma mark -
#pragma mark PredictionsView Methods

- (void)showPredictionViewWithAnimation
{
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
    
    [predictionsView setFrame:CGRectMake(0, 0, [[self view] frame].size.width, kPredictionViewHeight)];
    
	[UIView commitAnimations];
}

- (void)hidePredictionViewWithAnimation
{
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
    
    [predictionsView setFrame:CGRectMake(0, -kPredictionViewHeight, [[self view] frame].size.width, kPredictionViewHeight)];
    
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark DatePicker Methods

- (void) stopViewController:(StopViewController *)stopviewController showDatePickerWithDate:(NSDate *)date
{
	[datePicker setDate:date];
	
	[[self navigationController] setToolbarHidden:YES];
	[[self view] addSubview:datePicker];
	
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGSize datePickerSize = [datePicker sizeThatFits:CGSizeZero];
	// compute the end frame
	CGRect pickerRect = CGRectMake(0.0,
								   screenRect.size.height - (datePickerSize.height + 40.0),
								   datePickerSize.width,
								   datePickerSize.height);
	// start the slide up animation
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
    
    // Hide predictionView to remove clutter
    [self hidePredictionViewWithAnimation];
    
	// we need to perform some post operations after the animation is complete
	[UIView setAnimationDelegate:self];
	
	[datePicker setFrame:pickerRect];
	
	[UIView commitAnimations];
    
	// Save back button
	[self setBackButton:[[self navigationItem] leftBarButtonItem]];
	[[self navigationItem] setLeftBarButtonItem:datePickerCancel animated:YES];
	[[self navigationItem] setRightBarButtonItem:datePickerDone animated:YES];
}

- (void) dismissDatePicker
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect endFrame = [datePicker frame];
	endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
	
	[datePicker setFrame:endFrame];
	
	[UIView commitAnimations];
	
	// Restore navigation buttons
	[[self navigationItem] setRightBarButtonItem:nil animated:YES];
	[[self navigationItem] setLeftBarButtonItem:backButton animated:YES];
    
    // Resize overlay view to fit in navbar
    [detailOverlayView setFrame:CGRectMake(0, 0, kDetailedOverlayViewWidth, kDetailedOverlayViewHeight)];
    
	[[self navigationController] setToolbarHidden:NO];
}

- (void)slideDownDidStop
{
	// the date picker has finished sliding downwards, so remove it
	[datePicker removeFromSuperview];
}

- (void)endDatePickerWithDate:(NSDate *)date
{
    [self dismissDatePicker];
    [self showPredictionViewWithAnimation];
    [stopViewController chooseNewScheduleDateDidEndWithDate:date];
}

- (IBAction) datePickerDone:(id)sender
{
	[self endDatePickerWithDate:[datePicker date]];
}

- (IBAction) datePickerCancel:(id)sender
{
    [self endDatePickerWithDate:nil];
}

- (void) dismissDatePickerWithDate:(NSDate *)date
{
    [self endDatePickerWithDate:date];
}

- (void)datePickerValueDidChange
{
    // Let the stopViewController know that the date changed so it can update accordingly
    [stopViewController datePickerValueDidChangeWithDate:[datePicker date]];
}

@end
