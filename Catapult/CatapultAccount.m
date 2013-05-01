//
//  CatapultAccount.m
//  Catapult
//
//  Created by Aziz Light on 4/9/13.
//  Copyright (c) 2013 Catapult Technology Ltd. All rights reserved.
//

#import "CatapultAccount.h"

@interface CatapultAccount ()

- (BOOL)createAccountsTable;

- (BOOL)accountWithNameIsAlreadyAdded:(NSString *)accountName;

- (NSDictionary *)getAccountLogosForClient:(NSDictionary *)client;

- (NSString *)getAccountLogoFromURL:(NSURL *)url;

- (NSString *)saveImage:(UIImage *)image
           withFileName:(NSString *)imageName
                 ofType:(NSString *)extension
            inDirectory:(NSString *)directoryPath;

@end

@implementation CatapultAccount

- (void)createAccountWithAccountID:(NSString *)accountID andThenComplete:(void (^)(BOOL, NSDictionary *))completion
{
    __block BOOL operationSuccessfull = NO;
    __block NSDictionary *createdAccount = nil;
    
    NXOAuth2Account *account = [[NXOAuth2AccountStore sharedStore] accountWithIdentifier:accountID];
    
    // NOTE: Here, I am not checking if accont is nil, but that shouldn't be a problem
    
    [NXOAuth2Request performMethod:@"GET"
                        onResource:[NSURL URLWithString:[NSString stringWithFormat:@"%@/users/me", kCatapultHost]]
                   usingParameters:nil
                       withAccount:account
               sendProgressHandler:nil
                   responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                       if (error != nil) {
                           operationSuccessfull = NO;
#if DEBUG
                           NSLog(@"ERROR: %@", error);
#endif
                           _lastError = error;
                       } else {
                           NSError *jsonError;
                           
                           NSDictionary *serializedResponse = [NSJSONSerialization JSONObjectWithData:responseData
                                                                                              options:kNilOptions
                                                                                                error:&jsonError];
                           
                           if (jsonError != nil) {
                               operationSuccessfull = NO;
#if DEBUG
                               NSLog(@"ERROR: %@", jsonError);
#endif
                               _lastError = jsonError;
                           } else {
                               NSDictionary *user   = [serializedResponse objectForKey:@"user"];
                               NSDictionary *client = [serializedResponse objectForKey:@"client"];
                               
                               NSString *forename    = [user objectForKey:@"forename"];
                               NSString *surname     = [user objectForKey:@"surname"];
                               NSString *accountName = [client objectForKey:@"account_name"];
                               NSString *clientName  = [client objectForKey:@"client_name"];
                               
                               if ([self openDatabaseConnection]) {
                                   if ([self createAccountsTable]) {
                                       if ([self accountWithNameIsAlreadyAdded:accountName]) {
                                           operationSuccessfull = NO;
                                           
                                           _lastError = [NSError errorWithDomain:kCatapultAccountErrorDomain
                                                                            code:kCatapultDuplicateAccountErrorCode
                                                                        userInfo:@{@"message": @"You have already added this account"}];
                                           
#if DEBUG
                                           NSLog(@"ERROR: %@", _lastError);
#endif
                                       } else {
                                           NSDictionary *logos = [self getAccountLogosForClient:client];
                                           
                                           operationSuccessfull = [self.db executeUpdate:@"insert into accounts(account_id, forename, surname, account_name, client_name, smallest_logo, thumb_logo, logged_in) values(?,?,?,?,?,?,?,?)",
                                                                   accountID, forename, surname, accountName, clientName, logos[@"smallest_logo"], logos[@"thumb_logo"], @"1"];
                                           
                                           if (operationSuccessfull) {
                                               FMResultSet *savedAccount = [self.db executeQuery:@"select forename, surname, account_name, client_name, smallest_logo, thumb_logo from accounts where account_name = ? limit 1", accountName];
                                               
                                               if ([savedAccount next]) {
                                                   createdAccount = [savedAccount resultDictionary];
                                                   account.userData = createdAccount;
                                               }
                                           }
                                       }
                                   } else {
                                       operationSuccessfull = NO;
                                       
                                       _lastError = [NSError errorWithDomain:kCatapultDatabaseErrorDomain
                                                                        code:kCatapultUnableToCreateTableErrorCode
                                                                    userInfo:@{@"message": @"Unable to create the accounts table"}];
                                       
#if DEBUG
                                       NSLog(@"ERROR: %@", _lastError);
#endif
                                   }
                                   
                                   [self closeDatabaseConnection];
                               } else {
                                   operationSuccessfull = NO;
                                   
                                   _lastError = [NSError errorWithDomain:kCatapultDatabaseErrorDomain
                                                                    code:kCatapultUnableToOpenDatabaseConnectionErrorCode
                                                                userInfo:@{@"message": @"Unable to open database connection"}];
                                   
#if DEBUG
                                   NSLog(@"ERROR: %@", _lastError);
#endif
                               }
                           }
                       }
                       
                       completion(operationSuccessfull, createdAccount);
                   }];
}

