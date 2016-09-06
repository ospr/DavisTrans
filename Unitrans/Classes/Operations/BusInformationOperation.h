//
//  BusInformationOperation.h
//  DavisTrans
//
//  Created by Kip on 12/6/09.
//  Copyright 2009 Kip Nicol & Ken Zheng
//

#import <Foundation/Foundation.h>
#import "ConcurrentOperation.h"

@protocol BusInformationOperationDelegate;

@interface BusInformationOperation : ConcurrentOperation <NSXMLParserDelegate> {
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
@property (nonatomic, assign) id<BusInformationOperationDelegate> delegate;

- (id) initWithRouteName:(NSString *)newRouteName;

- (void) retrieveBusInformation;

@end

// Delegate methods
@protocol BusInformationOperationDelegate <NSObject>
@required
- (void)busInformation:(BusInformationOperation *)busInformationOperation didFinishWithBusInformation:(NSArray *)busInformation;
- (void)busInformation:(BusInformationOperation *)busInformationOperation didFailWithError:(NSError *)error;
@end

