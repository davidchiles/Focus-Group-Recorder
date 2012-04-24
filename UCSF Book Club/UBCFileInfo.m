//
//  UBCFileInfo.m
//  UCSF Book Club
//
//  Created by David Chiles on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UBCFileInfo.h"

@implementation UBCFileInfo

@synthesize numberOfParticipants,name,length,startDate,filePath,hasAudio,isUploaded,uploadList;

-(id)initWithFile:(NSString *)fPath
{
    self = [super init];
    if(self)
    {
        self.filePath = fPath;
        self.uploadList = [[NSMutableArray alloc] init];
        
    }
    
    /*
    NSArray * taps = [UBCFileReader TapsArrayWithFile:self.filePath];
    
    UBCTap * startTap = (UBCTap*)[taps objectAtIndex:0];
    self.startDate = startTap.date;
    self.length = [(UBCTap*)[taps lastObject] timeIntervalSinceTap:startTap];
    
    self.numberOfParticipants = 0;
    
    for (UBCTap* tap in taps)
    {
        if (tap.num > self.numberOfParticipants) {
            self.numberOfParticipants = tap.num;
        }
        
    }
    */
    return self;
}

-(void)getInfo
{
    if(self.filePath)
    {
        NSArray * taps = [UBCFileReader TapsArrayWithFile:self.filePath];
        
        UBCTap * startTap = (UBCTap*)[taps objectAtIndex:0];
        self.startDate = startTap.date;
        self.length = [(UBCTap*)[taps lastObject] timeIntervalSinceTap:startTap];
        
        self.numberOfParticipants = 0;
        
        for (UBCTap* tap in taps)
        {
            if (tap.num > self.numberOfParticipants) {
                self.numberOfParticipants = tap.num;
            }
            
        }
        
    }
    
}

-(NSString *)getName{
    if (!self.name && self.filePath) {
        self.name = [[self.filePath lastPathComponent] stringByDeletingPathExtension];
    }
    return self.name;
}





@end
