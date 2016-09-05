//
//  CreditsViewController.m
//  DavisTrans
//
//  Created by Kip on 4/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CreditsViewController.h"


@implementation CreditsViewController

@synthesize logoImageView;
@synthesize creditsTextView;
@synthesize versionLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    [[self navigationItem] setTitle:@"Credits"];
    [versionLabel setText:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    
    [logoImageView setImage:[logoImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [creditsTextView flashScrollIndicators];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
    [logoImageView release];
    [super dealloc];
}


@end
