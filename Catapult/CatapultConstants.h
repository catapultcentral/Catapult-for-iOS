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
#define kDoorkeeperClientID     @"717539df0330898e0dfc854b7488d92e534e0aa39789738fa36a9b3d4ebf310d"
#define kDoorkeeperClientSecret @"e94065156822a5f17362f5a0c2fdd474bc03f3c75a7e5ade4b350de63a5fcd6e"
#define kDoorkeeperAuthURL      @"https://oauth.audii.me/oauth/authorize"
#define kDoorkeeperTokenURL     @"https://oauth.audii.me/oauth/token"
#define kDoorkeeperRedirectURL  @"catapultcentral://ios"
#define kCatapultAccountType    @"com.cataputlcentral.api"

// API
#define kCatapultHost           @"https://api.audii.me/api"

#else

#define kCatapultHost           @"https://api.catapultcentral.com/api"

#endif

#endif
