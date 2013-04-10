//
//  CatapultAccountsTableViewController.m
//  Catapult
//
//  Created by Aziz Light on 4/9/13.
//  Copyright (c) 2013 Catapult Technology Ltd. All rights reserved.
//

#import "CatapultAccountsTableViewController.h"

@interface CatapultAccountsTableViewController ()

@end

@implementation CatapultAccountsTableViewController
{
    CatapultAccount *_accountModel;
    NSURL *_preparedAuthURL;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _accountModel = [[CatapultAccount alloc] init];
    
    self.accounts = [[NSMutableArray alloc] init];
    
    // TODO: Make the next line execute only if there are no accounts registered yet
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(signInWithCatapult:)];
    
    //    NSLog(@"%@", [[NXOAuth2AccountStore sharedStore] accounts]); // TODO: REMOVE THAT FUCKING LINE!!!
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)accounts
{
    if (_accounts == nil) {
        _accounts = [[NSMutableArray alloc] init];
    }
    
    return _accounts;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.accounts.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"accountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)signInWithCatapult:(id)sender
{
    [_accountModel signInWithCatapult:^ (BOOL completed, NSURL *preparedURL) {
        if (completed) {
            _preparedAuthURL = preparedURL;
            [self performSegueWithIdentifier:@"showAddAccountWebView" sender:sender];
        } else {
            // TODO: Show error or something
        }
    }];
}

- (void)signOut:(void (^)(void))callback
{
    [_accountModel signOutFromCatapult:^ (BOOL complete) {
        if (complete) {
            callback();
        } else {
            // TODO: Show error or something
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CatapultAddAccountWebViewController *webViewController = [segue destinationViewController];
    webViewController.url = _preparedAuthURL;
}

@end
