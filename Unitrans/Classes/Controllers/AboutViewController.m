//
//  AboutViewController.m
//  Unitrans
//
//  Created by Kip Nicol on 11/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"
#import "CreditsViewController.h"
#import "DatabaseManager.h"
#import "Agency.h"

NSString *kMainTextKey = @"Main";
NSString *kDetailTextKey = @"Detail";
NSString *kResourceURLKey = @"URL";

NSString *kUnitransPhone = @"530-752-BUSS";
NSString *kUnitransPhoneText = @"(530) 752-BUSS";
NSString *kUnitransEmail = @"unitrans@ucdavis.edu";

NSString *kTipsyPhone = @"530-752-6666";
NSString *kTipsyPhoneText = @"(530) 752-6666";
NSString *kTipsyWebsite = @"http://daviswiki.org/Tipsy_Taxi";

NSString *kUniRidePhone = @"530-754-4373";
NSString *kUniRidePhoneText = @"(530) 754-4373";
NSString *kUniRideWebsite = @"http://unitrans.ucdavis.edu/services/";

@implementation AboutViewController

@synthesize agency;
@synthesize aboutItems;
@synthesize delegate;

#pragma mark -
#pragma mark Init Methods

- (id)init
{
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (void)dealloc
{
    [agency release];
    [aboutItems release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set title
    [self setTitle:@"Info"];
    
    // Add done button
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    [[self navigationItem] setRightBarButtonItem:doneItem];
    [doneItem release];

                                                                                                                                            
    NSDictionary *unitransPhone = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"phone", kMainTextKey,
                                   kUnitransPhoneText, kDetailTextKey,
                                   [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", kUnitransPhone]], kResourceURLKey,
                                   nil];
    
    NSDictionary *unitransWebsite = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"website", kMainTextKey,
                                     [agency url], kDetailTextKey,
                                     [NSURL URLWithString:[agency url]], kResourceURLKey,
                                     nil];
    
    NSDictionary *unitransEmail = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"email", kMainTextKey,
                                   kUnitransEmail, kDetailTextKey,
                                   [NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", kUnitransEmail]], kResourceURLKey,
                                   nil];
        
    NSDictionary *tipsyPhone = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"phone", kMainTextKey,
                                kTipsyPhoneText, kDetailTextKey,
                                [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", kTipsyPhone]], kResourceURLKey,
                                nil];
    
    NSDictionary *tipsyWebsite = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"website", kMainTextKey,
                                  kTipsyWebsite, kDetailTextKey,
                                  [NSURL URLWithString:kTipsyWebsite], kResourceURLKey,
                                  nil];
    
    /*
    NSDictionary *uniRidePhone = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"phone", kMainTextKey,
                                  kUniRidePhoneText, kDetailTextKey,
                                  [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", kUniRidePhone]], kResourceURLKey,
                                  nil];
    
    NSDictionary *uniRideWebsite = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"website", kMainTextKey,
                                    kUniRideWebsite, kDetailTextKey,
                                    [NSURL URLWithString:kUniRideWebsite], kResourceURLKey,
                                    nil]; */
    
    NSDictionary *about = [NSDictionary dictionaryWithObjectsAndKeys:
                           @"Credits", kMainTextKey,
                           nil];
    
    NSArray *unitrans = [NSArray arrayWithObjects:unitransPhone, unitransWebsite, unitransEmail, nil];
    NSArray *tipsy = [NSArray arrayWithObjects:tipsyPhone, tipsyWebsite, nil];
    //NSArray *uniride = [NSArray arrayWithObjects:uniRidePhone, uniRideWebsite, nil];
    NSArray *moreInfo = [NSArray arrayWithObjects:about, nil];
    
    aboutItems = [[NSArray alloc] initWithObjects:unitrans, tipsy, moreInfo, nil];
}

- (void)viewDidUnload 
{
	[super viewDidUnload];
	[self setAgency:nil];
	[self setAboutItems:nil];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [aboutItems count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[aboutItems objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Unitrans";
    if (section == 1)
        return @"Tipsy Taxi";
    //if (section == 2)
    //    return @"UniRide";
    if (section == 2)
        return @"More Info";
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *ContactsCell = @"ContactsCell";
    static NSString *AboutCell    = @"AboutCell";
    
    NSString *cellIdentifier = nil;
    
    if ([indexPath section] == 3)
        cellIdentifier = AboutCell;
    else
        cellIdentifier = ContactsCell;
        
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        // About cell
        if ([indexPath section] == 3)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AboutCell] autorelease];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        // Contacts cells
        else
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:ContactsCell] autorelease];
            [[cell detailTextLabel] setAdjustsFontSizeToFitWidth:YES];
        }
    }
    	
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [[aboutItems objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
    
    // Set item's main text and detail text
    [[cell textLabel] setText:[item objectForKey:kMainTextKey]];
    [[cell detailTextLabel] setText:[item objectForKey:kDetailTextKey]];    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSDictionary *item = [[aboutItems objectAtIndex:[indexPath section]] objectAtIndex:[indexPath row]];
    
    if ([indexPath section] == 2)
    {
        CreditsViewController *creditsViewController = [[CreditsViewController alloc] init];
        
        [[self navigationController] pushViewController:creditsViewController animated:YES];
        [creditsViewController release];
    }
    else
    {
        // Open URL for selected cell
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
    
    // TableViewController won't work because viewDidAppear is not called when app is brought back to foreground (urls)
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [[self tableView] deselectRowAtIndexPath:[[self tableView] indexPathForSelectedRow] animated:YES];
}

- (IBAction)done:(id)sender
{
    [delegate aboutViewControllerDidFinish:self];
}

@end

