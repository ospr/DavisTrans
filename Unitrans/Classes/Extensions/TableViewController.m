//
//  TableViewController.m
//  DavisTrans
//
//  Created by Kip Nicol on 11/29/09.
//  Copyright 2009 Kip Nicol & Ken Zheng
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
