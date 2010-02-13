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

CGFloat kPredictionLabelPadding = 10.0;
CGFloat kLoadingIndicatorPadding = 5.0;

@implementation PredictionsView

@synthesize predictions;
@synthesize predictionOperation;
@synthesize route;
@synthesize stop;

- (id)initWithFrame:(CGRect)frame 
{
    shadowOffset = 3;
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setOpaque:NO];
        
        // Init predictions to an empty array
        predictions = [[NSArray alloc] init];
        
        // Create image background view
        UIImage *backgroundImage = [[UIImage imageNamed:@"RedButton.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
        backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [backgroundImageView setImage:backgroundImage];
        [self addSubview:backgroundImageView];
        
        // Set up prediction label
        predictionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPredictionLabelPadding, kPredictionLabelPadding, frame.size.width - kPredictionLabelPadding*2.0, frame.size.height - kPredictionLabelPadding*2.0)];
        [predictionsLabel setTextAlignment:UITextAlignmentCenter];
        [predictionsLabel setBackgroundColor:[UIColor clearColor]];
        [predictionsLabel setTextColor:[UIColor whiteColor]];
        [predictionsLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [predictionsLabel setShadowColor:[UIColor blackColor]];
        [predictionsLabel setShadowOffset:CGSizeMake(0, 1)];
        [predictionsLabel setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:predictionsLabel];
        
        // Set up loading indicator
        loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [loadingIndicatorView setCenter:CGPointMake(frame.size.width - [loadingIndicatorView frame].size.width/2.0 - kLoadingIndicatorPadding , frame.size.height/2.0)];
        [self addSubview:loadingIndicatorView];
        
        // Update prediction text
        [self updatePredictionText];
    }
    
    return self;
}

- (void)dealloc
{
    // End continuous updates if still running
    if (predictionsContinuousUpdatesRunning)
        [self endContinuousPredictionsUpdates];
    
    [predictions release];
    [predictionOperation release];
    
    [predictionsLabel release];
    [loadingIndicatorView release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Prediction Update Methods

- (void)beginContinuousPredictionsUpdates
{
    predictionsContinuousUpdatesRunning = YES;
    
    [self updatePredictions];
    
    // If we are still updating after the first update, start a timer to updated every 20 seconds
    if (predictionsContinuousUpdatesRunning)
        predictionTimer = [[NSTimer scheduledTimerWithTimeInterval:20.0
                                                            target:self
                                                          selector:@selector(updatePredictions) 
                                                          userInfo:nil
                                                           repeats:YES] retain];
}

- (void)endContinuousPredictionsUpdates
{
    predictionsContinuousUpdatesRunning = NO;
    
    [self setPredictionOperation:nil];
    
    [predictionTimer invalidate];
    [predictionTimer release];
    predictionTimer = nil;
}

- (void)updatePredictions
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [loadingIndicatorView startAnimating];
    loading = YES;
    
    [self setPredictionOperation:[[[PredictionOperation alloc] initWithRouteName:[route shortName] stopTag:[[stop code] stringValue]] autorelease]];
    [predictionOperation setDelegate:self];
    [predictionOperation start];
    
    [self updatePredictionText];
}

- (void)updatePredictionText
{
    NSString *predictionText;
    
    if(loading && (!predictions || [predictions count] == 0))
        predictionText = @"Updating Predictions...";
    else if (!predictions)
        predictionText = @"Error gathering predictions.";
    else if ([predictions count] == 1 && [[predictions objectAtIndex:0] isEqual:@"Now"])
        predictionText = @"Now";
    else if ([predictions count] > 0)
        predictionText = [NSString stringWithFormat:@"%@ minutes", [predictions componentsJoinedByString:@", "]];
    else
        predictionText = @"No predictions at this time."; 
    
    [predictionsLabel setText:predictionText];
}

#pragma mark -
#pragma mark PredictionOperation Delegate Methods

- (void)predictionOperation:(PredictionOperation *)predictionOperation didFinishWithPredictions:(NSArray *)newPredictions
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [loadingIndicatorView stopAnimating];
    loading = NO;
    
    // If the first time is 0 convert it to "Now"
    NSMutableArray *mutableNewPredictions = [NSMutableArray arrayWithArray:newPredictions];
    if ([newPredictions count] > 0 && [[newPredictions objectAtIndex:0] isEqualToNumber:[NSNumber numberWithInteger:0]])
        [mutableNewPredictions replaceObjectAtIndex:0 withObject:@"Now"];
	
    [self setPredictions:[NSArray arrayWithArray:mutableNewPredictions]];
    [self updatePredictionText];
}

- (void)predictionOperation:(PredictionOperation *)predictionOperation didFailWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [loadingIndicatorView stopAnimating];
    loading = NO;
    
    [self endContinuousPredictionsUpdates];
    
    [self setPredictions:nil];
    [self updatePredictionText];
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
#pragma mark UIResponder Touch Event Methods

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touches ended");
    
    [self updatePredictions];
}

#pragma mark -
#pragma mark Custom Accessor Methods

- (void)setFrame:(CGRect)frame
{
    CGRect superFrame = frame;
    superFrame.size.height += shadowOffset;
    
    [super setFrame:superFrame];
}

#pragma mark -
#pragma mark Draw Methods

- (void)drawRect:(CGRect)rect
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
}

@end
