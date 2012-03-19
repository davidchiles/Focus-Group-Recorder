//
//  UBCDropboxController.m
//  UCSF Book Club
//
//  Created by David Chiles on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UBCDropboxController.h"

@implementation UBCDropboxController

@synthesize destFilePath,localFilePaths;
@synthesize remoteRevs, restClient;
@synthesize num;
@synthesize delegate;

-(void)dealloc {
    self.destFilePath = nil;
    self.localFilePaths = nil;
    self.remoteRevs = nil;
    self.restClient = nil;
}

-(id)init {
    if(self = [super init]) {
        self.remoteRevs = [[NSMutableDictionary alloc] init];
        self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        self.restClient.delegate = self; 
        num = 0;
    }

    return self;
}

-(void)uploadWithFiles:(NSArray*)files andDestinationFolder:(NSString *) filePath
{
    //[[self restClient] uploadFile:@"test.txt" toPath:destFilePath withParentRev:nil fromPath:[localFilePaths objectAtIndex:0]];
    self.destFilePath = filePath;
    self.localFilePaths = files;
    num = 0;
    NSLog(@"Get metadata: %@",destFilePath);
    [self.restClient loadMetadata:destFilePath];
}

-(void) uploadWithRevs
{
    for(NSString * localPath in localFilePaths)
    {
        if([remoteRevs objectForKey:[localPath lastPathComponent]])
        {
            [[self restClient] uploadFile:[localPath lastPathComponent] toPath:destFilePath withParentRev:[remoteRevs objectForKey:[localPath lastPathComponent]]  fromPath:localPath];
            NSLog(@"Old File");
        }
        else
        {
            [[self restClient] uploadFile:[localPath lastPathComponent] toPath:destFilePath withParentRev:nil fromPath:localPath];
            NSLog(@"New File");
        }
    }
    
}

#pragma Dropbox
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    NSLog(@"File uploaded successfully wtih name: %@", metadata.filename);
    num ++;
    if(num == localFilePaths.count)
    {
        [self.delegate uploadsFinished:num];
    }
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory) {
        NSLog(@"Folder '%@' contains:", metadata.path);
        for (DBMetadata *file in metadata.contents) {
            [remoteRevs setObject:file.rev forKey:file.filename];
            NSLog(@"\t%@", file.filename);
        }
        [self uploadWithRevs];
    }
}

- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    NSLog(@"Error loading metadata: %@", error);
}

-(void) restClient:(DBRestClient *)client loadedAccountInfo:(DBAccountInfo *)info
{
    NSLog(@"Accont Info %@",info.displayName);
}




@end
