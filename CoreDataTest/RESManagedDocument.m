//
//  RESManagedDocument.m
//  CoreDataTest
//
//  Created by Regan Sarwas on 10/29/13.
//  Copyright (c) 2013 Regan Sarwas. All rights reserved.
//

#import "RESManagedDocument.h"
#import "RESCustomMOM.h"

#define kprotocolDirectory @"AdditionalContent"
#define kProtocolFilename @"protocol.json"
#define kDefaultProtocolFilename @"defaultprotocol.json"

@implementation RESManagedDocument

static NSURL *_defaultProtocol;

+ (NSURL *)defaultProtocolPath
{
    if (!_defaultProtocol) {
        NSURL *documentdir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        _defaultProtocol = [NSURL URLWithString:kDefaultProtocolFilename relativeToURL:documentdir];
    }
    return _defaultProtocol;
}

/*
-(id)initWithFileURL:(NSURL *)url protocol:(NSDictionary *)protocol
{
    NSLog(@"RESManagedDocument.init");
    self = [super initWithFileURL:url];
    NSLog(@"RESManagedDocument.super init done");
    if (self) {
        self.protocol = protocol;
    }
    NSLog(@"RESManagedDocument.set protocol");
    return self;
}
*/

NSManagedObjectModel *_myManagedObjectModel;



- (NSManagedObjectModel *)managedObjectModel
{
    NSLog(@"RESManagedDocument.managedObjectModel");
    //NSLog(@"  documentURL = %@", self.fileURL);
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[self.fileURL path]];
    NSLog(@"  document exists %@", exists ? @"YES" : @"NO");
    BOOL exists1 = [[NSFileManager defaultManager] fileExistsAtPath:[[self.fileURL path] stringByAppendingPathComponent:kProtocolFilename]];
    NSLog(@"  protocol exists %@", exists1 ? @"YES" : @"NO");
    BOOL exists2 = [[NSFileManager defaultManager] fileExistsAtPath:[[self.fileURL path] stringByAppendingPathComponent:@"AdditionalContent"]];
    NSLog(@"  AdditionalContent directory exists %@", exists2 ? @"YES" : @"NO");

    if (!_myManagedObjectModel)
    {
        [self loadProtocol];
        // the document does not exist yet, so I can't save the protocol
        // the client must do this after they have created the document on disk.
        if (!self.protocol) {
            //FIXME - need to alert the user, and close the document
            NSLog(@"  Unable to initialize document - there was no valid protocol found or provided");
            //return nil;  //FIXME - This will crash the app, find a better way
        }
        _myManagedObjectModel = [RESCustomMOM momWithProtocol:self.protocol];
    }
    return _myManagedObjectModel;
}

#pragma mark - Additional data

-(void) loadProtocol
{
    NSLog(@"RESManagedDocument.loadProtocol");
    NSString *path = [[self.fileURL path] stringByAppendingPathComponent:kProtocolFilename];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data) {
        NSLog(@"   got protocol from document");
        NSDictionary *protocol = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (protocol) {
            self.protocol = protocol;
        } else {
            NSLog(@"   protocol is not valid JSON");
        }
    } else {
        //try the default location when creating new files
        data = [NSData dataWithContentsOfURL:[self.class defaultProtocolPath]];
        if (data) {
            NSLog(@"   got protocol from default location");
            NSDictionary *protocol = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (protocol) {
                self.protocol = protocol;
            } else {
                NSLog(@"   protocol is not valid JSON");
            }
        } else {
            NSLog(@"   No protocol to initialize the MOM");
        }
    }
    // try a static variable
}


- (void) saveProtocol
{
    NSLog(@"RESManagedDocument.saveProtocol");
    //NOTE:  using URLS does not work - self.fileURL is an end point (it does not end in a slash)
    NSString *from = [[self.class defaultProtocolPath] path];
    NSString *to = [[self.fileURL path] stringByAppendingPathComponent:kProtocolFilename];
    NSLog(@"  moving from: %@ to %@", from, to);
    NSError *error;
    //[[NSFileManager defaultManager] moveItemAtPath:from toPath:to error:&error];
    [[NSFileManager defaultManager] copyItemAtPath:from toPath:to error:&error];
    if (error)
    {
        //FIXME - check the error an respond appropriately
        NSLog(@"  Error moving file %@", error);
    }
 }

-(void)openWithCompletionHandler:(void (^)(BOOL))completionHandler
{
    NSLog(@"RESManagedDocument.openWithCompletionHandler");
    [super openWithCompletionHandler:completionHandler];
    BOOL protocolExists = [[NSFileManager defaultManager] fileExistsAtPath:[[self.fileURL path] stringByAppendingPathComponent:kProtocolFilename]];
    if (!protocolExists) {
        [self saveProtocol];
    }
}
/*
-(BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    NSLog(@"RESManagedDocument.loadFromContents");
    return [super loadFromContents:contents ofType:typeName error:outError];
}

-(BOOL)readFromURL:(NSURL *)url error:(NSError *__autoreleasing *)outError
//  calls readAdditionalContentFromURL
{
    NSLog(@"RESManagedDocument.readFromURL");
    NSLog(@"  fromURL = %@",url);
    return [super readFromURL:url error:outError];
}

-(BOOL)readAdditionalContentFromURL:(NSURL *)absoluteURL error:(NSError *__autoreleasing *)error
{
    NSLog(@"RESManagedDocument.readAdditionalContentFromURL");
    NSLog(@"  fromURL = %@",absoluteURL);
    return [super readAdditionalContentFromURL:absoluteURL error:error];
}

-(id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
//   calls additionalContentForURL: and sends the results to writeAdditionalContent:
{
    NSLog(@"RESManagedDocument.contentsForType");
    NSLog(@"  type = %@",typeName);
    return [super contentsForType:typeName error:outError];
}

- (BOOL)writeAdditionalContent:(id)content toURL:(NSURL *)absoluteURL originalContentsURL:(NSURL *)absoluteOriginalContentsURL error:(NSError *__autoreleasing *)error
{
    NSLog(@"RESManagedDocument.writeAdditionalContent");
    NSLog(@"  toURL = %@, originalURL = %@",absoluteURL, absoluteOriginalContentsURL);
    return [super writeAdditionalContent:content toURL:absoluteURL originalContentsURL:absoluteOriginalContentsURL error:error];
}

-(id)additionalContentForURL:(NSURL *)absoluteURL error:(NSError *__autoreleasing *)error
{
    NSLog(@"RESManagedDocument.additionalContentForURL");
    NSLog(@"  forURL = %@",absoluteURL);
    return [super additionalContentForURL:absoluteURL error:error];
}
*/
@end