// NOTE: Don't open/close the database in this method
- (BOOL)createAccountsTable
{
    BOOL operationSuccessful = NO;
    // Accounts table schema
    // id integer primary key autoincrement
    // account_id varchar(36) not null - unique
    // forename varchar(255) not null
    // surname varchar(255) not null
    // account_name varchar(255) not null - unique
    // client_name varchar(255) not null
    // smallest_account_logo text
    // thumb_account_logo text
    // logged_in char(1) not null
    
    operationSuccessful = [self.db executeUpdate:@"create table if not exists accounts(id integer primary key autoincrement, account_id varchar(36) not null, forename varchar(255) not null, surname varchar(255) not null, account_name varchar(255) not null, client_name varchar(255) not null, smallest_logo text, thumb_logo text, logged_in char(1) not null, unique(account_id) on conflict abort, unique(account_name) on conflict abort)"];
    
    if (operationSuccessful) {
        _lastError = nil;
    } else {
        _lastError = [self.db lastError];
#if DEBUG
        NSLog(@"Failed to create users table: %@", _lastError);
#endif
    }

    return operationSuccessful;
}

// NOTE: Don't open/close the database in this method
- (BOOL)accountWithNameIsAlreadyAdded:(NSString *)accountName
{
    FMResultSet *account = [self.db executeQuery:@"select count(*) from accounts where account_name = ?", accountName];
    
    int totalCount = 0;
    
    if ([account next]) {
        totalCount = [account intForColumnIndex:0];
    }
    
    return totalCount > 0;
}

- (NSDictionary *)getAccountLogosForClient:(NSDictionary *)client
{
    NSDictionary *returnValue = nil;
    
    NSString *smallestLogoURLString = [[[client objectForKey:@"logo"] objectForKey:@"smallest"] objectForKey:@"url"];
    NSString *thumbLogoURLString = [[[client objectForKey:@"logo"] objectForKey:@"thumb"] objectForKey:@"url"];
    if ([smallestLogoURLString class] != [NSNull class] && [thumbLogoURLString class] != [NSNull class]) {
        NSString *smallestLogoPath = [self getAccountLogoFromURL:[NSURL URLWithString:smallestLogoURLString]];
        NSString *thumbLogoPath = [self getAccountLogoFromURL:[NSURL URLWithString:thumbLogoURLString]];
        
        returnValue = @{@"smallest_logo": smallestLogoPath, @"thumb_logo": thumbLogoPath};
    }
    
    return returnValue;
}

- (NSString *)getAccountLogoFromURL:(NSURL *)url
{
    NSString *urlWithoutGETParams = [[[url absoluteString] componentsSeparatedByString:@"?"] objectAtIndex:0];
    NSString *lastSegmentOfURL = [[urlWithoutGETParams componentsSeparatedByString:@"/"] lastObject];
    NSString *logoName = [[lastSegmentOfURL componentsSeparatedByString:@"."] objectAtIndex:0];
    NSString *logoExtension =  [[lastSegmentOfURL componentsSeparatedByString:@"."] lastObject];
    
    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *logoPath = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", logoName, logoExtension]];
    
    BOOL logoExists = [[NSFileManager defaultManager] fileExistsAtPath:logoPath];
    
    if (logoExists) {
        return logoPath;
    } else {
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        UIImage *logo = [UIImage imageWithData:data];
        
        logoPath = [self saveImage:logo withFileName:logoName ofType:logoExtension inDirectory:documentsDirectoryPath];
        
        return (logoPath == nil) ? nil : logoPath;
    }
}

