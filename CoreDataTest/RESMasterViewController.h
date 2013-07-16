//
//  RESMasterViewController.h
//  CoreDataTest
//
//  Created by Regan Sarwas on 2013-07-14.
//  Copyright (c) 2013 Regan Sarwas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CoreDataTableViewController.h"

@interface RESMasterViewController : CoreDataTableViewController <NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activitySpinner;

@end
