//
//  CatapultAccount.h
//  Catapult
//
//  Created by Aziz Light on 4/9/13.
//  Copyright (c) 2013 Catapult Technology Ltd. All rights reserved.
//

#import "CatapultBase.h"
#import "NXOAuth2.h"
#import "CatapultConstants.h"

@interface CatapultAccount : CatapultBase

- (void)createAccountWithAccountID:(NSString *)accountID andThenComplete:(void (^)(BOOL completed))completion;

- (void)signInWithCatapult:(void (^)(BOOL completed, NSURL *preparedURL))completion;

- (void)signOutFromCatapult:(void (^)(BOOL completed))completion;

@end
