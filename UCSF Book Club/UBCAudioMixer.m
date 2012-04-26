//
//  UBCAudioMixer.m
//  UCSF Book Club
//
//  Created by David Chiles on 3/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UBCAudioMixer.h"
#import "PCMMixer.h"


static
inline
BOOL mix_buffers(const int16_t *buffer1,
				 const int16_t *buffer2,
				 int16_t *mixbuffer,
				 int mixbufferNumSamples)
{
	BOOL clipping = FALSE;
    
	for (int i = 0 ; i < mixbufferNumSamples; i++) {
		int32_t s1 = buffer1[i];
		int32_t s2 = buffer2[i];
		int32_t mixed = s1 + s2;
        
		if ((mixed < -32768) || (mixed > 32767)) {
			clipping = TRUE;
			break;
		} else {
			mixbuffer[i] = (int16_t) mixed;
		}
	}
    
	return clipping;
}
#define checkResult(result,operation) (_checkResult((result),(operation),__FILE__,__LINE__))
static inline BOOL _checkResult(OSStatus result, const char *operation, const char* file, int line) {
    if ( result != noErr ) {
        NSLog(@"%s:%d: %s result %d %08X %4.4s\n", file, line, operation, (int)result, (int)result, (char*)&result); 
        return NO;
    }
    return YES;
}
@implementation UBCAudioMixer

@synthesize audioConverter;


