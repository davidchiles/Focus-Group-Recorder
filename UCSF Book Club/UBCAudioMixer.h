//
//  UBCAudioMixer.h
//  UCSF Book Club
//
//  Created by David Chiles on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioFile.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioPlayer.h>
#import "TPAACAudioConverter.h"

#import "UBCTap.h"
#import "UBCOutput.h"
#import "UBCFileReader.h"

@interface UBCAudioMixer : NSObject <TPAACAudioConverterDelegate>

@property (strong, nonatomic) TPAACAudioConverter * audioConverter;

+(NSString *)audioFilefromText:(NSString *)filePath toFile:(NSString *)mixPath;
+ (void) writeAudio: (NSString *) newAudio toExistingAudio: (AudioFileID) existingAudio atPacket: (SInt64) packet;
-(NSString *) convertForExport:(NSString *)filePath;
+(NSString *)createMixedAudiofromTextAudio:(NSString *)textAudioPath andRecording:(NSString *)recordingPath;

-(void)makeAllFilesfrom:(NSString *)fileSubName;

@end
