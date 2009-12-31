//
//  DatePickerController.h
//  Unitrans
//
//  Created by Ken Zheng on 12/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DatePickerControllerDelegate;

@interface DatePickerController : UIViewController {
	NSDate *initialDate;
	
	IBOutlet UIDatePicker *datePicker;
	
	id<DatePickerControllerDelegate> delegate;
}

@property (nonatomic, retain) NSDate *initialDate;
@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, retain) id<DatePickerControllerDelegate> delegate;

- (IBAction) cancel:(id)sender;
- (IBAction) done:(id)sender;

@end

// Delegate methods
@protocol DatePickerControllerDelegate <NSObject>
@required
- (void) datePickerController:(DatePickerController *)datePickerController dateChangedTo:(NSDate *)newDate;
@end