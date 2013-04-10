//
//  CatapultAddAccountWebViewController.h
//  Catapult
//
//  Created by Aziz Light on 4/9/13.
//  Copyright (c) 2013 Catapult Technology Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXOAuth2.h"
#import "CatapultAccount.h"

@interface CatapultAddAccountWebViewController : UIViewController <UIAlertViewDelegate>

@property (weak, nonatomic) NSURL *url;

@property (strong, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)cancel:(id)sender;

@end
