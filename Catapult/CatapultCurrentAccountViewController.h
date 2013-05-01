//
//  CatapultCurrentAccountViewController.h
//  Catapult
//
//  Created by Aziz Light on 4/29/13.
//  Copyright (c) 2013 Catapult Technology Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXOAuth2.h"
#import "CatapultAccount.h"
#import "CatapultCurrentAccountTableViewController.h"

@interface CatapultCurrentAccountViewController : UIViewController <UIAlertViewDelegate>


@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *loadingLabel;

@end
