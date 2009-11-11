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
    [[self view] setBackgroundColor:[UIColor colorWithRed:(163/255.0) green:(50/255.0) blue:(52/255.0) alpha:1.0]];

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


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
        [[UIApplication sharedApplication] openURL:url];
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

@end

