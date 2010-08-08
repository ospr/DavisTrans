//
//  PredictionsView.m
//  Unitrans
//
//  Created by Kip on 2/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PredictionsView.h"

#import "Route.h"
#import "Stop.h"

#import "NSOperationQueue_Extensions.h"

CGFloat kPredictionLabelPadding = 10.0;
CGFloat kLoadingIndicatorPadding = 5.0;

@implementation PredictionsView

@synthesize predictions;
@synthesize route;
@synthesize stop;
@synthesize predictionLoadError;
@synthesize isRunningContinuousPredictionUpdates = runningContinuousPredictionUpdates;

- (id)initWithFrame:(CGRect)frame 
{
    shadowOffset = 3;
    
    self = [super initWithFrame:frame];
    
    if (self) {        
        // Create operation queue to handle the prediction operations
        operationQueue = [[NSOperationQueue alloc] init];
        
        // Init predictions to an empty array
        predictions = [[NSArray alloc] init];
        
        // Create non-highlighted background image
        UIImage *backgroundImage = [[UIImage imageNamed:@"RedButton.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
        [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        
        // Set up loading indicator
        loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [loadingIndicatorView setCenter:CGPointMake(frame.size.width - [loadingIndicatorView frame].size.width/2.0 - kLoadingIndicatorPadding , frame.size.height/2.0)];
        [self addSubview:loadingIndicatorView];
        
        // Set up prediction label
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
        [[self titleLabel] setFont:[UIFont boldSystemFontOfSize:20]];
        [[self titleLabel] setShadowOffset:CGSizeMake(0, 1)];
        [[self titleLabel] setAdjustsFontSizeToFitWidth:YES];
        [self setTitleEdgeInsets:UIEdgeInsetsMake(-shadowOffset, kPredictionLabelPadding, 0, kPredictionLabelPadding)];
        
        // Handle touches inside to update predictions
        [self addTarget:self action:@selector(updatePredictions) forControlEvents:UIControlEventTouchUpInside];
        
        // Update prediction text
        [self updatePredictionWithText:nil];
    }
    
    return self;
}

- (void)dealloc
{
    // End continuous updates if still running
    if (runningContinuousPredictionUpdates)
        [self endContinuousPredictionsUpdates];
    
    [predictions release];
    [operationQueue release];
    
    [route release];
    [stop release];
    [predictionLoadError release];
    
    [loadingIndicatorView release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Prediction Update Methods

- (void)beginContinuousPredictionsUpdates
{
    [self setIsRunningContinuousPredictionUpdates:YES];
    
    [self updatePredictions];
    
    // If we are still updating after the first update, start a timer to updated every 20 seconds
    if (runningContinuousPredictionUpdates)
        predictionTimer = [[NSTimer scheduledTimerWithTimeInterval:20.0
                                                            target:self
                                                          selector:@selector(updatePredictions) 
                                                          userInfo:nil
                                                           repeats:YES] retain];
}

- (void)endContinuousPredictionsUpdates
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self setIsRunningContinuousPredictionUpdates:NO];
            
    [predictionTimer invalidate];
    [predictionTimer release];
    predictionTimer = nil;
    
    [operationQueue cancelAllOperations];
}

- (void)updatePredictions
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [loadingIndicatorView startAnimating];
    loading = YES;

    PredictionOperation *predictionOperation = [[PredictionOperation alloc] initWithRouteName:[route shortName] stopTag:[[stop code] stringValue]];
    [predictionOperation setDelegate:self];
    
    [operationQueue addOperation:predictionOperation];
    [predictionOperation release];
    
    [self updatePredictionWithText:nil];
}

- (void)updatePredictionWithText:(NSString *)text
{
    NSString *predictionText;
    
    if(loading && (!predictions || [predictions count] == 0))
    {
        predictionText = @"Updating Predictions...";
    }
    else if (!predictions) 
    {
        if ([[predictionLoadError domain] isEqualToString:NSURLErrorDomain])
            predictionText = @"No Internet connection.";
        else 
            predictionText = @"Error gathering predictions.";
    }
    else 
    {
        predictionText = text;
    }

        
    [self setTitle:predictionText forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark PredictionOperation Delegate Methods

- (void)predictionOperation:(PredictionOperation *)predictionOperation didFinishWithPredictions:(NSArray *)newPredictions
{
    // Stop activity indicator if there are no more operations running
    if ([operationQueue allFinished]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [loadingIndicatorView stopAnimating];
        loading = NO;
    }
    
    // Reset error
    [self setPredictionLoadError:nil];
	
    [self setPredictions:newPredictions];
    [self updatePredictionWithText:[predictionOperation predictionText]];
}

- (void)predictionOperation:(PredictionOperation *)predictionOperation didFailWithError:(NSError *)error
{
    // Stop activity indicator if there are no more operations running
    if ([operationQueue allFinished]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [loadingIndicatorView stopAnimating];
        loading = NO;
    }
    
    [self setPredictionLoadError:error];
    NSLog(@"PredictionOperation failed due to error: %@, %@", error, [error userInfo]);
        
    [self setPredictions:nil];
    [self updatePredictionWithText:nil];
}

#pragma mark -
#pragma mark UIResponder Touch Event Methods

- (void)showLoadingError
{
    NSString *reason = @"There was an error while loading the predictions. Make sure you are connected to the internet.";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Predictions Loading Error" message:reason
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark -
#pragma mark Custom Accessor Methods

- (void)setFrame:(CGRect)frame
{
    // Add shadowOffset values to frame to accommodate for shadow
    CGRect superFrame = frame;
    superFrame.size.height += shadowOffset;
    
    [super setFrame:superFrame];
}

#pragma mark -
#pragma mark Draw Methods

/*- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGRect bounds = [self bounds];
    CGRect boundsOffset = CGRectOffset(bounds, 0, -shadowOffset);
    CGSize myShadowOffset = CGSizeMake(0, -shadowOffset);
    
    CGContextSetShadow(context, myShadowOffset, 5);
    
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, boundsOffset);
    
    CGContextRestoreGState(context);
}*/

@end
