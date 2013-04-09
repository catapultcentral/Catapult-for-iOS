//
//  CatapultCenterTableViewController.m
//  Catapult
//
//  Created by Aziz Light on 4/9/13.
//  Copyright (c) 2013 Catapult Technology Ltd. All rights reserved.
//

#import "CatapultCenterTableViewController.h"

@interface CatapultCenterTableViewController ()

@end

@implementation CatapultCenterTableViewController

- (IBAction)showMenu:(id)sender
{
    [self.sidePanelController toggleLeftPanel:sender];
}

@end