- (NSString *)saveImage:(UIImage *)image
           withFileName:(NSString *)imageName
                 ofType:(NSString *)extension
            inDirectory:(NSString *)directoryPath
{
    NSData *imageRepresentation;
    
    if ([[extension lowercaseString] isEqualToString:@"png"] || [[extension lowercaseString] isEqualToString:@"gif"]) {
        imageRepresentation = UIImagePNGRepresentation(image);
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        imageRepresentation = UIImageJPEGRepresentation(image, 1.0);
    } else {
#if DEBUG
        NSLog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG/GIF)", extension);
#endif
        return nil;
    }
    
    NSString *imagePath = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, extension]];
    
    NSError *error;
    BOOL imageDidSave = [imageRepresentation writeToFile:imagePath
                                                 options:NSAtomicWrite
                                                   error:&error];
    
    if (error != nil) {
#if DEBUG
        NSLog(@"Error saving the file: %@", error);
#endif
    }
    
    return (imageDidSave) ? imagePath : nil;
}

- (void)signInWithCatapult:(void (^)(BOOL, NSURL *))completion
{
    [self signOutFromCatapult:^ (BOOL completed) {
        if (completed) {
            [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:kCatapultAccountType
                                           withPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
                                               completion(YES, preparedURL);
                                           }];
        } else {
            completion(NO, nil);
        }
    }];
}

- (void)signOutFromCatapult:(void (^)(BOOL))completion
{
    __block BOOL operationSuccessful = NO;
    
    NXOAuth2Account *account = [[[NXOAuth2AccountStore sharedStore] accounts] lastObject];
    
    if (account != nil) {
        [NXOAuth2Request performMethod:@"DELETE"
                            onResource:[NSURL URLWithString:[NSString stringWithFormat:@"%@/logout", kCatapultHost]]
                       usingParameters:nil
                           withAccount:account
                   sendProgressHandler:nil
                       responseHandler:^ (NSURLResponse *response, NSData *responseData, NSError *error) {
                           if (error != nil && error.code != 401) {
#if DEBUG
                               NSLog(@"ERROR: %@", error);
#endif
                           } else {
                               // Workaround.
                               if (error != nil && error.code == 401) {
                                   NSArray *accounts = [[NXOAuth2AccountStore sharedStore] accounts];
                                   for (NXOAuth2Account *account in accounts) {
                                       [[NXOAuth2AccountStore sharedStore] removeAccount:account];
                                   }
                               }
                               
                               if ([self openDatabaseConnection]) {
                                   if ([self createAccountsTable]) {
                                       operationSuccessful = [self.db executeUpdate:@"update accounts set logged_in = 0 where logged_in = 1"];
                                       
                                       if (operationSuccessful) {
                                           [[NXOAuth2AccountStore sharedStore] removeAccount:account];
                                       } else {
#if DEBUG
                                           NSLog(@"Error: %@", [self.db lastError]);
#endif
                                       }
                                   } else {
                                       _lastError = [NSError errorWithDomain:kCatapultDatabaseErrorDomain
                                                                        code:kCatapultUnableToCreateTableErrorCode
                                                                    userInfo:@{@"message": @"Unable to create the accounts table"}];
                                       
#if DEBUG
                                       NSLog(@"ERROR: %@", _lastError);
#endif
                                   }
                                   
                                   
                                   [self closeDatabaseConnection];
                               } else {
                                   _lastError = [NSError errorWithDomain:kCatapultDatabaseErrorDomain
                                                                    code:kCatapultUnableToOpenDatabaseConnectionErrorCode
                                                                userInfo:@{@"message": @"Unable to open database connection"}];
                                   
#if DEBUG
                                   NSLog(@"ERROR: %@", _lastError);
#endif
                               }
                           }
                           
                           completion(operationSuccessful);
                       }];
    } else {
        completion(YES);
    }
}

