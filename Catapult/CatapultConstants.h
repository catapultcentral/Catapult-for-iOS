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
#define kDoorkeeperClientID     @"9ba84746010a85491f9ac33728690ba78d2967b6a43ea4cd18ea2d566be65ba9"
#define kDoorkeeperClientSecret @"3e7597673b817f2deda63f2050bb3f4a3976bf47a45dd8e59aaa4761033a492c"
#define kDoorkeeperAuthURL      @"https://oauth.lvh.me:3000/oauth/authorize"
#define kDoorkeeperTokenURL     @"https://oauth.lvh.me:3000/oauth/token"
#define kDoorkeeperRedirectURL  @"catapultcentral://ios"
#define kCatapultAccountType    @"com.cataputlcentral.api"

// API
#define kCatapultHost           @"https://api.lvh.me:3000/api"

// Custom error domains
#define kCatapultAccountErrorDomain  @"com.catapultcentral.Catapult.AccountErrorDomain"
#define kCatapultDatabaseErrorDomain @"com.catapultcentral.Catapult.DatabaseErrorDomain"

#else

#define kCatapultHost           @"https://api.catapultcentral.com/api"

#endif

#endif
