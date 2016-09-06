//
//  UIColor_Extensions.h
//  DavisTrans
//
//  Created by Kip Nicol on 11/9/09.
//  Copyright 2009 Kip Nicol & Ken Zheng
//

#import <Foundation/Foundation.h>


@interface UIColor(UIColor_Extensions)

+ (UIColor *)colorFromHexadecimal:(NSInteger)hex alpha:(CGFloat)alpha;

+ (UIColor *)extraLightGrayColor;

@end
