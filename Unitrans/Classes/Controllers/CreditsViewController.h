//
//  CreditsViewController.h
//  DavisTrans
//
//  Created by Kip on 4/11/10.
//  Copyright 2010 Kip Nicol & Ken Zheng
//

#import <UIKit/UIKit.h>


@interface CreditsViewController : UIViewController {
    UIImageView *logoImageView;
    UITextView *creditsTextView;
    UILabel *versionLabel;
}

@property (nonatomic, retain) IBOutlet UIImageView *logoImageView;
@property (nonatomic, retain) IBOutlet UITextView *creditsTextView;
@property (nonatomic, retain) IBOutlet UILabel *versionLabel;

@end