- (NSArray *)getAllAccountsExceptCurrentOne:(NSString *)currentAccountName
{
    NSMutableArray *results = nil;
    
    if ([self openDatabaseConnection]) {
        if ([self createAccountsTable]) {
            results = [NSMutableArray array];
            
            FMResultSet *resultSet = [self.db executeQuery:@"select forename, surname, account_name, client_name, smallest_logo, thumb_logo from accounts where account_name != ?", currentAccountName];
            
            while ([resultSet next]) {
                [results addObject:[resultSet resultDictionary]];
            }
        } else {
            _lastError = [NSError errorWithDomain:kCatapultDatabaseErrorDomain
                                             code:kCatapultUnableToCreateTableErrorCode
                                         userInfo:@{@"message": @"Unable to create the accounts table"}];
            
#if DEBUG
            NSLog(@"ERROR: %@", _lastError);
#endif
        }
        
        [self closeDatabaseConnection];
    } else {
        _lastError = [NSError errorWithDomain:kCatapultDatabaseErrorDomain
                                         code:kCatapultUnableToOpenDatabaseConnectionErrorCode
                                     userInfo:@{@"message": @"Unable to open database connection"}];
        
#if DEBUG
        NSLog(@"ERROR: %@", _lastError);
#endif
    }
    
    return results;
}

- (NSArray *)getAllAccounts
{
    return [self getAllAccountsExceptCurrentOne:@""];
}

- (NSDictionary *)getCurrentAccount
{
    NXOAuth2Account *currentNXOAuth2Account = [[[NXOAuth2AccountStore sharedStore] accounts] lastObject];
    
    return (NSDictionary *)[currentNXOAuth2Account userData];
}

- (void)getCurrentClient:(void (^)(BOOL completed, NSDictionary *account, NSDictionary *user))completion
{
    __block NSMutableDictionary *currentClient = nil;
    
    NXOAuth2Account *currentAccount = [[[NXOAuth2AccountStore sharedStore] accounts] lastObject];
    
    [NXOAuth2Request performMethod:@"GET"
                        onResource:[NSURL URLWithString:[NSString stringWithFormat:@"%@/clients/%@", kCatapultHost, currentAccount.userData[@"account_name"]]]
                   usingParameters:nil
                       withAccount:currentAccount
               sendProgressHandler:nil
                   responseHandler:^ (NSURLResponse *response, NSData *responseData, NSError *error) {
                       if (error != nil) {
#if DEBUG
                           NSLog(@"ERROR: %@", error);
#endif
                           completion(NO, nil, nil);
                       }
                       else {
                           NSError *jsonError;
                           
                           currentClient = [NSJSONSerialization JSONObjectWithData:responseData
                                                                            options:kNilOptions
                                                                              error:&jsonError];
                           
                           if (jsonError != nil) {
#if DEBUG
                               NSLog(@"Error: %@", jsonError);
#endif
                               completion(NO, nil, nil);
                           } else {
                               [self getCurrentUser:^ (BOOL completed, NSDictionary *user) {
                                   if (completed) {
                                       completion(YES, currentClient, user);
                                   } else {
                                       completion(NO, nil, nil);
                                   }
                               }];
                           }
                       }
                   }];
}

- (void)getCurrentUser:(void (^)(BOOL completed, NSDictionary *user))completion
{
    __block BOOL operationSuccessful = NO;
    __block NSDictionary *currentUser = nil;
    NXOAuth2Account *currentAccount = [[[NXOAuth2AccountStore sharedStore] accounts] lastObject];
    
    [NXOAuth2Request performMethod:@"GET"
                        onResource:[NSURL URLWithString:[NSString stringWithFormat:@"%@/users/me/full", kCatapultHost]]
                   usingParameters:nil
                       withAccount:currentAccount
               sendProgressHandler:nil
                   responseHandler:^ (NSURLResponse *response, NSData *responseData, NSError *error) {
                       if (error != nil) {
                           operationSuccessful = NO;
#if DEBUG
                           NSLog(@"Error: %@", error);
#endif
                       } else {
                           operationSuccessful = YES;
                           
                           NSError *jsonError;
                           
                           currentUser = [NSJSONSerialization JSONObjectWithData:responseData
                                                                         options:kNilOptions
                                                                           error:&jsonError];
                           
                           if (jsonError != nil) {
                               operationSuccessful = NO;
#if DEBUG
                               NSLog(@"Error: %@", jsonError);
#endif
                           }
                       }
                       
                       completion(operationSuccessful, currentUser);
                   }];
}

