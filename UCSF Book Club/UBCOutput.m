//
//  UBCOutput.m
//  UCSF Book Club
//
//  Created by David Chiles on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UBCOutput.h"

@implementation UBCOutput



+(NSData*) createAudio:(NSArray *)taps
{
    
    return [NSData data];
}

+(void) addTap: (UBCTap *) tap toFilePath: (NSString *) fileName withStartTap: (UBCTap*) startTap
{
    //NSError *error;
    NSTimeInterval timeSinceStart = [tap timeIntervalSinceTap:startTap];
    NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:fileName]];
    NSString *str;
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    
    
    NSLog(@"TimeSinceStart: %f",timeSinceStart);
    
    [fileHandler seekToEndOfFile];
    NSLog(@"addTap: %@",tap.description);
    
    if (tap.num == 0) //start
        str = [NSString stringWithFormat:@"\n%@ Recording Started",tap.description];
    else if(tap.num == -1) //end
        str = [NSString stringWithFormat:@"\n%@ Recording Ended",tap.description];
    else //actual numbered taps
        str = [NSString stringWithFormat:@"\n%@",tap.description];
    
    
    int min = floor((timeSinceStart)/60.0);
    float sec = timeSinceStart-(min*60.0);
    //int mil = round(1000*(timeSinceStart-sec-min*60-hou*3600));
    
    NSString *intervalString;
    if (min) {
        intervalString = [NSString stringWithFormat:@"%d:%f",min,sec];
    }
    else{
        intervalString = [NSString stringWithFormat:@"%f",sec];
    }
    
    //intervalString = [NSString stringWithFormat:@"%f",timeSinceStart];
    str = [NSString stringWithFormat:@"%@ %@",str,intervalString];
    NSLog(@"Hello %@",str);
    [fileHandler writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler closeFile];
}

+(int)undoLastTapfromFileName: (NSString *) fileName
{
    NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:fileName]];
    
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    NSString* fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray* allLinedStrings = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    
    if (allLinedStrings.count>2) {
        [fileHandler truncateFileAtOffset:0];
        NSString * str = [allLinedStrings objectAtIndex:0];
        
        for (int i =1; i<allLinedStrings.count; i++) {
            [fileHandler writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
            str = [NSString stringWithFormat:@"\n%@",[allLinedStrings objectAtIndex:i]];
        
            }
        str = [allLinedStrings objectAtIndex:[allLinedStrings count]-2];
        NSLog(@"lastButtonString: %@",str);
        return [[[str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]objectAtIndex:0] intValue];
    }
    else {
        return 0;
    }
    [fileHandler closeFile];
}


+(NSString *)fileDateFormat
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    NSString *dateString = [dateFormat stringFromDate:today];
    NSLog(@"date: %@", dateString);
    return dateString;
}

@end
