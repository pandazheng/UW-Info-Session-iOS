//
//  MyInfoViewController.m
//  UW Info
//
//  Created by Zhang Honghao on 2/10/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "MyInfoViewController.h"
#import "InfoSessionCell.h"
#import "InfoSessionModel.h"
#import "LoadingCell.h"
#import "DetailViewController.h"
#import "UWTabBarController.h"
#import "InfoSessionsViewController.h"

@interface MyInfoViewController ()

@end

@implementation MyInfoViewController {
    UIRefreshControl *refreshControl;
    UIBarButtonItem *editButton;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _tabBarController.lastTapped = -1;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSLog(@"MyInfoVC DidLoad");
    [self.navigationController.navigationBar performSelector:@selector(setBarTintColor:) withObject:[UIColor colorWithRed:255/255 green:221.11/255 blue:0 alpha:1.0]];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    
    // initiate the right buttons
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(enterEditMode:)] animated:YES];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadTable) forControlEvents:UIControlEventValueChanged];
    [self reloadTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadTable {
    [self.tableView reloadData];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    // end refreshControl
    [self.refreshControl endRefreshing];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_infoSessionModel == nil || [_infoSessionModel.myInfoSessions count] == 0 ){
        return 1;
    } else {
        return [_infoSessionModel.myInfoSessions count];
    };
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_infoSessionModel == nil || [_infoSessionModel.myInfoSessions count] == 0) {
        LoadingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EmptyCell"];
        
        // set the label vertically align center.
        CGRect newFrame = cell.loadingLabel.frame;
        newFrame.origin.y = [self tableView:tableView heightForRowAtIndexPath:indexPath] / 2 - cell.loadingLabel.frame.size.height / 2;
        cell.loadingLabel.frame = newFrame;
        
        return cell;
    } else {
        InfoSessionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoSessionCell"];
        [self configureCell:cell withIndexPath:indexPath];
        return cell;
    }
}

/**
 *  Configure InfoSessionCell
 *
 *  @param cell      InfoSessionCell
 *  @param indexPath IndexPath for the cell
 */
- (void)configureCell:(InfoSessionCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    InfoSession *infoSession = [_infoSessionModel.myInfoSessions objectAtIndex:indexPath.row];
    
    // if current time is befor start time, set dark (future sessions)
    if ([[NSDate date] compare:infoSession.startTime] == NSOrderedAscending) {
        [cell.employer setTextColor:[UIColor blackColor]];
        [cell.locationLabel setTextColor:[UIColor darkGrayColor]];
        [cell.location setTextColor:[UIColor darkGrayColor]];
        [cell.dateLabel setTextColor:[UIColor darkGrayColor]];
        [cell.date setTextColor:[UIColor darkGrayColor]];
    }
    // if current time is between start time and end time, set blue (ongoing sessions)
    else if ( ([infoSession.startTime compare:[NSDate date]] == NSOrderedAscending) && ([[NSDate date] compare:infoSession.endTime] == NSOrderedAscending) ){
        [cell.employer setTextColor:[UIColor colorWithRed:0.08 green:0.46 blue:1 alpha:1]];
        [cell.locationLabel setTextColor:[UIColor colorWithRed:0.08 green:0.46 blue:1 alpha:1]];
        [cell.location setTextColor:[UIColor colorWithRed:0.08 green:0.46 blue:1 alpha:1]];
        [cell.dateLabel setTextColor:[UIColor colorWithRed:0.08 green:0.46 blue:1 alpha:1]];
        [cell.date setTextColor:[UIColor colorWithRed:0.08 green:0.46 blue:1 alpha:1]];
    }
    // set light grey (past sessions)
    else {
        [cell.employer setTextColor: [UIColor lightGrayColor]];
        [cell.locationLabel setTextColor:[UIColor lightGrayColor]];
        [cell.location setTextColor:[UIColor lightGrayColor]];
        [cell.dateLabel setTextColor:[UIColor lightGrayColor]];
        [cell.date setTextColor:[UIColor lightGrayColor]];
        
    }
//    
//    cell.employer.text = infoSession.employer;
//    cell.location.text = infoSession.location;
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"MMM d, y"];
//    [timeFormatter setDateFormat:@"h:mm a"];
//    
//    cell.date.text = [NSString stringWithFormat:@"%@ - %@, %@", [timeFormatter stringFromDate:infoSession.startTime], [timeFormatter stringFromDate:infoSession.endTime], [dateFormatter stringFromDate:infoSession.date]];
    NSMutableAttributedString *employerString = [[NSMutableAttributedString alloc] initWithString:infoSession.employer];
    NSMutableAttributedString *locationString = [[NSMutableAttributedString alloc] initWithString:infoSession.location];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, y"];
    [timeFormatter setDateFormat:@"h:mm a"];
    
    NSString *dateNSString = [NSString stringWithFormat:@"%@ - %@, %@", [timeFormatter stringFromDate:infoSession.startTime], [timeFormatter stringFromDate:infoSession.endTime], [dateFormatter stringFromDate:infoSession.date]];
    NSMutableAttributedString *dateString = [[NSMutableAttributedString alloc] initWithString:dateNSString];
    if (infoSession.isCancelled) {
        [employerString addAttribute:NSStrikethroughStyleAttributeName value:@2 range:NSMakeRange(0, [employerString length])];
        [locationString addAttribute:NSStrikethroughStyleAttributeName value:@2 range:NSMakeRange(0, [locationString length])];
        [dateString addAttribute:NSStrikethroughStyleAttributeName value:@2 range:NSMakeRange(0, [dateString length])];
    }
    [cell.employer setAttributedText:employerString];
    [cell.location setAttributedText:locationString];
    [cell.date setAttributedText:dateString];
}

