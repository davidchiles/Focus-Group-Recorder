//
//  UBCsecret.h
//  UCSF Book Club
//
//  Created by David Chiles on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UBCsecret : NSObject

+(NSString *)getAppKey;
+(NSString *)getAppSecret;

@end
