//
//  UBCFileReader.h
//  UCSF Book Club
//
//  Created by David Chiles on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "UBCTap.h"
#import "UBCFileInfo.h"

@interface UBCFileReader : NSObject

+(NSArray *)TapsArrayWithFile:(NSString *)filePath;
+(UBCTap *) TapFromString:(NSString *)string;
+(NSArray *)listFileAtPath;
@end
