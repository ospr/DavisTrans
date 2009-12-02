//
//  DatePickerController.h
//  Unitrans
//
//  Created by Ken Zheng on 12/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StopViewController.h"


@interface DatePickerController : UIViewController {
	StopViewController *stopViewController;
	IBOutlet UIDatePicker *datePicker;
}

@property (retain, nonatomic) StopViewController *stopViewController;
@property (retain, nonatomic) IBOutlet UIDatePicker *datePicker;

- (IBAction) cancel;
- (IBAction) done;

@end
