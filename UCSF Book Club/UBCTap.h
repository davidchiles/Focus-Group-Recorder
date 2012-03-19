//
//  UBCTap.h
//  UCSF Book Club
//
//  Created by David Chiles on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UBCTap : NSObject


@property (nonatomic,strong) NSDate *date;
@property (nonatomic) int num;
@property (nonatomic) long relativeSeconds;

-(UBCTap *)initWithDate: (NSDate *) date Number: (int) num;
-(UBCTap *)initWithNumber: (int) num;
-(NSTimeInterval) timeIntervalSinceDate:(NSDate *) date;
-(NSTimeInterval) timeIntervalSinceTap: (UBCTap *) tap;

@end
