//
//  UBCOutput.h
//  UCSF Book Club
//
//  Created by David Chiles on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UBCTap.h"

@interface UBCOutput : NSObject

//@property (nonatomic, strong) NSArray * taps;

+(NSData*) createAudio:(NSMutableArray *)taps;
+(void) addTap: (UBCTap *) tap toFilePath: (NSString *) fileName withStartTap: (UBCTap*) startTap;
+(NSString *)fileDateFormat;
+(int)undoLastTapfromFileName: (NSString *) fileName;

@end
