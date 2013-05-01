//
//  CatapultCurrentAccountTableViewController.m
//  Catapult
//
//  Created by Aziz Light on 4/26/13.
//  Copyright (c) 2013 Catapult Technology Ltd. All rights reserved.
//

#import "CatapultCurrentAccountTableViewController.h"

@interface CatapultCurrentAccountTableViewController ()

- (NSString *)extractAndFormatRailsDateTime:(NSString *)theDate;

@end

@implementation CatapultCurrentAccountTableViewController
{
    CatapultAccount *_accountModel;
    NSDictionary *_account;
    NSDictionary *_user;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self startAnimatingActivityIndicator];
    
    _accountModel = [[CatapultAccount alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_accountModel getCurrentClient:^ (BOOL completed, NSDictionary *currentAccount, NSDictionary *currentUser) {
        if (completed) {
            _account = currentAccount;
            _user = currentUser;
            
            //            NSLog(@"Account: %@", _account);
            //            NSLog(@"User: %@", _user);
            
            [self.tableView reloadData];
            
            [self stopAnimatingActivityIndicator];
        } else {
            UIAlertView *errorMessage = [[UIAlertView alloc] initWithTitle:@"Account retrieval unsuccessful"
                                                                   message:@"Unable to retrieve current account information"
                                                                  delegate:self
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil];
            
            [self stopAnimatingActivityIndicator];
            
            [errorMessage show];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    NSString *cellDetailText;
    
    if (indexPath.section == kCatapultAccountDetailsSection) {
        switch (indexPath.row) {
            case kCatapultAccountClientName:
            {
                cellDetailText = _account[@"client"][@"client_name"];
                break;
            }
            case kCatapultAccountAccountName:
            {
                cellDetailText = _account[@"client"][@"account_name"];
                break;
            }
            case kCatapultAccountClientSince:
            {
                cellDetailText = [self extractAndFormatRailsDateTime:_account[@"client"][@"created_at"]];
                break;
            }
            case kCatapultAccountAffiliateCode:
            {
                NSString *affiliateCode = _account[@"client"][@"affiliate_code"];
                
                cellDetailText = ([affiliateCode class] == [NSNull class] || affiliateCode == nil) ? @"None" : affiliateCode;
                break;
            }
        }
    } else if (indexPath.section == kCatapultOwnerDetailsSection) {
        switch (indexPath.row) {
            case kCatapultOwnerForename:
            {
                cellDetailText = _account[@"client"][@"forename"];
                break;
            }
            case kCatapultOwnerSurname:
            {
                cellDetailText = _account[@"client"][@"surname"];
                break;
            }
            case kCatapultOwnerEmail:
            {
                cellDetailText = _account[@"client"][@"email_address"];
                break;
            }
            case kCatapultOwnerPhoneNumber:
            {
                cellDetailText = _account[@"client"][@"phone_number"];
                break;
            }
        }
    } else if (indexPath.section == kCatapultPlanDetailsSection) {
        switch (indexPath.row) {
            case kCatapultPlanPlan:
            {
                cellDetailText = _account[@"plan"][@"name"];
                break;
            }
            case kCatapultPlanPrice:
            {
                NSString *price = _account[@"plan"][@"price"];

                cellDetailText = ([price doubleValue] > 0) ? price : @"Free";
                break;
            }
            case kCatapultPlanMaxUsers:
            {
                NSString *maxUsers = _account[@"plan"][@"max_users"];
                
                cellDetailText = ([maxUsers intValue] > 9999) ? @"Unlimited" : maxUsers;
                break;
            }
            case kCatapultPlanMaxContacts:
            {
                NSString *maxContacts = _account[@"plan"][@"max_contacts"];
                
                cellDetailText = ([maxContacts intValue] > 9999) ? @"Unlimited" : maxContacts;
                break;
            }
            case kCatapultPlanMaxStorage:
            {
                NSString *maxStorage = _account[@"plan"][@"max_storage"];
                
                cellDetailText = ([maxStorage intValue] > 9999) ? @"Unlimited" : maxStorage;
                break;
            }
        }
    } else if (indexPath.section == kCatapultUserDetailsSection) {
        switch (indexPath.row) {
            case kCatapultUserForename:
            {
                cellDetailText = _user[@"forename"];
                break;
            }
            case kCatapultUserSurname:
            {
                cellDetailText = _user[@"surname"];
                break;
            }
            case kCatapultUserUsername:
            {
                cellDetailText = _user[@"user_name"];
                break;
            }
            case kCatapultUserEmail:
            {
                cellDetailText = _user[@"email"];
                break;
            }
            case kCatapultUserJobTitle:
            {
                NSString *jobTitle = _user[@"job_title"];
                
                cellDetailText = ([jobTitle class] == [NSNull class] || jobTitle == nil) ? @"Unknown" : jobTitle;
                break;
            }
            case kCatapultUserBirthday:
            {
                NSString *birthday = _user[@"birthday"];
                
                cellDetailText = ([birthday class] == [NSNull class] || birthday == nil) ? @"Unknown" : [self extractAndFormatRailsDateTime:birthday];
                break;
            }
            case kCatapultUserJoinedOn:
            {
                cellDetailText = [self extractAndFormatRailsDateTime:_user[@"created_at"]];
                break;
            }
            case kCatapultUserLastUpdated:
            {
                cellDetailText = [self extractAndFormatRailsDateTime:_user[@"updated_at"]];
                break;
            }
            case kCatapultUserRole:
            {
                cellDetailText = ([_user[@"admin"] intValue] == 1) ? @"Administrator" : @"User";
                break;
            }
        }
    }
    
    cell.detailTextLabel.text = cellDetailText;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 80.0;
    } else {
        return [super tableView:tableView heightForHeaderInSection:section];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
//    if (section == 0) {
//        NSDictionary *account = (NSDictionary *)_account.userData;
//        NSString *logoPath = account[@"thumb_logo"];
//        UIImage *logo = [UIImage imageWithContentsOfFile:logoPath];
//        UIImageView* headerView = [[UIImageView alloc] initWithImage:logo];
//        headerView.contentMode = UIViewContentModeCenter;
//        return headerView;
//    } else {
        return [super tableView:tableView viewForHeaderInSection:section];
//    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)startAnimatingActivityIndicator
{
    [self.parentActivityIndicator startAnimating];
    [UIView beginAnimations:@"fadein" context:nil];
    [UIView setAnimationDuration:0.3];
    self.parentLoadingView.alpha = 1;
    [UIView commitAnimations];
    
}

- (void)stopAnimatingActivityIndicator
{
    [self.parentActivityIndicator stopAnimating];
    [UIView beginAnimations:@"fadeout" context:nil];
    [UIView setAnimationDuration:0.3];
    self.parentLoadingView.alpha = 0.0;
    [UIView commitAnimations];
}

- (NSString *)extractAndFormatRailsDateTime:(NSString *)theDate
{
    theDate = [theDate stringByReplacingOccurrencesOfString:@":" withString:@""];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HHmmssZZ";
    
    NSDate *theDateObject = [dateFormatter dateFromString:theDate];
    dateFormatter.dateFormat = @"MMMM d, yyyy";
    
    return [dateFormatter stringFromDate:theDateObject];
}

@end
