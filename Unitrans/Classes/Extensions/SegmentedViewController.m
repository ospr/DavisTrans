//
//  SegmentedViewController.m
//  Unitrans
//
//  Created by Kip on 12/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SegmentedViewController.h"

#import "ExtendedViewController.h"


@implementation SegmentedViewController

@synthesize selectedViewController;
@synthesize segmentedControl;
@synthesize segmentItems;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        segmentWidth = 90.0;
        viewTransitionDuration = 1.0;
    }
    
    return self;
}

- (void)dealloc 
{
    [segmentedControl release];
    [segmentedButtonItem release];
    [flexibleSpaceItem release];
    
    [segmentItems release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Unhide the toolbar and set tint color
    [[[self navigationController] toolbar] setTintColor:[[[self navigationController] navigationBar] tintColor]];
        
    // Create segmentedControl used to switch between views
    segmentedControl = [[UISegmentedControl alloc] initWithItems:[self segmentItems]];
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [segmentedControl setTintColor:[[[self navigationController] navigationBar] tintColor]];
    
    // Create the segmented button item to add to the toolbar
    segmentedButtonItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    [segmentedButtonItem setWidth:(segmentWidth * [segmentItems count])];
    
    // Create a flexible space item to use in the toolbar
    flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    // Select first segment
    if ([[self segmentItems] count] != 0)
        [segmentedControl setSelectedSegmentIndex:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Forward onto selected view controller
    [selectedViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Forward onto selected view controller
    [selectedViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Forward onto selected view controller
    [selectedViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Forward onto selected view controller
    [selectedViewController viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Action Methods

- (IBAction)segmentAction:(id)sender
{
    // Select new segment view when user changes segment
    [self segmentIndexWasSelected:[segmentedControl selectedSegmentIndex]];
}

#pragma mark -
#pragma mark Segmented Methods To Override

- (ExtendedViewController *)viewControllerForSelectedSegmentIndex:(NSInteger)index
{
    return nil;
}

#pragma mark -
#pragma mark Private Segmented Methods

- (void)segmentIndexWasSelected:(NSInteger)index
{
    ExtendedViewController *newSelectedViewController = [self viewControllerForSelectedSegmentIndex:index];
    
    // If there is no viewController for selected index set view to nil and return
    if (!newSelectedViewController) {
        [self setView:nil];
        [self setSelectedViewController:nil];
        return;
    }
    
    // Set segmentedViewController
    [newSelectedViewController setSegmentedViewController:self];
        
    // Get the selected view from the viewController
    UIView *selectedView = [newSelectedViewController view];
    
    // Get the buttonItems from the viewController
    UINavigationItem *navigationItem = [newSelectedViewController navigationItem];
    UIBarButtonItem *rightBarButtonItem = [navigationItem rightBarButtonItem];
    UIBarButtonItem *leftBarButtonItem = [navigationItem leftBarButtonItem];
        
    // If there is no corresponding button item,
    // replace it with a flexible item
    if (!rightBarButtonItem)
        rightBarButtonItem = flexibleSpaceItem;
    if (!leftBarButtonItem)
        leftBarButtonItem = flexibleSpaceItem;
        
    // Create an array of toolbar items and set them
    NSArray *toolbarItems = [NSArray arrayWithObjects:leftBarButtonItem, flexibleSpaceItem, segmentedButtonItem, flexibleSpaceItem, rightBarButtonItem, nil];
    [self setToolbarItems:toolbarItems];
 
    if (!selectedViewController)
        [self setView:selectedView];
    else
        [self animateViewTransitionFromViewController:selectedViewController toViewController:newSelectedViewController];
    
    [self setSelectedViewController:newSelectedViewController];
}

#pragma mark -
#pragma mark View Transition Methods

- (void)animateViewTransitionFromViewController:(ExtendedViewController *)fromViewCtl toViewController:(ExtendedViewController *)toViewCtl
{    
    NSDictionary *context = [[NSDictionary dictionaryWithObjectsAndKeys:fromViewCtl, @"FromViewController",
                                                                        toViewCtl,   @"ToViewController", nil] retain]; 
    
    // Move to will start animation method?
    [fromViewCtl viewWillDisappear:YES];
    [toViewCtl viewWillAppear:YES];
    
    // Determine animation
    UIViewAnimationTransition transition = [toViewCtl segmentTransition];
    
    // Animate setting view property to new view
	[UIView beginAnimations:nil context:context];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animateViewTransitionDidStop:finished:context:)];
	[UIView setAnimationDuration:viewTransitionDuration];

    
	[UIView setAnimationTransition:transition
                           forView:[[self view] superview]
                             cache:YES];
        
    [self setView:[toViewCtl view]];
	
	[UIView commitAnimations];
}
                                                  
- (void)animateViewTransitionDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    NSDictionary *contextDictionary = (NSDictionary *)context;
    ExtendedViewController *fromViewCtl = [contextDictionary objectForKey:@"FromViewController"];
    ExtendedViewController *toViewCtl = [contextDictionary objectForKey:@"ToViewController"];
    
    // Notify view controllers of disappearance and appearance
    [fromViewCtl viewDidDisappear:YES];
    [toViewCtl viewDidAppear:YES];
    
    [contextDictionary release];
}


@end
