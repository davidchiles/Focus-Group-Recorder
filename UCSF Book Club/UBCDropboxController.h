//
//  UBCDropboxController.h
//  UCSF Book Club
//
//  Created by David Chiles on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>

@protocol UBCDropboxControllerDelegate
- (void)uploadsFinished:(int)num;
@end

@interface UBCDropboxController : NSObject <DBRestClientDelegate>

@property (nonatomic, strong) NSString * destFilePath;
@property (nonatomic, strong) NSArray * localFilePaths;
@property (nonatomic, strong) NSMutableDictionary * remoteRevs;
@property (nonatomic, strong) DBRestClient *restClient;
@property (nonatomic ) int num;
@property (weak, nonatomic) id <UBCDropboxControllerDelegate> delegate;

-(void)uploadWithFiles:(NSArray*)files andDestinationFolder:(NSString*) filePath;

@end
