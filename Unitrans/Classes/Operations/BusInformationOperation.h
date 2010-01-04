//
//  BusInformationOperation.h
//  Unitrans
//
//  Created by Kip on 12/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConcurrentOperation.h"

@protocol BusInformationOperationDelegate;

@interface BusInformationOperation : ConcurrentOperation {
    NSMutableArray *busInformation;
    NSString *routeName;
	NSString *currentElement;
    
    NSError *parseError;
    
    id<BusInformationOperationDelegate> delegate;
}

@property (nonatomic, retain) NSMutableArray *busInformation;
@property (nonatomic, retain) NSString *routeName;
@property (nonatomic, retain) NSString *currentElement;
@property (nonatomic, retain) NSError *parseError;
@property (nonatomic, retain) id<BusInformationOperationDelegate> delegate;

- (id) initWithRouteName:(NSString *)newRouteName;

- (void) retrieveBusInformation;

@end

// Delegate methods
@protocol BusInformationOperationDelegate <NSObject>
@required
- (void)busInformation:(BusInformationOperation *)busInformationOperation didFinishWithBusInformation:(NSArray *)busInformation;
- (void)busInformation:(BusInformationOperation *)busInformationOperation didFailWithError:(NSError *)error;
@end