+ (void) writeAudio: (NSString *) newAudio toExistingAudio: (AudioFileID) existingAudioFileID atPacket: (SInt64) packet
{
    //UInt64 outDataSize = 0;
    //UInt32 thePropSize = sizeof(UInt64);
    //NSLog(@"Audio file size: %@",AudioFileGetProperty(existingAudioFileID, kAudioFilePropertyDataOffset, &thePropSize, &outDataSize));
    //NSLog(@"The size: %llu",outDataSize);
    //NSURL *existingAudioURL = [NSURL fileURLWithPath:existingAudio];
    NSURL *newAudioURL = [NSURL fileURLWithPath:newAudio];
    CFURLRef newCURL = (__bridge CFURLRef)newAudioURL;
    
    NSString *silencePath = [[NSBundle mainBundle] pathForResource:@"silence" ofType:@"caf"]; //fix should be silence
    NSURL *silenceUrl = [NSURL fileURLWithPath:silencePath];
    CFURLRef silenceCFURL = (__bridge CFURLRef)silenceUrl;
    
    NSString * stat = nil;
    
    OSStatus status, close_status;
    
    AudioStreamBasicDescription inputDataFormat;
    
    //AudioFileID existingAudioFileID = NULL;
    AudioFileID newAudioFileID = NULL;
    AudioFileID silenceID = NULL;
    
    //bzero(inputDataFormat, sizeof(AudioStreamBasicDescription));
	
	inputDataFormat.mFormatID = kAudioFormatLinearPCM;
	inputDataFormat.mSampleRate = 44100.0;
	inputDataFormat.mChannelsPerFrame = 2;
	inputDataFormat.mBytesPerPacket = 2;
	inputDataFormat.mFramesPerPacket = 1;
	inputDataFormat.mBytesPerFrame = 2;
	inputDataFormat.mBitsPerChannel = 16;
	inputDataFormat.mFormatFlags = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    
    //status = AudioFileCreateWithURL(existingCURL, kAudioFileCAFType, &inputDataFormat, kAudioFileFlags_EraseFile, &existingAudioFileID);
    //OSStatus status;
    status = AudioFileOpenURL(newCURL, kAudioFileReadPermission, 0, &newAudioFileID);
    status = AudioFileOpenURL(silenceCFURL, kAudioFileReadPermission, 0, &silenceID);
    
    if (status)
	{
		goto reterr;
	}
    
    
    
#define BUFFER_SIZE 8192 
    //4096
	char *newBuffer = NULL;
	char *existingBuffer = NULL;    
    
    //AudioStreamBasicDescription inputDataFormat;
	UInt32 propSize = sizeof(inputDataFormat);
    
	bzero(&inputDataFormat, sizeof(inputDataFormat));
    status = AudioFileGetProperty(existingAudioFileID, kAudioFilePropertyDataFormat,
								  &propSize, &inputDataFormat);
    
    if (status)
	{
		goto reterr;
	}
    
	if ((inputDataFormat.mFormatID == kAudioFormatLinearPCM) &&
		(inputDataFormat.mSampleRate == 44100.0) &&
		(inputDataFormat.mChannelsPerFrame == 2) &&
		(inputDataFormat.mChannelsPerFrame == 2) &&
		(inputDataFormat.mBitsPerChannel == 16)  &&
		(inputDataFormat.mFormatFlags == (kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsSignedInteger |kAudioFormatFlagIsPacked))
		) {
		// no-op when the expected data format is found
	} else {
		status = kAudioFileUnsupportedFileTypeError;
		//goto reterr;
	}
    
	// Both input files validated, open output (mix) file
    
	//[self _setDefaultAudioFormatFlags:&inputDataFormat numChannels:1];
    
	//status = AudioFileCreateWithURL(existingCURL, kAudioFileCAFType, &inputDataFormat, kAudioFileFlags_EraseFile, &existingAudioFileID);
    //status = AudioFileOpenURL(existingCURL, kAudioFileWritePermission, 0, &existingAudioFileID);
    //NSLog(@"status: %f",status);
    if (status)
	{
		//goto reterr;
	}
    
	newBuffer = malloc(BUFFER_SIZE);
	assert(newBuffer);
	existingBuffer = malloc(BUFFER_SIZE);
	assert(existingBuffer);
    
	SInt64 packetNum1 = 0;
	SInt64 existingPacketNum = packet;
    
    UInt64 packetCount = 0;
    UInt32 size = sizeof(packetCount);
    AudioFileGetProperty( existingAudioFileID, kAudioFilePropertyAudioDataPacketCount, &size, &packetCount );
    //NSLog(@"packetCount: %llu",packetCount);
    SInt64 currentEndPacket = packetCount;
    
	UInt32 numPackets1;
    
    
    
    
        
    
    
        UInt32 bytesRead;
        
        //NSLog(@"packets: %lld",currentEndPacket);
        
        numPackets1 = BUFFER_SIZE / inputDataFormat.mBytesPerPacket;
        status = AudioFileReadPackets(silenceID,
									  false,
									  &bytesRead,
									  NULL,
									  packetNum1,
									  &numPackets1,
									  newBuffer);
        
        
		// if buffer was not filled, fill with zeros
        
        if (bytesRead < BUFFER_SIZE) {
            bzero(newBuffer + bytesRead, (BUFFER_SIZE - bytesRead));
            NSLog(@"bzero");
        }
        
        packetNum1 += numPackets1;
    //NSLog(@"packetNum1: %lld",packetNum1);
        
        
		// If no frames were returned, conversion is finished
    while (currentEndPacket < existingPacketNum)
    {
        //NSLog(@"currentEndPacket: %lld",currentEndPacket);
        //NSLog(@"exisitingPacketNum: %lld",existingPacketNum);
		// Write pcm data to output file
        //NSLog(@"in the loop");
        int maxNumPackets;
        maxNumPackets = numPackets1; 
        
        //NSLog(@"max num packets: %d",maxNumPackets);

        
        UInt32 packetsWritten = maxNumPackets;
        
        status = AudioFileWritePackets(existingAudioFileID,
                                       FALSE,
                                       (maxNumPackets * inputDataFormat.mBytesPerPacket),
                                       NULL,
                                       currentEndPacket,
                                       &packetsWritten,
                                       newBuffer);
        //NSLog(@"Other status: %ld",status);
        //existingPacketNum += packetsWritten;
        currentEndPacket = currentEndPacket + maxNumPackets;
        
    }

    packetNum1 =0;
    while (TRUE) 
    {
		// Read a chunk of input
        //NSLog(@"Read a chunk of input");
		UInt32 bytesRead;
        
        //NSLog(@"packets: %lld",existingPacketNum);
            
        numPackets1 = BUFFER_SIZE / inputDataFormat.mBytesPerPacket;
        status = AudioFileReadPackets(newAudioFileID,
									  false,
									  &bytesRead,
									  NULL,
									  packetNum1,
									  &numPackets1,
									  newBuffer);
        
        
        if (status) {
            goto reterr;
        }
        
		// if buffer was not filled, fill with zeros
        
        if (bytesRead < BUFFER_SIZE) {
            bzero(newBuffer + bytesRead, (BUFFER_SIZE - bytesRead));
            //NSLog(@"bzero");
        }
        
        packetNum1 += numPackets1;
       		
        
		// If no frames were returned, conversion is finished
        if (numPackets1 == 0)
            break;
        
		// Write pcm data to output file
        
        int maxNumPackets;
        maxNumPackets = numPackets1; 
        
        //int numSamples = (numPackets1 * inputDataFormat.mBytesPerPacket) / sizeof(int16_t);
        
		// write the mixed packets to the output file
        
        UInt32 packetsWritten = maxNumPackets;
        //NSLog(@"MaxNumPackets: %d",maxNumPackets);
        status = AudioFileWritePackets(existingAudioFileID,
                                       FALSE,
                                       (maxNumPackets * inputDataFormat.mBytesPerPacket),
                                       NULL,
                                       existingPacketNum,
                                       &packetsWritten,
                                       newBuffer);
        if (status) {
            goto reterr;
        }
    
        if (packetsWritten != maxNumPackets) {
            status = kAudioFileInvalidPacketOffsetError;
            goto reterr;
        }
        existingPacketNum += packetsWritten;
        
    }
    
    
reterr:
    if (newAudioFileID != NULL) {
		close_status = AudioFileClose(newAudioFileID);
		assert(close_status == 0);
	}
	if (existingAudioFileID != NULL) {
		//assertclose_status = AudioFileClose(existingAudioFileID);
		//(close_status == 0);
	}
	if (stat == @"OSSTATUS_MIX_WOULD_CLIP") {
		//char *mixfile_str = (char*) [existingAudio UTF8String];
		//close_status = unlink(mixfile_str);
		assert(close_status == 0);
	}
	if (newBuffer != NULL) {
		free(newBuffer);
	}
	if (existingBuffer != NULL) {
		free(existingBuffer);
	}
    
	//return mixPath;
    

}


