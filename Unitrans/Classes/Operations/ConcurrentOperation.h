//
//  ConcurrentOperation.h
//  DavisTrans
//
//  Created by Kip on 12/6/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ConcurrentOperation : NSOperation {
    BOOL executing;
    BOOL finished;
}

- (void)completeOperation;
- (void)didFinishOperation;

@end
