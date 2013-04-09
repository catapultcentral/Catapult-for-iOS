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
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreAccountsDidChangeNotification
                                                      object:[NXOAuth2AccountStore sharedStore]
                                                       queue:nil
                                                  usingBlock:^(NSNotification *aNotification){
                                                      if (aNotification.userInfo != nil) {
                                                          // Only create an account if a new account was added.
                                                          // Explanation: This notification will also be triggered on account removal
                                                          [self performSelector:@selector(createAccount:) withObject:aNotification];
                                                      }
                                                  }];
    
    _accountModel = [[CatapultAccount alloc] init];
    
	// Do any additional setup after loading the view.
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createAccount:(NSNotification *)notification
{
    NXOAuth2Account *account = [notification.userInfo objectForKey:@"NXOAuth2AccountStoreNewAccountUserInfoKey"];
    
    [_accountModel createAccountWithAccountID:account.identifier andThenComplete:^ (BOOL completed) {
        if (completed) {
            // Do something
            NSLog(@"Yay");
        } else {
            // Delete the newly created account
            [[NXOAuth2AccountStore sharedStore] removeAccount:account];
            
            UIAlertView *errorMessage = [[UIAlertView alloc] initWithTitle:@"Account Error"
                                                                   message:@"Unable to add new account"
                                                                  delegate:nil
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
            
            [errorMessage show];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end