+ (void) _setDefaultAudioFormatFlags:(AudioStreamBasicDescription*)audioFormatPtr
						 numChannels:(NSUInteger)numChannels
{
	bzero(audioFormatPtr, sizeof(AudioStreamBasicDescription));
	
	audioFormatPtr->mFormatID = kAudioFormatLinearPCM;
	audioFormatPtr->mSampleRate = 44100.0;
	audioFormatPtr->mChannelsPerFrame = numChannels;
	audioFormatPtr->mBytesPerPacket = 2 * numChannels;
	audioFormatPtr->mFramesPerPacket = 1;
	audioFormatPtr->mBytesPerFrame = 2 * numChannels;
	audioFormatPtr->mBitsPerChannel = 16;
	audioFormatPtr->mFormatFlags = 0;
}

inline SInt16 TPMixSamples(SInt16 a, SInt16 b) {
    return  
    // If both samples are negative, mixed signal must have an amplitude between the lesser of A and B, and the minimum permissible negative amplitude
    a < 0 && b < 0 ?
    ((int)a + (int)b) - (((int)a * (int)b)/INT16_MIN) :
    
    // If both samples are positive, mixed signal must have an amplitude between the greater of A and B, and the maximum permissible positive amplitude
    ( a > 0 && b > 0 ?
     ((int)a + (int)b) - (((int)a * (int)b)/INT16_MAX)
     
     // If samples are on opposite sides of the 0-crossing, mixed signal should reflect that samples cancel each other out somewhat
     :
     a + b);
}

