//
//  RESCustomMOM.m
//  CoreDataTest
//
//  Created by Regan Sarwas on 10/29/13.
//  Copyright (c) 2013 Regan Sarwas. All rights reserved.
//

#import "RESCustomMOM.h"

@implementation RESCustomMOM

+ (NSManagedObjectModel *) createMOM
{
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] init];
    NSEntityDescription *runEntity = [[NSEntityDescription alloc] init];
    [runEntity setName:@"Run"];
    [runEntity setManagedObjectClassName:@"Run"];
    [mom setEntities:@[runEntity]];

    NSMutableArray *runProperties = [NSMutableArray array];

    NSAttributeDescription *dateAttribute = [[NSAttributeDescription alloc] init];
    [runProperties addObject:dateAttribute];
    [dateAttribute setName:@"date"];
    [dateAttribute setAttributeType:NSDateAttributeType];
    [dateAttribute setOptional:NO];

    NSAttributeDescription *idAttribute= [[NSAttributeDescription alloc] init];
    [runProperties addObject:idAttribute];
    [idAttribute setName:@"processID"];
    [idAttribute setAttributeType:NSInteger32AttributeType];
    [idAttribute setOptional:NO];
    [idAttribute setDefaultValue:@0];

    NSPredicate *validationPredicate = [NSPredicate predicateWithFormat:@"SELF >= 0"];
    NSString *validationWarning = @"Process ID < 0";
    [idAttribute setValidationPredicates:@[validationPredicate]
                  withValidationWarnings:@[validationWarning]];

    [runEntity setProperties:runProperties];

    NSDictionary *localizationDictionary = @{
                                             @"Property/processID/Entity/Run" : @"Process ID",
                                             @"Property/date/Entity/Run" : @"Date",
                                             @"ErrorString/Process ID < 0" : @"Process ID must not be less than 0" };
    [mom setLocalizationDictionary:localizationDictionary];
    return mom;
}


+ (NSManagedObjectModel *) modifyMOM
{
    NSManagedObjectModel *mom = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSEntityDescription * attribEntity = [[mom entitiesByName] valueForKey:@"Author"];
    NSMutableArray *attribProperties = [NSMutableArray arrayWithArray:attribEntity.properties];

    NSAttributeDescription *dateAttribute = [[NSAttributeDescription alloc] init];
    [attribProperties addObject:dateAttribute];
    [dateAttribute setName:@"birthdate"];
    [dateAttribute setAttributeType:NSDateAttributeType];
    [dateAttribute setOptional:NO];

    NSAttributeDescription *idAttribute= [[NSAttributeDescription alloc] init];
    [attribProperties addObject:idAttribute];
    [idAttribute setName:@"kids"];
    [idAttribute setAttributeType:NSInteger32AttributeType];
    [idAttribute setOptional:NO];
    [idAttribute setDefaultValue:@0];

    NSPredicate *validationPredicate = [NSPredicate predicateWithFormat:@"SELF >= 0"];
    NSString *validationWarning = @"Kid count must be non-negative";
    [idAttribute setValidationPredicates:@[validationPredicate]
                  withValidationWarnings:@[validationWarning]];

    [attribEntity setProperties:attribProperties];

    return mom;
}


+ (NSManagedObjectModel *) momWithProtocol:(NSDictionary *)protocol
{
    NSManagedObjectModel *mom = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSArray *attribs = protocol[@"objectmodel"];
    if (attribs)
        mom = [self mergeMom:mom entity:@"Author" attributes:attribs];
    return mom;
}


+ (NSManagedObjectModel *) momWithJSONData:(NSData *)json
{
    NSManagedObjectModel *mom = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSLog(@"json: %@", [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]);

    NSArray *attribs = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
    if (attribs)
        mom = [self mergeMom:mom entity:@"Author" attributes:attribs];
    return mom;
}


+ (NSManagedObjectModel *) momWithJSONString:(NSString *)json
    {
        NSData * data = [json dataUsingEncoding:NSUTF8StringEncoding];
        return [self momWithJSONData:data];
}

+ (NSManagedObjectModel *) mergeMom:(NSManagedObjectModel *)mom entity:(NSString *)entity attributes:(NSArray *)attributes
{
    NSEntityDescription * attribEntity = [[mom entitiesByName] valueForKey:entity];
    NSMutableArray *attribProperties = [NSMutableArray arrayWithArray:attribEntity.properties];
    for (NSDictionary *attrib in attributes) {
        NSAttributeDescription *attributeDescription = [[NSAttributeDescription alloc] init];
        [attribProperties addObject:attributeDescription];
        [attributeDescription setName:[attrib valueForKey:@"name"]];
        [attributeDescription setAttributeType:[(NSNumber *)[attrib valueForKey:@"type"] intValue]];
        [attributeDescription setOptional:[attrib[@"optional"] boolValue]];
        [attributeDescription setDefaultValue:attrib[@"default"]];
        NSArray *constraints = attrib[@"constraints"];
        if (constraints)
        {
            NSMutableArray *predicates = [[NSMutableArray alloc] init];
            NSMutableArray *warnings = [[NSMutableArray alloc] init];
            for (NSDictionary *constraint in constraints) {
                [predicates addObject:[NSPredicate predicateWithFormat:constraint[@"predicate"]]];
                [warnings addObject:constraint[@"warning"]];
                [attributeDescription setValidationPredicates:predicates
                              withValidationWarnings:warnings];
            }
        }

    }
    [attribEntity setProperties:attribProperties];
    return mom;
}


@end