/**
 *  set different cell height for different cell
 *
 *  @param tableView tableView
 *  @param indexPath indexPath
 *
 *  @return for LoadingCell, return 44.0f, for InfoSessionCell, return 70.0f
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // empty cell
    if (_infoSessionModel == nil || [_infoSessionModel.myInfoSessions count] == 0) {
        return 70.0f;
    } else {
        // info session cell
        return 70.0f;
    }
}


/**
 *  select row at indexPath
 *
 *  @param tableView tableView
 *  @param indexPath indexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ShowDetailFromMyInfoSessions" sender:[[NSArray alloc] initWithObjects:@"MyInfoViewController", _infoSessionModel.myInfoSessions[indexPath.row], _infoSessionModel, nil]];
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        InfoSession *infoSessionToBeDeleted = _infoSessionModel.myInfoSessions[indexPath.row];
        if ([InfoSessionModel deleteInfoSession:infoSessionToBeDeleted in:_infoSessionModel.myInfoSessions] == UWDeleted) {
            NSLog(@"deleted");
            [_tabBarController setBadge];
            
            UINavigationController *infoSessionVCNavigationController = _tabBarController.infoSessionsViewController.navigationController;
            // if count > 1, means detailView is shown
            if ([infoSessionVCNavigationController.viewControllers count] > 1) {
                UITableViewController *controller = infoSessionVCNavigationController.viewControllers[1];
                if ([controller isKindOfClass:[DetailViewController class]]) {
                    // get the tabbar item0's detailViewController
                    DetailViewController *detailController = (DetailViewController *)controller;
                    // if the tabbar item0's detailView is shown infoSession to be deleted, then let it pop up.
                    if ([infoSessionToBeDeleted isEqual:detailController.infoSession]) {
                        detailController.infoSessionBackup = nil;
                    }
                }
            }
            // save to file
            [_infoSessionModel saveInfoSessions];
        }
        if ([_infoSessionModel.myInfoSessions count] != 0) {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        // if last item is deleted
        else {
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self enterEditMode:nil];
        }
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

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

- (void)enterEditMode:(id)sender {
    if ([self.tableView isEditing]) {
        [self.tableView setEditing:NO animated:YES];
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(enterEditMode:)] animated:YES];
    } else {
        [self.tableView setEditing:YES animated:YES];
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(enterEditMode:)] animated:YES];
    }
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailViewController *controller = segue.destinationViewController;
    _tabBarController.detailViewControllerOfTabbar1 = controller;
    controller.caller = sender[0];
    controller.infoSession = sender[1];
    controller.infoSessionModel = sender[2];
    controller.tabBarController = _tabBarController;

}


@end