+(NSString *)createMixedAudiofromTextAudio:(NSString *)textAudioPath andRecording:(NSString *)recordingPath
{
    NSString* cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSArray * myArray = [recordingPath componentsSeparatedByString: @"/"];
    NSString * fileName = (NSString*)[myArray lastObject];
    NSString * mixPath = [cachesDirectory stringByAppendingPathComponent: [[fileName stringByDeletingPathExtension] stringByAppendingString:@"_mixed.caf"]];
    
    NSLog(@"start Mixing both");
    OSStatus status;
    status = [PCMMixer mix:textAudioPath file2:recordingPath mixfile:mixPath];

    if (status == OSSTATUS_MIX_WOULD_CLIP) {
		NSLog(@"Clipping");
	} 
    else {	
        /*
		NSURL *url = [NSURL fileURLWithPath:mixPath];
        NSURL *textUrl = [NSURL fileURLWithPath:textAudioPath];
        NSURL *recordingUrl = [NSURL fileURLWithPath:textAudioPath];
		
		NSData *urlData = [NSData dataWithContentsOfURL:url];
        NSData *textUrlData = [NSData dataWithContentsOfURL:textUrl];
        NSData *recordingUrlData = [NSData dataWithContentsOfURL:recordingUrl];
		
		NSLog(@"Wrote mix file of size %d : %@", [urlData length], mixPath);
        NSLog(@"TextAudio file of size %d : %@", [textUrlData length], textAudioPath);
        NSLog(@"RecordingAudio file of size %d : %@", [recordingUrlData length], recordingUrl);
         */
    }
    
    return mixPath;
}

+(NSString *)audioFilefromText:(NSString *)filePath toFile:(NSString *)mixPath
{
    NSLog(@"mixPath: %@",mixPath);
    NSURL *mixURL = [NSURL fileURLWithPath:mixPath];
    //NSString *resPath1 = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"caf"];
	//NSString *resPath2 = [[NSBundle mainBundle] pathForResource:@"2" ofType:@"caf"];
    NSString *startString = [[NSBundle mainBundle] pathForResource:@"0" ofType:@"caf"];
    //NSURL *url1 = [NSURL fileURLWithPath:resPath1];
	//NSURL *url2 = [NSURL fileURLWithPath:resPath2];
    
    

    
    
    //CFURLRef cURL1 = (__bridge CFURLRef)url1;
    //CFURLRef cURL2 = (__bridge CFURLRef)url2;
    CFURLRef mURL = (__bridge CFURLRef)mixURL;
    
    //NSString * stat = nil;
    
    OSStatus status;
    
    
    NSArray * taps = [UBCFileReader TapsArrayWithFile:filePath];
    UBCTap * start = (UBCTap *)[taps objectAtIndex:0];
    UBCTap * end = (UBCTap *)[taps  lastObject];
    NSTimeInterval length = [end.date timeIntervalSinceDate:start.date];
    NSLog(@"Track length: %f",length);
    
    AudioStreamBasicDescription inputDataFormat;
    
    //AudioFileID inAudioFile1 = NULL;
	//AudioFileID inAudioFile2 = NULL;
    AudioFileID mixAudioFile = NULL;
    
    //bzero(inputDataFormat, sizeof(AudioStreamBasicDescription));
	
	inputDataFormat.mFormatID = kAudioFormatLinearPCM;
	inputDataFormat.mSampleRate = 22050.0;
	inputDataFormat.mChannelsPerFrame = 1;
	inputDataFormat.mBytesPerPacket = 2;
	inputDataFormat.mFramesPerPacket = 1;
	inputDataFormat.mBytesPerFrame = 2;
	inputDataFormat.mBitsPerChannel = 16;
	inputDataFormat.mFormatFlags = kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsSignedInteger |kAudioFormatFlagIsPacked;
    
    status = AudioFileCreateWithURL(mURL, kAudioFileCAFType, &inputDataFormat, kAudioFileFlags_EraseFile, &mixAudioFile);
    NSLog(@"Audio status %ld",status);
    [UBCAudioMixer writeAudio:startString toExistingAudio:mixAudioFile atPacket:0];
    //[UBCAudioMixer writeAudio:resPath2 toExistingAudio:mixAudioFile atPacket:20000];
    
    //22050 packets / second
    for (UBCTap * tap in taps) 
    {
        NSTimeInterval timeElapsed = [tap timeIntervalSinceTap:start];
        SInt64 packets =(SInt64)(timeElapsed*22050.0);
        NSString * numString = [NSString stringWithFormat:@"%d",tap.num];
        NSString *resourceString;
        if (tap.num>=0)
            resourceString = [[NSBundle mainBundle] pathForResource:numString ofType:@"caf"];
        else 
            resourceString = [[NSBundle mainBundle] pathForResource:@"end" ofType:@"caf"];
        [UBCAudioMixer writeAudio:resourceString toExistingAudio:mixAudioFile atPacket:packets];
        
    }
    return mixPath;
    
}

