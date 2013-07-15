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

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activitySpinner;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSFetchedResultsController *fetchController;

@end

@implementation RESMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self openModel];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self closeModel];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchController sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSManagedObject *managedObject = [self.fetchController objectAtIndexPath:indexPath];
    
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
        NSManagedObject *managedObject = [self.fetchController objectAtIndexPath:indexPath];
        [self.document.managedObjectContext deleteObject:managedObject];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *managedObject = [self.fetchController objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:managedObject];
    }
}

#pragma mark - private methods


- (void)insertNewObject:(id)sender
{
    NSManagedObject *author = [NSEntityDescription insertNewObjectForEntityForName:@"Author"
                                                            inManagedObjectContext:self.document.managedObjectContext];
    [author setValue:@"Last name" forKey:@"lastname"];
    [author setValue:@"First name" forKey:@"firstname"];
    [author setValue:@"Notes" forKey:@"notes"];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}



//lazy instantiation
- (NSURL *)url
{
    if (!_url)
    {
        NSURL *documentsDirectory = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
        _url = [documentsDirectory URLByAppendingPathComponent:FILE_NAME];
    }
    return _url;
}

- (void) openModel
{
    // let the user know we are working - Start the spinner
    self.activitySpinner.hidden = NO;
    
    //Async Loader, wait for documentIsReady, documentOpenFailed, or documentCreateFailed
    [self openDocument];
    
    //sign up for notifications from Notification center
    [self connectToNotificationCenter];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void) closeModel
{
    // let the user know we are working - Start the spinner
    self.activitySpinner.hidden = NO;
    
    //Async Closer, wait for documentIsClosed, documentSaveFailed, or documentCloseFailed
    [self closeDocument];
    
    //disconnect from the notification center, to remove pointers to our objects
    [self disconnectFromNotificationCenter];
}

- (void) connectToNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(documentStateChanged:)
                                                 name:UIDocumentStateChangedNotification
                                               object:self.document];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataChanged:)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:self.document.managedObjectContext];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataSaved:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:self.document.managedObjectContext];
}

- (void) disconnectFromNotificationCenter
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDocumentStateChangedNotification
                                                  object:self.document];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextObjectsDidChangeNotification
                                                  object:self.document.managedObjectContext];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:self.document.managedObjectContext];
}

//Async Loader, wait for documentIsReady, documentOpenFailed, or documentCreateFailed
- (void) openDocument
{
    self.document = [[UIManagedDocument alloc] initWithFileURL:self.url];
    BOOL documentExists = [[NSFileManager defaultManager] fileExistsAtPath:[self.url path]];
    if (documentExists) {
        [self.document openWithCompletionHandler:^ (BOOL success) {
            if (success)
                [self documentIsReady];
            else
                [self documentOpenFailed];
        }];
    }
    else
    {
        [self.document saveToURL:self.url forSaveOperation:UIDocumentSaveForCreating completionHandler:^ (BOOL success) {
            if (success)
                [self documentIsReady];
            else
                [self documentCreateFailed];
        }];
    }
}

//Async Closer, wait for documentIsClosed, documentSaveFailed, or documentCloseFailed
- (void) closeDocument
{
    if (self.document) {
        [self.document saveToURL:self.url forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^ (BOOL success) {
            if (success)
                [self.document closeWithCompletionHandler:^(BOOL success) {
                    if (success)
                        [self documentIsClosed];
                    else
                        [self documentCloseFailed];
                }];
            else
                [self documentSaveFailed];
        }];
    }
}

- (void) documentIsReady
{
    NSLog (@"UIManagedDocument is ready at url %@", self.url);
    switch (self.document.documentState) {
        case UIDocumentStateNormal:
            [self loadData:self.document.managedObjectContext];
            self.activitySpinner.hidden = YES;
            return;
        case UIDocumentStateClosed:
            NSLog(@"Document is closed");
            break;
        case UIDocumentStateEditingDisabled:
            NSLog(@"Document editing is disabled");
            break;
        case UIDocumentStateInConflict:
            NSLog(@"Document is in conflict");
            break;
        case UIDocumentStateSavingError:
            NSLog(@"Document has an error saving state");
            break;
        default:
            NSLog(@"Document has an unexpected state");
    }
    [self fatalAbort];
}

