//
//  RESCustomMOM.h
//  CoreDataTest
//
//  Created by Regan Sarwas on 10/29/13.
//  Copyright (c) 2013 Regan Sarwas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface RESCustomMOM : NSObject

+ (NSManagedObjectModel *) createMOM;
+ (NSManagedObjectModel *) modifyMOM;
+ (NSManagedObjectModel *) momWithJSONString:(NSString *)json;
+ (NSManagedObjectModel *) momWithJSONData:(NSData *)json;
@end
