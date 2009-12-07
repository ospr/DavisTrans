//
//  AboutViewController.m
//  Unitrans
//
//  Created by Kip Nicol on 11/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"
#import "DatabaseManager.h"
#import "Agency.h"

NSString *kMainTextKey = @"Main";
NSString *kDetailTextKey = @"Detail";
NSString *kResourceURLKey = @"URL";

NSString *kUnitransEmail = @"unitrans@ucdavis.edu";

@implementation AboutViewController

@synthesize agency;

- (id)init
{
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (void)dealloc
{
    [aboutItems release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"About Unitrans"];

    NSDictionary *unitransPhone = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"Unitrans phone", kMainTextKey,
                                   [agency phone], kDetailTextKey,
                                   [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [agency phone]]], kResourceURLKey,
                                   nil];
    
    NSDictionary *unitransWebsite = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"Unitrans website", kMainTextKey,
                                     [agency url], kDetailTextKey,
                                     [NSURL URLWithString:[NSString stringWithFormat:[agency url]]], kResourceURLKey,
                                     nil];
    
    NSDictionary *unitransEmail = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"Unitrans email", kMainTextKey,
                                   kUnitransEmail, kDetailTextKey,
                                   [NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", kUnitransEmail]], kResourceURLKey,
                                   nil];
    
    
    aboutItems = [[NSArray alloc] initWithObjects:unitransWebsite, unitransPhone, unitransEmail, nil];
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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [aboutItems count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *item = [aboutItems objectAtIndex:[indexPath row]];
    
    [[cell textLabel] setText:[item objectForKey:kMainTextKey]];
    [[cell detailTextLabel] setText:[item objectForKey:kDetailTextKey]];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSDictionary *item = [aboutItems objectAtIndex:[indexPath row]];
    
    NSURL *url = [item objectForKey:kResourceURLKey];
    
    if (url) {
        // Open URL if we can open the URL
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
        // If we can't open the URL, then alert the user
        else {
            NSString *reason = @"Your device does not support this feature.";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unsupported Feature" message:reason
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow] animated:YES];
}


@end

