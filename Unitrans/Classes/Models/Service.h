//
//  Service.h
//  Unitrans
//
//  Created by Kip on 5/20/10.
//  Copyright 2010 All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Service : NSObject {
    NSString *shortName;
    NSString *longName;
    NSString *resourceName;
    NSString *resourceKind;
}

@property (nonatomic, copy) NSString *shortName;
@property (nonatomic, copy) NSString *longName;
@property (nonatomic, copy) NSString *resourceName;
@property (nonatomic, copy) NSString *resourceKind;

- (BOOL)validServiceOnDate:(NSDate *)date;

@end
