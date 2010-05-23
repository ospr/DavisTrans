//
//  Service.m
//  Unitrans
//
//  Created by Kip on 5/20/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "Service.h"


@implementation Service

@synthesize shortName;
@synthesize longName;
@synthesize resourceName;
@synthesize resourceKind;

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]] && [[object shortName] isEqualToString:shortName])
        return YES;
        
    return NO;
}

- (NSUInteger)hash
{
    return [shortName hash];
}

@end
