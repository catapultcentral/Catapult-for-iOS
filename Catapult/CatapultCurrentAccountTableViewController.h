//
//  CatapultCurrentAccountTableViewController.h
//  Catapult
//
//  Created by Aziz Light on 4/26/13.
//  Copyright (c) 2013 Catapult Technology Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXOAuth2.h"
#import "CatapultAccount.h"

// Sections constants
#define kCatapultAccountDetailsSection 1
#define kCatapultOwnerDetailsSection 2
#define kCatapultPlanDetailsSection 3
#define kCatapultUserDetailsSection 4

// Account details rows constants
#define kCatapultAccountClientName 0
#define kCatapultAccountAccountName 1
#define kCatapultAccountClientSince 2
#define kCatapultAccountAffiliateCode 3

// Owner details rows constants
#define kCatapultOwnerForename 0
#define kCatapultOwnerSurname 1
#define kCatapultOwnerEmail 2
#define kCatapultOwnerPhoneNumber 3

// Plan details rows constants
#define kCatapultPlanPlan 0
#define kCatapultPlanPrice 1
#define kCatapultPlanMaxUsers 2
#define kCatapultPlanMaxContacts 3
#define kCatapultPlanMaxStorage 4

// User details rows constants
#define kCatapultUserForename 0
#define kCatapultUserSurname 1
#define kCatapultUserUsername 2
#define kCatapultUserEmail 3
#define kCatapultUserJobTitle 4
#define kCatapultUserBirthday 5
#define kCatapultUserJoinedOn 6
#define kCatapultUserLastUpdated 7
#define kCatapultUserRole 8

@interface CatapultCurrentAccountTableViewController : UITableViewController

@property (strong, nonatomic) UIView *parentLoadingView;
@property (strong, nonatomic) UIActivityIndicatorView *parentActivityIndicator;

@end
