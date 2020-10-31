//
//  RESManagedDocument.h
//  CoreDataTest
//
//  Created by Regan Sarwas on 10/29/13.
//  Copyright (c) 2013 Regan Sarwas. All rights reserved.
//

/*
I want to use UIManagedDocument, because it gives me a background context, undo management, and
 automatic background saving.

My documents have an object model that is mostly static, however, different surveys will collect
  different attributes.  These attributes are specified in a JSON file.  The documents object model
  is a merge of the app MOM stored in the bundle, and a custom JSON file.  once the document is created,
  the MOM cannot change, furthermore, the merge must be done everytime the document is opened.  If the
  file is new, then we need to be given the JSON to use (the protocol @property), once the MOM is created,
  we need to save the JSON with the file for future opens.  Put another way, when we open a document, we
  look for the JSON needed to customixe the MOM, if we find it, then apply it and return the MOM.  If there
  is no JSON found (a new document), then it is the callers obligation to provide a JSON object (in the
  protocol @property) to use.  If we use the provided JSON, we must save it for future opens.
 
We cannot use readAdditionalContentFromURL:error: to load the JSON, because it is called after the
 managedObjectModel is called (i.e. we need the JSON before UIKit loads the additional content). Also, the
 document directory does not exist, for new documents, when UIKit asks for the MOM, so we cannot save the
 JSON for a new document when creating the MOM.
 
Fortunately, the protocol is immutable, so once we create it, we will never change it.  A protocol change
 necessitates a new document.  There may be other "AdditionalContent" in the future, but I will deal with
 that later.

Unfortunately, We cannot manage our own immutable content in the AdditionalContent directory, because the
 UIKit does a safe save, by first writing to a new temp directory, then if that was successful, replaces
 the old Additional content foler with the temp folder.  Therefore I need to write to Additional Content
 whenever asked. As the Additional content in this case never changes, it should never be called, but it
 seems to be called whenever the document (i.e. the database) is saved.

I'm sure I'm missing some details on UIDocument.  In particular, my set up will not support iCloud, or even
  save as.  fortunately, I am not support those.
 
The big risk is since UIKit manages the document, UIKit might clear the document folder at some point on
 some devices, and the protocol will get cleared.

For now, I am entangling the user of the user of this ManagedDocument with it's implementation details.
 The user must write the protocol to the document folder when _creating_ the document.  (They must also
 set the protocol @property when creating a new document).  They do not need to set the protocol @property
 to open an existing ManagedDocument.
*/

#import <UIKit/UIKit.h>

@interface RESManagedDocument : UIManagedDocument

//Additional Data
@property (nonatomic, strong) NSDictionary *protocol;
@property (nonatomic, strong) UIImage *thumbnail;

// When creating a new document, you must write the protocol to the defaultProtocolPath
// before calling initWithFileURL.  After calling saveToURL:xxx forSaveOperation:UIDocumentSaveForCreating
// call saveProtocol to move the protocol at defaultProtocolPath into the document folder.
+ (NSURL *) defaultProtocolPath;
- (void) saveProtocol;


@end
