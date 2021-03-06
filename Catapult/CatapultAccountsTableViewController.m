//
//  CatapultAccountsTableViewController.m
//  Catapult
//
//  Created by Aziz Light on 4/9/13.
//  Copyright (c) 2013 Catapult Technology Ltd. All rights reserved.
//

#import "CatapultAccountsTableViewController.h"

@interface CatapultAccountsTableViewController ()

- (void)removeAccountFromAccountsArrayUsingAccountName:(NSString *)accountName;

@end

@implementation CatapultAccountsTableViewController
{
    CatapultAccount *_accountModel;
    UIBarButtonItem *_backButton;
    NSURL *_preparedAuthURL;
    NSString *_loginType;
    NSString *_clientName;
    NSString *_userName;
    UITableViewCell *_latestAccountCell;
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
    
    NSDictionary *currentAccount = [_accountModel getCurrentAccount];
    
    if (currentAccount == nil) {
        self.accounts = [[_accountModel getAllAccounts] mutableCopy];
    } else {
        NSMutableArray *allAccounts = [[_accountModel getAllAccountsExceptCurrentOne:[currentAccount objectForKey:@"account_name"]] mutableCopy];
        [allAccounts addObject:currentAccount];
        self.accounts = allAccounts;
    }
    
    if (self.accounts.count == 0) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                               target:self
                                                                                               action:@selector(signInWithCatapult:)];
    } else {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kCatapultAccountCreatedNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^ (NSNotification *notification) {
                                                      [self.accounts addObject:notification.userInfo];
                                                      
                                                      [self.tableView beginUpdates];
                                                      
                                                      [self.tableView insertSections:[NSIndexSet indexSetWithIndex:(self.accounts.count) -1]
                                                                    withRowAnimation:UITableViewRowAnimationTop];
                                                      
                                                      [self.tableView endUpdates];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kCatapultAccountLoggedInNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^ (NSNotification *notification) {
                                                      _latestAccountCell.accessoryType = UITableViewCellAccessoryCheckmark;
                                                  }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    static NSString *cellIdentifier = @"accountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *account = [self.accounts objectAtIndex:indexPath.section];
    
    [cell.textLabel setText:[account objectForKey:@"client_name"]];
    
    NSString *forename = [account objectForKey:@"forename"];
    NSString *surname = [account objectForKey:@"surname"];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@ %@", forename, surname]];
    
    NSString *smallestLogoPath = [account objectForKey:@"smallest_logo"];
    
    UIImage *smallestLogo = nil;
    
    if (smallestLogoPath != nil && [smallestLogoPath class] != [NSNull class]) {
        smallestLogo = [UIImage imageWithContentsOfFile:smallestLogoPath];
    }
    
    if (smallestLogo != nil) {
        cell.imageView.image = smallestLogo;
    }
    
    NSDictionary *currentAccount = [_accountModel getCurrentAccount];
    
    if ([[account objectForKey:@"account_name"] isEqualToString:[currentAccount objectForKey:@"account_name"]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (editing) {
        [super setEditing:editing animated:animated];
        
        _backButton = self.navigationItem.leftBarButtonItem;
        
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                    target:self
                                                                                    action:@selector(signInWithCatapult:)];
        self.navigationItem.leftBarButtonItem = leftButton;
    } else {
        [super setEditing:editing animated:animated];
        
        self.navigationItem.leftBarButtonItem = _backButton;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//        NSDictionary *account = [_accountModel getAccountWithClientName:cell.textLabel.text andUserName:cell.detailTextLabel.text];
        
        NSString *accountName = [_accountModel getAccountNameForAccountWithClientName:cell.textLabel.text andUserName:cell.detailTextLabel.text];
        
        if (accountName != nil && [_accountModel deleteAccountWithClientName:cell.textLabel.text andUserName:cell.detailTextLabel.text]) {
            [self removeAccountFromAccountsArrayUsingAccountName:accountName];
            
            [_accountModel signOutFromCatapult:^ (BOOL completed) {
#if DEBUG
                if (!completed) {
                    NSLog(@"ERROR: User was not logged out of the account!");
                }
#endif
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                
                if (self.accounts.count == 0) {
                    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                                           target:self
                                                                                                           action:@selector(signInWithCatapult:)];
                    [self setEditing:NO animated:YES];
                }
            }];
        } else {
#if DEBUG
            NSLog(@"ERROR: %@", [_accountModel lastError]);
#endif
            UIAlertView *errorMessage = [[UIAlertView alloc] initWithTitle:@"Deletion unsuccessful"
                                                                   message:@"Unable to delete selected account"
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
            [errorMessage show];
        }
    }
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        [_accountModel signOutFromCatapult:^ (BOOL completed) {
            if (completed) {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selected = false;
            } else {
                UIAlertView *errorMessage = [[UIAlertView alloc] initWithTitle:@"Sign out error"
                                                                       message:@"Unable to sign out from Catapult"
                                                                      delegate:nil
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles:nil];
                
                [errorMessage show];
            }
        }];
    } else if (cell.accessoryType == UITableViewCellAccessoryNone) {
        _latestAccountCell = cell;
        [self signInWithCatapult:cell];
    }
}

- (void)signInWithCatapult:(id)sender
{
#if DEBUG
    // NOTE: Uncomment this code to clear the keychain
//    NSArray *accounts = [[NXOAuth2AccountStore sharedStore] accounts];
//    for (NXOAuth2Account *account in accounts) {
//        [[NXOAuth2AccountStore sharedStore] removeAccount:account];
//    }
//    
//    return;
#endif
    
    [_accountModel signInWithCatapult:^ (BOOL completed, NSURL *preparedURL) {
        if (completed) {
            if ([sender class] == [UITableViewCell class]) {
                UITableViewCell *cell = sender;
                NSString *newURLString = [NSString stringWithFormat:@"%@&client_name=%@", [preparedURL absoluteString], [cell.textLabel.text urlEncodeUsingEncoding:NSUTF8StringEncoding]];
                _preparedAuthURL = [NSURL URLWithString:newURLString];
                _loginType = kCatapultSubsequentLogInType;
                _clientName = cell.textLabel.text;
                _userName = cell.detailTextLabel.text;
            } else {
                _preparedAuthURL = preparedURL;
                _loginType = kCatapultFirstLogInType;
                _clientName = nil;
                _userName = nil;
            }
            
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
    webViewController.loginType = _loginType;
    webViewController.clientName = _clientName;
    webViewController.userName = _userName;
}

- (void)removeAccountFromAccountsArrayUsingAccountName:(NSString *)accountName
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *account, NSDictionary *binding) {
        return [account isEqualToString:[binding objectForKey:@"account_name"]];
    }];
    
    [self.accounts enumerateObjectsUsingBlock:^(NSDictionary *account, NSUInteger index, BOOL *stop) {
        if ([predicate evaluateWithObject:accountName substitutionVariables:account]) {
            [self.accounts removeObjectAtIndex:index];
            *stop = YES;
            return;
        }
    }];
}

@end