- (void) documentIsClosed
{
    NSLog (@"UIManagedDocument is closed at url %@", self.url);
    //view may be gone by now, so do nothing
    //self.activitySpinner.hidden = YES;
}

- (void) documentOpenFailed
{
    NSLog (@"Document open failed for url %@", self.url);
    self.activitySpinner.hidden = YES;
    //raise alert
    [self fatalAbort];
}

 - (void) documentCreateFailed
{
    NSLog (@"Document creation failed for url %@", self.url);
    self.activitySpinner.hidden = YES;
    //raise alert
    [self fatalAbort];
}
 
- (void) documentSaveFailed
{
    NSLog (@"Document save failed for url %@", self.url);
    self.activitySpinner.hidden = YES;
    //raise alert
    [self fatalAbort];
}

- (void) documentCloseFailed
{
    NSLog (@"Document creation failed for url %@", self.url);
    self.activitySpinner.hidden = YES;
    //raise alert
    [self fatalAbort];
}

- (void) fatalAbort
{
    NSLog(@"Fatal Error, quitting");
    // give user information about how to report the error
    // email log to developer
    // close the app
}

- (void) documentStateChanged: (NSNotification *)notification
{
    //name should always be UIDocumentStateChangedNotification
    //object should always be self.document
    //userinfo is nil
    
    NSLog(@"Document State Changed");
    switch (self.document.documentState) {
        case UIDocumentStateNormal:
            NSLog(@"  Document is normal");
            break;
        case UIDocumentStateClosed:
            NSLog(@"  Document is closed");
            break;
        case UIDocumentStateEditingDisabled:
            NSLog(@"  Document editing is disabled");
            break;
        case UIDocumentStateInConflict:
            NSLog(@"  Document is in conflict");
            break;
        case UIDocumentStateSavingError:
            NSLog(@"  Document has an error saving state");
            break;
        default:
            NSLog(@"  Document has an unexpected state");
    }
}

- (void) dataChanged: (NSNotification *)notification
{
    //name should always be NSManagedObjectContextObjectsDidChangeNotification
    //object should always be self.document
    //userinfo has keys NSInsertedObjectsKey, NSUpdatedObjectsKey, NSDeletedObjectsKey which all return arrays of objects
    
    NSLog(@"Data Changed; \nname:%@ \nobject:%@ \nuserinfo:%@", notification.name, notification.object, notification.userInfo);
}

- (void) dataSaved: (NSNotification *)notification
{
    //name should always be NSManagedObjectContextDidSaveNotification
    //object should always be self.document
    //userinfo has keys NSInsertedObjectsKey, NSUpdatedObjectsKey, NSDeletedObjectsKey which all return arrays of objects
    
    NSLog(@"Data Saved; \nname:%@ \nobject:%@ \nuserinfo:%@", notification.name, notification.object, notification.userInfo);
}

- (void) loadData:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Author"];
    NSSortDescriptor *sortlastname = [NSSortDescriptor sortDescriptorWithKey:@"lastname"ascending:YES];
    NSSortDescriptor *sortfirstname = [NSSortDescriptor sortDescriptorWithKey:@"firstname"ascending:YES];
    request.sortDescriptors = @[sortlastname, sortfirstname];
    //No predicate - get all
    self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                               managedObjectContext:self.document.managedObjectContext
                                                                 sectionNameKeyPath:nil
                                                                          cacheName:@"coredatatest_cache"];
    self.fetchController.delegate = self;
    NSError *error;
    BOOL success = [self.fetchController performFetch:&error];
    if (!success) {
        NSLog(@"Fetch failed: %@", error);
        [self fatalAbort];
    }
}

@end
