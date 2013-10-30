//
//  RESMasterViewController.m
//  CoreDataTest
//
//  Created by Regan Sarwas on 2013-07-14.
//  Copyright (c) 2013 Regan Sarwas. All rights reserved.
//

#import "RESMasterViewController.h"
#import "RESDetailViewController.h"

#define FILE_NAME @"res_core_data"

@interface RESMasterViewController ()

@end

@implementation RESMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.activitySpinner.hidden = YES;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@",
                           [managedObject valueForKey:@"lastname"],
                           [managedObject valueForKey:@"firstname"]];
    cell.detailTextLabel.text = [managedObject valueForKey:@"notes"];
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.fetchedResultsController.managedObjectContext deleteObject:managedObject];
        //NSFetchRequestController will notice the insert, then call its delegate to update the table view
        //if you try to do this now, the controller might not know about the new object.
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
        //NSFetchRequestController will notice the insert, then call its delegate to update the table view
        //if you try to do this now, the controller might not know about the new object.
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:managedObject];
    }
}



#pragma mark - private methods


- (void)insertNewObject:(id)sender
{
    NSManagedObject *author = [NSEntityDescription insertNewObjectForEntityForName:@"Author"
                                                            inManagedObjectContext:self.fetchedResultsController.managedObjectContext];
    //[author setValue:@"Last name" forKey:@"lastname"];
    //[author setValue:@"First name" forKey:@"firstname"];
    //[author setValue:@"Notes" forKey:@"notes"];
    int code = rand() % 99;
    int kids = rand() % 9;
    [author setValue:[NSString stringWithFormat:@"Smith_%u", code] forKey:@"lastname"];
    [author setValue:[NSString stringWithFormat:@"Agent_%u", code] forKey:@"firstname"];
    [author setValue:[NSString stringWithFormat:@"Eaten %u pizzas", code] forKey:@"notes"];
    [author setValue:[NSNumber numberWithInt:kids] forKey:@"kids"];
    [author setValue:[NSDate date] forKey:@"birthdate"];
    //NSFetchRequestController will notice the insert, then call its delegate to update the table view
    //if you try to do this now, the controller might not know about the new object.
    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    //[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}




@end