- (NSString *)getAccountNameForAccountWithClientName:(NSString *)clientName andUserName:(NSString *)userName
{
    NSString *accountName = nil;
    
    if ([self openDatabaseConnection]) {
        if ([self createAccountsTable]) {
            FMResultSet *result = [self.db executeQuery:@"select account_name from accounts where client_name = ? and (forename || \" \" || surname = ?)", clientName, userName];
            
            NSDictionary *account = nil;
            
            if ([result next]) {
                account = [result resultDictionary];
            }
            
            if (account != nil) {
                accountName = [account objectForKey:@"account_name"];
            }
        } else {
            _lastError = [NSError errorWithDomain:kCatapultDatabaseErrorDomain
                                             code:kCatapultUnableToCreateTableErrorCode
                                         userInfo:@{@"message": @"Unable to create the accounts table"}];
            
#if DEBUG
            NSLog(@"ERROR: %@", _lastError);
#endif
        }
    } else {
        _lastError = [NSError errorWithDomain:kCatapultDatabaseErrorDomain
                                         code:kCatapultUnableToOpenDatabaseConnectionErrorCode
                                     userInfo:@{@"message": @"Unable to open database connection"}];
        
#if DEBUG
        NSLog(@"ERROR: %@", _lastError);
#endif
    }
    
    return accountName;
}

- (BOOL)deleteAccountWithClientName:(NSString *)clientName andUserName:(NSString *)userName
{
    BOOL accountDeleted = NO;
    
    if ([self openDatabaseConnection]) {
        if ([self createAccountsTable]) {
            accountDeleted = [self.db executeUpdate:@"delete from accounts where client_name = ? and (forename || \" \" || surname = ?)", clientName, userName];
            
            if (!accountDeleted) {
                _lastError = [self.db lastError];
                
#if DEBUG
                NSLog(@"ERROR: %@", _lastError);
#endif
            }    
        } else {
            _lastError = [NSError errorWithDomain:kCatapultDatabaseErrorDomain
                                             code:kCatapultUnableToCreateTableErrorCode
                                         userInfo:@{@"message": @"Unable to create the accounts table"}];
            
#if DEBUG
            NSLog(@"ERROR: %@", _lastError);
#endif
        }
        
        [self closeDatabaseConnection];
    } else {
        _lastError = [NSError errorWithDomain:kCatapultDatabaseErrorDomain
                                         code:kCatapultUnableToOpenDatabaseConnectionErrorCode
                                     userInfo:@{@"message": @"Unable to open database connection"}];
        
#if DEBUG
        NSLog(@"ERROR: %@", _lastError);
#endif
    }
    
    return accountDeleted;
}

- (void)setAccountAsCurrentUsingClientName:(NSString *)clientName userName:(NSString *)userName andAccountID:(NSString *)accountID andThenComplete:(void (^)(BOOL completed, NSDictionary *account))completion
{
    BOOL operationSuccessfull = NO;
    NSDictionary *account = nil;

    if ([self openDatabaseConnection]) {
        if ([self createAccountsTable]) {
            NXOAuth2Account *keychainAccount = [[NXOAuth2AccountStore sharedStore] accountWithIdentifier:accountID];
            
            operationSuccessfull = [self.db executeUpdate:@"update accounts set logged_in = 1 where client_name = ? and (forename || \" \" || surname = ?)", clientName, userName];
            
            if (operationSuccessfull) {
                FMResultSet *currentAccount = [self.db executeQuery:@"select forename, surname, account_name, client_name, smallest_logo, thumb_logo from accounts where logged_in = 1 limit 1"];
                
                if ([currentAccount next]) {
                    account = [currentAccount resultDictionary];
                    keychainAccount.userData = account;
                }
            } else {
                _lastError = [self.db lastError];
                
#if DEBUG
                NSLog(@"ERROR: %@", _lastError);
#endif
            }
        } else {
            _lastError = [NSError errorWithDomain:kCatapultDatabaseErrorDomain
                                             code:kCatapultUnableToCreateTableErrorCode
                                         userInfo:@{@"message": @"Unable to create the accounts table"}];
            
#if DEBUG
            NSLog(@"ERROR: %@", _lastError);
#endif
        }
        
        [self closeDatabaseConnection];
    } else {
        _lastError = [NSError errorWithDomain:kCatapultDatabaseErrorDomain
                                         code:kCatapultUnableToOpenDatabaseConnectionErrorCode
                                     userInfo:@{@"message": @"Unable to open database connection"}];
        
#if DEBUG
        NSLog(@"ERROR: %@", _lastError);
#endif
    }
    
    completion(operationSuccessfull, account);
}

@end
