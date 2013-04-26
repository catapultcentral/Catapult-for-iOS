//
//  CatapultAddAccountWebViewController.m
//  Catapult
//
//  Created by Aziz Light on 4/9/13.
//  Copyright (c) 2013 Catapult Technology Ltd. All rights reserved.
//

#import "CatapultAddAccountWebViewController.h"

@interface CatapultAddAccountWebViewController ()

- (void)createAccount:(NSNotification *)notification;

@end

@implementation CatapultAddAccountWebViewController
{
    CatapultAccount *_accountModel;
    id _accountDidChangeObserver;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _accountModel = [[CatapultAccount alloc] init];
    
    // Load the authentication request in the web view
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    
    self.webView.delegate = self;
    
    [self.webView loadRequest:request];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _accountDidChangeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreAccountsDidChangeNotification
                                                                                  object:[NXOAuth2AccountStore sharedStore]
                                                                                   queue:nil
                                                                              usingBlock:^(NSNotification *aNotification){
                                                                                  if (aNotification.userInfo != nil) {
                                                                                      // Only create an account if a new account was added.
                                                                                      // Explanation: This notification will also be triggered on account removal
                                                                                      [self performSelector:@selector(createAccount:) withObject:aNotification];
                                                                                  }
                                                                              }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:_accountDidChangeObserver];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
#if DEBUG
    NSLog(@"ERROR: %@", error);
#endif
    if (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"]) return;
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createAccount:(NSNotification *)notification
{
    NXOAuth2Account *keychainAccount = [notification.userInfo objectForKey:@"NXOAuth2AccountStoreNewAccountUserInfoKey"];
    
    __weak typeof(self) weakSelf = self;
    
    if ([self.loginType isEqualToString:kCatapultFirstLogInType]) {
        [_accountModel createAccountWithAccountID:keychainAccount.identifier andThenComplete:^ (BOOL completed, NSDictionary *account) {
            if (completed) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kCatapultAccountCreatedNotification
                                                                    object:self
                                                                  userInfo:account];
                
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                NSError *error = [_accountModel lastError];

                NSString *alertTitle;
                NSString *alertMessage;
                
                if (error != nil && error.code == kCatapultDuplicateAccountErrorCode) {
                    alertTitle = @"Duplicate account error";
                    alertMessage = @"You have already added this account";
                } else {
                    alertTitle = @"Account error";
                    alertMessage = @"Unable to add new account";
                }
                
                UIAlertView *errorMessage = [[UIAlertView alloc] initWithTitle:alertTitle
                                                                       message:alertMessage
                                                                      delegate:weakSelf
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles:nil];
                
                [errorMessage show];
            }
        }];
    } else if ([self.loginType isEqualToString:kCatapultSubsequentLogInType])
    {
        [_accountModel setAccountAsCurrentUsingClientName:self.clientName userName:self.userName andAccountID:keychainAccount.identifier andThenComplete:^ (BOOL completed, NSDictionary *account) {
            if (completed) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kCatapultAccountLoggedInNotification
                                                                    object:nil
                                                                  userInfo:account];
            } else {
#if DEBUG
                NSLog(@"Error: The account was not found in the SQLite DB...");
#endif
                UIAlertView *errorMessage = [[UIAlertView alloc] initWithTitle:@"Login error"
                                                                       message:@"Unable to log in the account"
                                                                      delegate:weakSelf
                                                             cancelButtonTitle:@"OK"
                                                             otherButtonTitles:nil];
                
                [errorMessage show];
            }
        }];
        
        
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end