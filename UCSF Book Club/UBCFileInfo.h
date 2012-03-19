//
//  UBCFileInfo.h
//  UCSF Book Club
//
//  Created by David Chiles on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UBCFileReader.h"

@interface UBCFileInfo : NSObject

@property (nonatomic,strong) NSString * name;
@property (nonatomic,strong) NSString * filePath;
@property (nonatomic) NSTimeInterval length;
@property (nonatomic, strong) NSDate * startDate;
@property (nonatomic) int numberOfParticipants;
@property (nonatomic) BOOL hasAudio;
@property (nonatomic) BOOL isUploaded;




-(id)initWithFile:(NSString *)path;
-(NSString *)getName;
-(void)getInfo;


@end
