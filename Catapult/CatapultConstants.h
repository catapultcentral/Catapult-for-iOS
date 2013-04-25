//
//  CatapultConstants.h
//  Catapult
//
//  Created by Aziz Light on 4/9/13.
//  Copyright (c) 2013 Catapult Technology Ltd. All rights reserved.
//

#ifndef Catapult_CatapultConstants_h
#define Catapult_CatapultConstants_h

#if DEBUG

// API authentication
#define kDoorkeeperClientID     @"9eb5646b4570b13f2152cb4612ba2c163f701f10b5d144b91b02ef3924738138"
#define kDoorkeeperClientSecret @"cc80eca9688dc00947b6878b562acb00ebaf407707ce41924f2157a618cd75da"
#define kDoorkeeperAuthURL      @"https://oauth.audii.me/oauth/authorize"
#define kDoorkeeperTokenURL     @"https://oauth.audii.me/oauth/token"
#define kDoorkeeperRedirectURL  @"catapultcentral://ios"
#define kCatapultAccountType    @"com.cataputlcentral.api"

// API
#define kCatapultHost           @"https://api.audii.me/api"

#else

#define kCatapultHost           @"https://api.catapultcentral.com/api"

#endif

// Custom error domains
#define kCatapultAccountErrorDomain  @"com.catapultcentral.Catapult.AccountErrorDomain"
#define kCatapultDatabaseErrorDomain @"com.catapultcentral.Catapult.DatabaseErrorDomain"

// iOS client
#define kCatapultAccountCreatedNotification @"CatapultAccountCreated"
#define kCatapultAccountLoggedInNotification @"CatapultAccountLoggedIn"

#endif
