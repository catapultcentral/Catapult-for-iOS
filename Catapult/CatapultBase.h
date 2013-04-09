//
//  CatapultBase.h
//  Catapult
//
//  Created by Aziz Light on 4/9/13.
//  Copyright (c) 2013 Catapult Technology Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

// Constants specific to that model and its subclasses
#define kCatapultUnableToOpenDatabaseConnectionErrorCode 1
#define kCatapultUnableToCreateTableErrorCode 2

#define kCatapultDuplicateAccountErrorCode 3

@interface CatapultBase : NSObject
{
    @protected
    
    NSError *_lastError;
}

@property FMDatabase *db;

- (BOOL)openDatabaseConnection;

- (void)closeDatabaseConnection;

- (NSError *)lastError;

@end
