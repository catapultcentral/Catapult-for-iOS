//
//  CatapultCurrentAccountViewController.m
//  Catapult
//
//  Created by Aziz Light on 4/29/13.
//  Copyright (c) 2013 Catapult Technology Ltd. All rights reserved.
//

#import "CatapultCurrentAccountViewController.h"

@interface CatapultCurrentAccountViewController ()

@end

@implementation CatapultCurrentAccountViewController
{
    CatapultAccount *_accountModel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CatapultCurrentAccountTableViewController *tvc = [segue destinationViewController];
    tvc.parentLoadingView = self.loadingView;
    tvc.parentActivityIndicator = self.activityIndicator;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
