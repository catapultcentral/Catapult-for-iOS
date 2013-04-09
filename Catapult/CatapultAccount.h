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

- (BOOL)createAccountWithAccountID:(NSString *)accountID;

@end