-(NSString *) convertForExport:(NSString *)fileSubName
{
    NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* destPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",fileSubName,@"m4a"]];
    NSString* sourcePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",fileSubName,@"caf"]];
    NSLog(@"source file %@",sourcePath);
    //NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    audioConverter = [[TPAACAudioConverter alloc] initWithDelegate:self 
                                                             source:sourcePath
                                                        destination:destPath];
    [audioConverter start];
    
    return destPath;
    
}
-(void) compressAudio:(NSString *)sourcePath toDest:(NSString *) destinationPath
{
    audioConverter = [[TPAACAudioConverter alloc] initWithDelegate:self 
                                                            source:sourcePath
                                                       destination:destinationPath];
    [audioConverter start];
    
}

-(void)makeAllFilesfrom:(NSString *)fileSubName
{
    //Need to create all before hand
    
    NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString* numbersAudioCAF = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",fileSubName,@"caf"]];
    NSString* micAudioCAF = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",fileSubName,@"caf"]];
    NSString* mixedAudioCAF = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_mixed.%@",fileSubName,@"caf"]];
    NSString* txtFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",fileSubName,@"txt"]];
    
    NSString* numbersAudoCompressed = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_numbers.%@",fileSubName,@"m4a"]];
    NSString* micAudioCompressed = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_mic.%@",fileSubName,@"m4a"]];
    NSString* mixedAudioCompressed = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_mixed.%@",fileSubName,@"m4a"]];
    
    [UBCAudioMixer audioFilefromText:txtFilePath toFile:numbersAudioCAF]; //Created textAudioCAF
    //[UBCAudioMixer createMixedAudiofromTextAudio:numbersAudioCAF andRecording:micAudioCAF]; //Created Mix audio
    [PCMMixer mixedAudioFromTextAudio:txtFilePath MicAudioPath:micAudioCAF toMixPath:mixedAudioCAF];
    
    
    //Compress all three
    [self compressAudio:numbersAudioCAF toDest:numbersAudoCompressed];
    [self compressAudio:micAudioCAF toDest:micAudioCompressed];
    [self compressAudio:mixedAudioCAF toDest:mixedAudioCompressed];
    
    
}

#pragma mark - Audio converter delegate

// Callback to be notified of audio session interruptions (which have an impact on the conversion process)
static void interruptionListener(void *inClientData, UInt32 inInterruption)
{
    UBCAudioMixer *THIS = (__bridge UBCAudioMixer *)inClientData;
    
    if (inInterruption == kAudioSessionEndInterruption) {
        // make sure we are again the active session
        //checkResult(AudioSessionSetActive(true), "resume audio session");
        if ( THIS->audioConverter ) [THIS->audioConverter resume];
    }
    
    if (inInterruption == kAudioSessionBeginInterruption) {
        if ( THIS->audioConverter ) [THIS->audioConverter interrupt];
    }
}

/*snip*/

-(void)startConverting {
    
    /*snip*/
    
    // Initialise audio session, and register an interruption listener, important for AAC conversion
    if ( !checkResult(AudioSessionInitialize(NULL, NULL, interruptionListener,(__bridge void*) self), "initialise audio session") ) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Converting audio", @"")
                                     message:NSLocalizedString(@"Couldn't initialise audio session!", @"")
                                    delegate:nil
                           cancelButtonTitle:nil
                           otherButtonTitles:NSLocalizedString(@"OK", @""), nil] show];
        return;
    }
    
    
    // Set up an audio session compatible with AAC conversion.  Note that AAC conversion is incompatible with any session that provides mixing with other device audio.
    UInt32 audioCategory = kAudioSessionCategory_MediaPlayback;
    if ( !checkResult(AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory), "setup session category") ) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Converting audio", @"")
                                     message:NSLocalizedString(@"Couldn't setup audio category!", @"")
                                    delegate:nil
                           cancelButtonTitle:nil
                           otherButtonTitles:NSLocalizedString(@"OK", @""), nil] show];
        return;
    } 
    
    /*snip*/
}


-(void)AACAudioConverterDidFinishConversion:(TPAACAudioConverter *)converter {
    NSLog(@"DONE CONVERT");
}

-(void)AACAudioConverter:(TPAACAudioConverter *)converter didFailWithError:(NSError *)error {
    NSLog(@"error");
}



@end
