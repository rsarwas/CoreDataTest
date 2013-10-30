//
//  RESManagedDocument.m
//  CoreDataTest
//
//  Created by Regan Sarwas on 10/29/13.
//  Copyright (c) 2013 Regan Sarwas. All rights reserved.
//

#import "RESManagedDocument.h"
#import "RESCustomMOM.h"

@implementation RESManagedDocument

NSManagedObjectModel *_myManagedObjectModel;

- (NSManagedObjectModel *)managedObjectModel
{
    if (!_myManagedObjectModel)
        _myManagedObjectModel = [RESCustomMOM modifyMOM];
    return _myManagedObjectModel;
}


@end
