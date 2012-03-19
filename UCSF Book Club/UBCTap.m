//
//  UBCTap.m
//  UCSF Book Club
//
//  Created by David Chiles on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UBCTap.h"

@implementation UBCTap

@synthesize date,num,relativeSeconds;

-(UBCTap *)initWithNumber:(int)n
{
    self = [super init];
    self.date = [NSDate date];
    self.num = n;
    
    return self;
}

-(UBCTap *)initWithDate:(NSDate *)d Number:(int)n
{
    self = [super init];
    self.date = d;
    self.num = n;
    
    return self;
}
-(NSTimeInterval) timeIntervalSinceDate:(NSDate *) d
{
    if(self.date)
    {
        return [self.date timeIntervalSinceDate:d];
    }
    return NSTimeIntervalSince1970;
}

-(NSTimeInterval) timeIntervalSinceTap:(UBCTap *)tap
{
    if(self.date)
    {
        return [self.date timeIntervalSinceDate:tap.date];
    }
    return NSTimeIntervalSince1970;
    
}

-(NSString *) description
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS Z"];
    NSString *dateString = [dateFormat stringFromDate:self.date];
    return [NSString stringWithFormat:@"%d %@",self.num,dateString];
}

@end
