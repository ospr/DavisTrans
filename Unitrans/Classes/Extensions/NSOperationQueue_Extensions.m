//
//  NSOperationQueue_Extensions.m
//  Unitrans
//
//  Created by Kip on 8/2/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "NSOperationQueue_Extensions.h"


@implementation NSOperationQueue (NSOperationQueue_Extensions)

- (BOOL)allFinished
{
    // Iterate through all operations, if we find one that hasn't been
    // finished yet, then return NO. Otherwise return YES
    for (NSOperation *operation in [self operations])
        if (![operation isFinished])
            return NO;
    
    return YES;
}

@end
