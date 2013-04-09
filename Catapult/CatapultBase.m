//
//  CatapultBase.m
//  Catapult
//
//  Created by Aziz Light on 4/9/13.
//  Copyright (c) 2013 Catapult Technology Ltd. All rights reserved.
//

#import "CatapultBase.h"

@implementation CatapultBase

- (id)init
{
    self = [super init];
    if (self) {
        // Setup the database. Create it if it doesn't exist.
        NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dbPath = [documentsDirectoryPath stringByAppendingPathComponent:@"catapultcentral.sqlite"];
        self.db = [FMDatabase databaseWithPath:dbPath];
    }
    return self;
}

- (BOOL)openDatabaseConnection
{
    if (![self.db open]) {
        _lastError = [self.db lastError];
#if DEBUG
        NSLog(@"Failed to open database: %@", _lastError);
#endif
        
        return NO;
    } else {
        _lastError = nil;
        
        return YES;
    }
}

- (void)closeDatabaseConnection
{
    [self.db close];
}

- (NSError *)lastError
{
    return _lastError;
}

@end
