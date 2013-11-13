//
//  RESAppDelegate.m
//  CoreDataTest
//
//  Created by Regan Sarwas on 2013-07-14.
//  Copyright (c) 2013 Regan Sarwas. All rights reserved.
//

#import "RESAppDelegate.h"
#import "RESMasterViewController.h"
#import "RESManagedDocument.h"

#import <CoreData/CoreData.h>

#define FILE_NAME @"res_core_data4"


@interface RESAppDelegate()

@property (weak, nonatomic)  UIActivityIndicatorView *activitySpinner;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) RESManagedDocument *document;
@property (weak, nonatomic) RESMasterViewController *masterVC;
//@property (strong, nonatomic) NSFetchedResultsController *fetchController;

@end


@implementation RESAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self openModel];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self closeModel];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self openModel];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self closeModel];
}





//lazy instantiation
- (RESMasterViewController *)masterVC
{
    if (!_masterVC)
    {
        UINavigationController *rvc = (UINavigationController *)self.window.rootViewController;
        _masterVC = (RESMasterViewController *)rvc.viewControllers[0];        
    }
    return _masterVC;
}

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
    self.masterVC.activitySpinner.hidden = NO;
    
    //Async Loader, wait for documentIsReady, documentOpenFailed, or documentCreateFailed
    [self openDocument];
    
    //sign up for notifications from Notification center
    [self connectToNotificationCenter];
    
}

- (void) closeModel
{
    // let the user know we are working - Start the spinner
    self.masterVC.activitySpinner.hidden = NO;
    
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
    NSLog(@"RESAppDelegate.openDocument");
    BOOL documentExists = [[NSFileManager defaultManager] fileExistsAtPath:[self.url path]];
    if (documentExists) {
        NSLog(@"  open existing document at %@", self.url);
        self.document = [[RESManagedDocument alloc] initWithFileURL:self.url];
        [self.document openWithCompletionHandler:^ (BOOL success) {
            if (success)
                [self documentIsReady];
            else
                [self documentOpenFailed];
        }];
    }
    else
    {
        NSLog(@"  create new document at %@", self.url);
        // put the protocol where the managed document can find it
        // UIManagedDocument creates the MOM in the init method (since it happens in super,
        // I cannot set an instance variable before the MOM is configured
        [self stashDefaultProtocol];
        self.document = [[RESManagedDocument alloc] initWithFileURL:self.url];
        [self.document saveToURL:self.url forSaveOperation:UIDocumentSaveForCreating completionHandler:^ (BOOL success) {
            if (success)
            {
                NSLog(@"  new document created");
                [self.document saveProtocol];
                [self documentIsReady];
            } else {
                [self documentCreateFailed];
            }
        }];
    }
}

- (void) stashDefaultProtocol
{
    NSLog(@"RESAppDelegate.loadSampleProtocol");
    NSString *path = [[NSBundle mainBundle] pathForResource:@"protocol" ofType:@"json"];
    NSString *toPath = [[RESManagedDocument defaultProtocolPath] path];
    [[NSFileManager defaultManager] copyItemAtPath:path toPath:toPath error:nil];
    //FIXME - check the error after copy, and deal with it
}

-(NSDictionary *) loadSampleProtocol
{
    NSLog(@"RESAppDelegate.loadSampleProtocol");
    NSString *path = [[NSBundle mainBundle] pathForResource:@"protocol" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        return nil;
    }
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
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
            self.masterVC.activitySpinner.hidden = YES;
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
    //self.masterVC.activitySpinner.hidden = YES;
}

- (void) documentOpenFailed
{
    NSLog (@"Document open failed for url %@", self.url);
    self.masterVC.activitySpinner.hidden = YES;
    //raise alert
    [self fatalAbort];
}

- (void) documentCreateFailed
{
    NSLog (@"Document creation failed for url %@", self.url);
    self.masterVC.activitySpinner.hidden = YES;
    //raise alert
    [self fatalAbort];
}

- (void) documentSaveFailed
{
    NSLog (@"Document save failed for url %@", self.url);
    self.masterVC.activitySpinner.hidden = YES;
    //raise alert
    [self fatalAbort];
}

- (void) documentCloseFailed
{
    NSLog (@"Document creation failed for url %@", self.url);
    self.masterVC.activitySpinner.hidden = YES;
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
    NSFetchedResultsController *fc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                               managedObjectContext:self.document.managedObjectContext
                                                                 sectionNameKeyPath:nil
                                                                          cacheName:@"coredatatest_cache"];
    
    self.masterVC.debug = YES;
    self.masterVC.fetchedResultsController = fc;
    [self.masterVC.tableView reloadData];

    /*    NSError *error;
    BOOL success = [self.fetchController performFetch:&error];
    if (!success) {
        NSLog(@"Fetch failed: %@", error);
        [self fatalAbort];
    }
    else{
        NSLog(@"Fetch success");
        int s = self.fetchController.sections.count;
        NSLog(@"Number of sections:%u", s);
        for (int i = 0; i < s; i++)
        {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchController sections] objectAtIndex:i];
            int r = [sectionInfo numberOfObjects];
            NSLog(@"Section %u has %u rows", 0, r);
            for (int j = 0; j < r; j++)
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                NSManagedObject *obj = [self.fetchController objectAtIndexPath:indexPath];
                NSLog(@"(%u,%u): lastname: %@, firstname: %@, notes: %@", i,j,[obj valueForKey:@"lastname"],
                      [obj valueForKey:@"firstname"], [obj valueForKey:@"notes"]);
            }
        }
    }
     */
}


@end
