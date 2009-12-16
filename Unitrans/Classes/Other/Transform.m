//
//  Transform.m
//  Unitrans
//
//  Created by Ken Zheng on 12/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Transform.h"

@implementation Transform

+ (CGAffineTransform) rotateByDegrees:(NSInteger)degrees
{
	double radians = degrees * (3.14/180);
	return CGAffineTransformMake(cos(radians), sin(radians), -sin(radians), cos(radians), 0, 0);
}

@end
