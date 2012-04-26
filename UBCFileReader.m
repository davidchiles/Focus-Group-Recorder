//
//  UBCFileReader.m
//  UCSF Book Club
//
//  Created by David Chiles on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UBCFileReader.h"

@implementation UBCFileReader


+(NSArray *)TapsArrayWithFile:(NSString *)filePath
{
    NSLog(@"tapsArraywithfile: %@",filePath);
    NSString* fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray* allLinedStrings = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray * taps = [[NSMutableArray alloc] initWithCapacity:([allLinedStrings count]-1)];
    
    for(int n = 1; n <= [allLinedStrings count]-1; n++)
    {
       //UBCTap * tap = [[UBCTap alloc] init];
        UBCTap * tap = [UBCFileReader TapFromString:[allLinedStrings objectAtIndex:n]];
        [taps addObject:tap];
    }
    
    return [taps copy];
    
    
}

+(UBCTap *) TapFromString:(NSString *)string
{
    NSLog(@"tapfromstring: %@",string);
    NSArray * strings = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    int num = [[strings objectAtIndex:0] intValue];

    NSString * dateString = [NSString stringWithFormat:@"%@ %@ %@",[strings objectAtIndex:1],[strings objectAtIndex:2],[strings objectAtIndex:3]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS Z"];
    NSDate *date = [[NSDate alloc] init];
    date = [dateFormatter dateFromString:dateString];
    
    UBCTap * tap = [[UBCTap alloc] initWithDate:date Number:num];
    return tap;
}

+(NSArray *)listFileAtPath
{
    NSLog(@"LISTING ALL FILES FOUND");
    NSString * path =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    int count;
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    for (count = 0; count < (int)[directoryContent count]; count++)
    {
        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    }
    NSMutableArray * files = [[NSMutableArray alloc] init];
    for(NSString * file in directoryContent)
    {
        if ([file rangeOfString:@".txt" options:(NSCaseInsensitiveSearch)].location != NSNotFound)
        {
            UBCFileInfo * fileInfo = [[UBCFileInfo alloc]initWithFile:[path stringByAppendingPathComponent:file]];
            NSLog(@"file path: %@",fileInfo.filePath);
            [files addObject:fileInfo];
        }
    }
    return files;
}

+(void)deleteAllFilesRelatedTo:(NSString *)fileName
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError * error;
    NSString * docDirectory =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * textPath = [docDirectory stringByAppendingPathComponent:[fileName stringByAppendingPathExtension:@"txt"]];
    NSString * mixedAudioPath = [docDirectory stringByAppendingPathComponent:[fileName stringByAppendingString:@"_mixed.m4a"]];
    NSString * micAudioPath = [docDirectory stringByAppendingPathComponent:[fileName stringByAppendingString:@"_mic.m4a"]];
    NSString * micCafAudioPath = [docDirectory stringByAppendingPathComponent:[fileName stringByAppendingString:@".caf"]];
    NSArray * filePaths = [NSArray arrayWithObjects:textPath,mixedAudioPath,micAudioPath,micCafAudioPath, nil];
    
    for (NSString * path in filePaths)
    {
        if([fileMgr fileExistsAtPath:path])
            [fileMgr removeItemAtPath:path error:&error];
        
    }
    if (error) {
        NSLog(@"Dlete File Error: %@",[error localizedDescription]);
    }
}

@end
