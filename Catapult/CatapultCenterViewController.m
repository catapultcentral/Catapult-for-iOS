//
//  CatapultCenterViewController.m
//  Catapult
//
//  Created by Aziz Light on 4/8/13.
//  Copyright (c) 2013 Catapult Technology Ltd. All rights reserved.
//

#import "CatapultCenterViewController.h"

@interface CatapultCenterViewController ()

@end

@implementation CatapultCenterViewController

- (IBAction)showMenu:(id)sender
{
    [self.sidePanelController toggleLeftPanel:sender];
}

@end
