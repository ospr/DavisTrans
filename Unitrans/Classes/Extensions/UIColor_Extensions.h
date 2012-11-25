//
//  UIColor_Extensions.h
//  Unitrans
//
//  Created by Kip Nicol on 11/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIColor(UIColor_Extensions)

+ (UIColor *)colorFromHexadecimal:(NSInteger)hex alpha:(CGFloat)alpha;

+ (UIColor *)extraLightGrayColor;

+ (UIColor *)davisTransScrollViewTexturedBackground;

@end
