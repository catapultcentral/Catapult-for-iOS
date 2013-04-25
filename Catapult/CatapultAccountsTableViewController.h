//
//  CatapultAccountsTableViewController.h
//  Catapult
//
//  Created by Aziz Light on 4/9/13.
//  Copyright (c) 2013 Catapult Technology Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXOAuth2.h"
#import "CatapultConstants.h"
#import "NSString+URLEncoding.h"
#import "CatapultAccount.h"
#import "CatapultAddAccountWebViewController.h"

@interface CatapultAccountsTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *accounts;

- (void)signInWithCatapult:(id)sender;

- (void)signOut:(void (^)(void))callback;

@end
