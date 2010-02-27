//
//  ConcurrentOperation.m
//  Unitrans
//
//  Created by Kip on 12/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ConcurrentOperation.h"


@implementation ConcurrentOperation

- (id)init
{
    self = [super init];
    
    if (self) {
        executing = NO;
        finished = NO;
    }
    
    return self;
}

- (void)start
{
    // Always check for cancellation before launching the task.
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    // If operation has already been used, then call finished method
    if ([self isFinished]) {
        [self didFinishOperation];
        return;
    }
    
    // If the operation is not canceled or used, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];

    // Start run method on a separate thread
    [NSThread detachNewThreadSelector:@selector(run) toTarget:self withObject:nil];
}

- (void)run
{    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    @try {       
        [self main];
        
        [self completeOperation];
        
        if (![self isCancelled])
            [self performSelectorOnMainThread:@selector(didFinishOperation) withObject:nil waitUntilDone:NO];
    }
    @catch(NSException *exception) {
        NSLog(@"Exception caught while executing %@. Exception: %@", self, exception);
    }
    @finally {
        [pool drain];
    }
}

- (void)completeOperation
{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)didFinishOperation {}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return executing;
}

- (BOOL)isFinished
{
    return finished;
}

@end
