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
#import "DatePickerController.h"
#import "PredictionsView.h"

CGFloat kPredictionViewHeight = 50.0;

@implementation StopSegmentedViewController

@synthesize route;
@synthesize stop;
@synthesize stopViewController;
@synthesize routeMapViewController;
@synthesize predictionsView;

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
    
    [predictionsView release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create detail overlay view
    DetailOverlayView *detailOverlayView = [[DetailOverlayView alloc] initWithFrame:CGRectMake(0, 0, 255, 40)];
    [[detailOverlayView textLabel] setText:[stop name]];
    [[detailOverlayView detailTextLabel] setText:[NSString stringWithFormat:@"#%@ %@", [stop stopID], [stop headingString]]];
    [[detailOverlayView imageView] setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@RouteToolbarIcon_43.png", [route shortName]]]];
    
    // Set navbar title view
    [[self navigationItem] setTitleView:detailOverlayView];
    [detailOverlayView release];
    
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
    [predictionsView beginContinuousPredictionsUpdates];
    [[self view] addSubview:predictionsView];
    
    // Resize contentView to fit between predictionView and toolbar
    [contentView setFrame:CGRectMake(0, kPredictionViewHeight, [[self view] frame].size.width, [[self view] frame].size.height-kPredictionViewHeight)];
}

- (void)viewDidUnload 
{
	[super viewDidUnload];
	[self setRoute:nil];
	[self setStop:nil];
	[self setStopViewController:nil];
	[self setRouteMapViewController:nil];
	[self setPredictionsView:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Animate sliding prediction view down
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
    
    [predictionsView setFrame:CGRectMake(0, 0, [[self view] frame].size.width, kPredictionViewHeight)];
    
	[UIView commitAnimations];
}

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
#pragma mark StopViewController Delegate

- (void) stopViewController:(StopViewController *)stopviewController showDatePickerWithDate:(NSDate *)date
{
	DatePickerController *datePickerController = [[[DatePickerController alloc] initWithNibName:@"DatePickerController" bundle:nil] autorelease];
	[datePickerController setDelegate:self];
	[datePickerController setInitialDate:date];
	[[self navigationController] presentModalViewController:datePickerController animated:YES];
}

#pragma mark -
#pragma mark DatePickerControllerDelegate methods

- (void) datePickerController:(DatePickerController *)datePickerController dateChangedTo:(NSDate *)newDate
{
	if(newDate)
	{
		[stopViewController setSelectedDate:newDate];
		[stopViewController updateStopTimes];
	}
	
	[self dismissModalViewControllerAnimated:YES];
}

@end
