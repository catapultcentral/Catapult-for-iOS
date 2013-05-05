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
    NSMutableArray *_dataSource;
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
            _dataSource = [[NSMutableArray alloc] init];
            
            _dataSource[kCatapultCurrentAccountHeaderSection] = [[NSArray alloc] init];
            _dataSource[kCatapultAccountDetailsSection]       = [[NSMutableArray alloc] init];
            _dataSource[kCatapultOwnerDetailsSection]         = [[NSMutableArray alloc] init];
            _dataSource[kCatapultPlanDetailsSection]          = [[NSMutableArray alloc] init];
            _dataSource[kCatapultUserDetailsSection]          = [[NSMutableArray alloc] init];
            
            _dataSource[kCatapultAccountDetailsSection][kCatapultAccountClientName] = currentAccount[@"client"][@"client_name"];
            _dataSource[kCatapultAccountDetailsSection][kCatapultAccountAccountName] = currentAccount[@"client"][@"account_name"];
            _dataSource[kCatapultAccountDetailsSection][kCatapultAccountClientSince] = [self extractAndFormatRailsDateTime:currentAccount[@"client"][@"created_at"]];
            _dataSource[kCatapultAccountDetailsSection][kCatapultAccountAffiliateCode] = ([currentAccount[@"client"][@"affiliate_code"] class] == [NSNull class] || currentAccount[@"client"][@"affiliate_code"] == nil) ? @"None" : currentAccount[@"client"][@"affiliate_code"];
            
            _dataSource[kCatapultOwnerDetailsSection][kCatapultOwnerForename] = currentAccount[@"client"][@"forename"];
            _dataSource[kCatapultOwnerDetailsSection][kCatapultOwnerSurname] = currentAccount[@"client"][@"surname"];
            _dataSource[kCatapultOwnerDetailsSection][kCatapultOwnerEmail] = currentAccount[@"client"][@"email_address"];
            _dataSource[kCatapultOwnerDetailsSection][kCatapultOwnerPhoneNumber] = currentAccount[@"client"][@"phone_number"];
            
            _dataSource[kCatapultPlanDetailsSection][kCatapultPlanPlan] = currentAccount[@"plan"][@"name"];
            _dataSource[kCatapultPlanDetailsSection][kCatapultPlanPrice] = ([currentAccount[@"plan"][@"price"] doubleValue] > 0) ? currentAccount[@"plan"][@"price"] : @"Free";
            _dataSource[kCatapultPlanDetailsSection][kCatapultPlanMaxUsers] = ([currentAccount[@"plan"][@"max_users"] intValue] > 9999) ? @"Unlimited" : currentAccount[@"plan"][@"max_users"];
            _dataSource[kCatapultPlanDetailsSection][kCatapultPlanMaxContacts] = ([currentAccount[@"plan"][@"max_contacts"] intValue] > 9999) ? @"Unlimited" : currentAccount[@"plan"][@"max_contacts"];
            _dataSource[kCatapultPlanDetailsSection][kCatapultPlanMaxStorage] = ([currentAccount[@"plan"][@"max_storage"] intValue] > 9999) ? @"Unlimited" : currentAccount[@"plan"][@"max_storage"];
            
            _dataSource[kCatapultUserDetailsSection][kCatapultUserForename] = currentUser[@"forename"];
            _dataSource[kCatapultUserDetailsSection][kCatapultUserSurname] = currentUser[@"surname"];
            _dataSource[kCatapultUserDetailsSection][kCatapultUserUsername] = currentUser[@"user_name"];
            _dataSource[kCatapultUserDetailsSection][kCatapultUserEmail] = currentUser[@"email"];
            _dataSource[kCatapultUserDetailsSection][kCatapultUserJobTitle] = ([currentUser[@"job_title"] class] == [NSNull class] || currentUser[@"job_title"] == nil) ? @"Unknown" : currentUser[@"job_title"];
            _dataSource[kCatapultUserDetailsSection][kCatapultUserBirthday] = ([currentUser[@"birthday"] class] == [NSNull class] || currentUser[@"birthday"] == nil) ? @"Unknown" : [self extractAndFormatRailsDateTime:currentUser[@"birthday"]];
            _dataSource[kCatapultUserDetailsSection][kCatapultUserJoinedOn] = [self extractAndFormatRailsDateTime:currentUser[@"created_at"]];
            _dataSource[kCatapultUserDetailsSection][kCatapultUserLastUpdated] = [self extractAndFormatRailsDateTime:currentUser[@"updated_at"]];
            _dataSource[kCatapultUserDetailsSection][kCatapultUserRole] = ([currentUser[@"admin"] intValue] == 1) ? @"Administrator" : @"User";

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
    
    cell.detailTextLabel.text = _dataSource[indexPath.section][indexPath.row];
    
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
    if (section == 0) {
        // TODO: Somehow refresh the image once in a while
        NSDictionary *account = (NSDictionary *)[[[[NXOAuth2AccountStore sharedStore] accounts] lastObject] userData];
        NSString *logoPath = account[@"thumb_logo"];
        UIImage *logo = [UIImage imageWithContentsOfFile:logoPath];
        UIImageView* headerView = [[UIImageView alloc] initWithImage:logo];
        headerView.contentMode = UIViewContentModeCenter;
        return headerView;
    } else {
        return [super tableView:tableView viewForHeaderInSection:section];
    }
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
