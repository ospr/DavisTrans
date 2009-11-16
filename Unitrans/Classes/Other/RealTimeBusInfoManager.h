//
//  RealTimeBusInfoManager.h
//  Unitrans
//
//  Created by Ken Zheng on 11/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RealTimeBusInfo;

@interface RealTimeBusInfoManager : NSObject {
	NSMutableArray *realTimeBusInfo;
	NSString *currentElement;
	NSXMLParser *xmlParser;
	NSInteger lastTime;
    NSError *parseError;
}

@property (nonatomic, retain) NSMutableArray *realTimeBusInfo;
@property (nonatomic, retain) NSString *currentElement;
@property (nonatomic, retain) NSXMLParser *xmlParser;
@property (nonatomic, assign) NSInteger lastTime;
@property (nonatomic, retain) NSError *parseError;

- (NSArray *) retrieveRealTimeBusInfoError:(NSError **)error;
- (NSArray *) retrieveRealTimeBusInfoFromLastTimeError:(NSError **)error;
- (NSArray *) retrieveRealTimeBusInfoWithRoute:(NSString *)theRoute error:(NSError **)error;
- (NSArray *) retrieveRealTimeBusInfoFromURL:(NSString *)theURL error:(NSError **)error;

+ (RealTimeBusInfoManager *) sharedRealTimeBusInfoManager;

@end
