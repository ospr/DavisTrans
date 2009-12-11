//
//  TableViewController.m
//  Unitrans
//
//  Created by Kip Nicol on 11/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TableViewController.h"


@implementation TableViewController

@dynamic tableView;

- (void)dealloc
{
    [tableView release];
    
    [super dealloc];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    [tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:animated];
    [tableView flashScrollIndicators];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)setTableView:(UITableView *)tv
{
    [tv retain];
    [tableView release];
    tableView = tv;
    
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth)];
}

- (UITableView *)tableView
{
    return tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
