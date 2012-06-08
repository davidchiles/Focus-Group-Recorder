//
//  PCMMixer.m
//
//  Created by Moses DeJong on 3/25/09.
//

#import "PCMMixer.h"
#import "UBCFileReader.h"

#import <unistd.h>

// Mix sample data from two buffers, if clipping is detected
// then we have to exit the mix operation.
#if !defined(MIN)
#define MIN(A,B)((A) < (B) ? (A) : (B))
#endif

#if !defined(MAX)
#define MAX(A,B)((A) > (B) ? (A) : (B))
#endif
static
inline
BOOL mix_buffers(const int16_t *buffer1,
				 const int16_t *buffer2,
				 int16_t *mixbuffer,
				 int mixbufferNumSamples)
{
	BOOL clipping = FALSE;
    
    int32_t max= 0;
    int32_t min= 0;
    
	for (int i = 0 ; i < mixbufferNumSamples; i++) {
		int32_t s1 = buffer1[i];
		int32_t s2 = buffer2[i];
		int32_t mixed = (s1 + s2);
        //mixed = s1;
        max= MAX(max, mixed);
        min= MIN(min, mixed);
        max= MAX(abs(min), max);
        
		if (mixed < -32768) {
			clipping = TRUE;
            //mixed = -32767;
			//break;
		} 
        else if(mixed > 32767)
        {
            //mixed = 32767;
        }
        
        //mixbuffer[i] = (int16_t) mixed;
	}
    //NSLog(@"\nMin: %d \nMax: %d",min,max);
    for (int i=0 ; i < mixbufferNumSamples; i++) {
        int32_t s1 = buffer1[i];
		int32_t s2 = buffer2[i];
        int32_t mixed = (s1 + s2);
        if (max > 32767.0) {
            //mixed = mixed*(32767.0/max);
            //mixed = mixed - (s1*s2)-32767;
        }
        mixbuffer[i] = (int32_t) mixed;
        //mixbuffer[i] = (int16_t) s1;
        //mixbuffer[i] = (int16_t) s2;
    }

	return clipping;
}
@implementation PCMMixer	

+ (void) _setDefaultAudioFormatFlags:(AudioStreamBasicDescription*)audioFormatPtr
						 numChannels:(NSUInteger)numChannels
{
	bzero(audioFormatPtr, sizeof(AudioStreamBasicDescription));
	
	audioFormatPtr->mFormatID = kAudioFormatLinearPCM;
	audioFormatPtr->mSampleRate = 22050.0;
	audioFormatPtr->mChannelsPerFrame = numChannels;
	audioFormatPtr->mBytesPerPacket = 2 * numChannels;
	audioFormatPtr->mFramesPerPacket = 1;
	audioFormatPtr->mBytesPerFrame = 2 * numChannels;
	audioFormatPtr->mBitsPerChannel = 16;
	audioFormatPtr->mFormatFlags = kAudioFormatFlagIsBigEndian |
	kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;	
}
+ (SInt16) TPMixSamples:(SInt16) a and: (SInt16) b {
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
+ (OSStatus) mix:(NSString*)file1 file2:(NSString*)file2 mixfile:(NSString*)mixfile
{


	OSStatus status, close_status;

	NSURL *url1 = [NSURL fileURLWithPath:file1];
	NSURL *url2 = [NSURL fileURLWithPath:file2];
	NSURL *mixURL = [NSURL fileURLWithPath:mixfile];

	AudioFileID inAudioFile1 = NULL;
	AudioFileID inAudioFile2 = NULL;
	AudioFileID mixAudioFile = NULL;

#ifndef TARGET_OS_IPHONE
	// Why is this constant missing under Mac OS X?
# define kAudioFileReadPermission fsRdPerm
#endif
	
#define BUFFER_SIZE 4096
	char *buffer1 = NULL;
	char *buffer2 = NULL;
	char *mixbuffer = NULL;	

	status = AudioFileOpenURL((CFURLRef)url1, kAudioFileReadPermission, 0, &inAudioFile1);
    if (status)
	{
		goto reterr;
	}	

	status = AudioFileOpenURL((CFURLRef)url2, kAudioFileReadPermission, 0, &inAudioFile2);
    if (status)
	{
		goto reterr;
	}

	// Verify that file contains pcm data at 44 kHz

    AudioStreamBasicDescription inputDataFormat;
	UInt32 propSize = sizeof(inputDataFormat);

	bzero(&inputDataFormat, sizeof(inputDataFormat));
    status = AudioFileGetProperty(inAudioFile1, kAudioFilePropertyDataFormat,
								  &propSize, &inputDataFormat);

    if (status)
	{
		goto reterr;
	}

	if ((inputDataFormat.mFormatID == kAudioFormatLinearPCM) &&
		(inputDataFormat.mSampleRate == 44100.0) &&
		(inputDataFormat.mChannelsPerFrame == 1) &&
		(inputDataFormat.mChannelsPerFrame == 1) &&
		(inputDataFormat.mBitsPerChannel == 16) &&
		(inputDataFormat.mFormatFlags == (kAudioFormatFlagsNativeEndian |
										  kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger))
		) {
		// no-op when the expected data format is found
	} else {
		status = kAudioFileUnsupportedFileTypeError;
		//goto reterr;
	}

	// Do the same for file2

	propSize = sizeof(inputDataFormat);

	bzero(&inputDataFormat, sizeof(inputDataFormat));
    status = AudioFileGetProperty(inAudioFile2, kAudioFilePropertyDataFormat,
								  &propSize, &inputDataFormat);

    if (status)
	{
		goto reterr;
	}
	
	if ((inputDataFormat.mFormatID == kAudioFormatLinearPCM) &&
		(inputDataFormat.mSampleRate == 44100.0) &&
		(inputDataFormat.mChannelsPerFrame == 1) &&
		(inputDataFormat.mChannelsPerFrame == 1) &&
		(inputDataFormat.mBitsPerChannel == 16) &&
		(inputDataFormat.mFormatFlags == (kAudioFormatFlagsNativeEndian |
										  kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger))
		) {
		// no-op when the expected data format is found
	} else {
		status = kAudioFileUnsupportedFileTypeError;
		//goto reterr;
	}

	// Both input files validated, open output (mix) file

	[self _setDefaultAudioFormatFlags:&inputDataFormat numChannels:1];

	status = AudioFileCreateWithURL((CFURLRef)mixURL, kAudioFileCAFType, &inputDataFormat,
									kAudioFileFlags_EraseFile, &mixAudioFile);
    if (status)
	{
		goto reterr;
	}

	// Read buffer of data from each file

	buffer1 = malloc(BUFFER_SIZE);
	assert(buffer1);
	buffer2 = malloc(BUFFER_SIZE);
	assert(buffer2);
	mixbuffer = malloc(BUFFER_SIZE);
	assert(mixbuffer);

	SInt64 packetNum1 = 0;
	SInt64 packetNum2 = 0;
	SInt64 mixpacketNum = 0;

	UInt32 numPackets1;
	UInt32 numPackets2;

	while (TRUE) {
		// Read a chunk of input

		UInt32 bytesRead;

		numPackets1 = BUFFER_SIZE / inputDataFormat.mBytesPerPacket;
		status = AudioFileReadPackets(inAudioFile1,
									  false,
									  &bytesRead,
									  NULL,
									  packetNum1,
									  &numPackets1,
									  buffer1);

		if (status) {
			goto reterr;
		}

		// if buffer was not filled, fill with zeros

		if (bytesRead < BUFFER_SIZE) {
			bzero(buffer1 + bytesRead, (BUFFER_SIZE - bytesRead));
		}

		packetNum1 += numPackets1;
        

		numPackets2 = BUFFER_SIZE / inputDataFormat.mBytesPerPacket;
		status = AudioFileReadPackets(inAudioFile2,
									  false,
									  &bytesRead,
									  NULL,
									  packetNum2,
									  &numPackets2,
									  buffer2);

		if (status) {
			goto reterr;
		}

		// if buffer was not filled, fill with zeros
		
		if (bytesRead < BUFFER_SIZE) {
			bzero(buffer2 + bytesRead, (BUFFER_SIZE - bytesRead));
		}		

		packetNum2 += numPackets2;

		// If no frames were returned, conversion is finished

		if (numPackets1 == 0 && numPackets2 == 0)
			break;

		// Write pcm data to output file

		int maxNumPackets;
		if (numPackets1 > numPackets2) {
			maxNumPackets = numPackets1; 
		} else {
			maxNumPackets = numPackets2;
		}

		int numSamples = (numPackets1 * inputDataFormat.mBytesPerPacket) / sizeof(int16_t);

		BOOL clipping = mix_buffers((const int16_t *)buffer1, (const int16_t *)buffer2,(int16_t *) mixbuffer, numSamples);
        
        //mixbuffer =(char *)[PCMMixer TPMixSamples:(SInt16)buffer1 and:(SInt16)buffer2];

		if (clipping) {
			status = OSSTATUS_MIX_WOULD_CLIP;
			//goto reterr;
		}

		// write the mixed packets to the output file

		UInt32 packetsWritten = maxNumPackets;

		status = AudioFileWritePackets(mixAudioFile,
										FALSE,
										(maxNumPackets * inputDataFormat.mBytesPerPacket),
										NULL,
										mixpacketNum,
										&packetsWritten,
										mixbuffer);

		if (status) {
			goto reterr;
		}
		
		if (packetsWritten != maxNumPackets) {
			status = kAudioFileInvalidPacketOffsetError;
			goto reterr;
		}

		mixpacketNum += packetsWritten;
	}	

reterr:
	if (inAudioFile1 != NULL) {
		close_status = AudioFileClose(inAudioFile1);
		assert(close_status == 0);
	}
	if (inAudioFile2 != NULL) {
		close_status = AudioFileClose(inAudioFile2);
		assert(close_status == 0);
	}
	if (mixAudioFile != NULL) {
		close_status = AudioFileClose(mixAudioFile);
		assert(close_status == 0);
	}
	if (status == OSSTATUS_MIX_WOULD_CLIP) {
		char *mixfile_str = (char*) [mixfile UTF8String];
		close_status = unlink(mixfile_str);
		assert(close_status == 0);
	}
	if (buffer1 != NULL) {
		free(buffer1);
	}
	if (buffer2 != NULL) {
		free(buffer2);
	}
	if (mixbuffer != NULL) {
		free(mixbuffer);
	}

	return status;
}

+(void)mixedAudioFromTextAudio: (NSString*) textPath MicAudioPath: (NSString *) micAudioPath toMixPath:(NSString *) mixAudioPath
{
    CFURLRef mixAudioCFURL = (__bridge CFURLRef)[NSURL fileURLWithPath:mixAudioPath];
    CFURLRef micAudioCFURL = (__bridge CFURLRef)[NSURL fileURLWithPath:micAudioPath];
    
    NSArray * taps = [UBCFileReader TapsArrayWithFile:textPath];
    UBCTap * start = (UBCTap *)[taps objectAtIndex:0];
    UBCTap * end = (UBCTap *)[taps  lastObject];
    NSTimeInterval length = [end.date timeIntervalSinceDate:start.date];
    NSLog(@"Track length: %f",length);
    
    AudioStreamBasicDescription inputDataFormat;
    AudioFileID mixAudioFile = nil;
    AudioFileID micAudioFileID = nil;
    
    inputDataFormat.mFormatID = kAudioFormatLinearPCM;
	inputDataFormat.mSampleRate = 22050.0;
	inputDataFormat.mChannelsPerFrame = 1;
	inputDataFormat.mBytesPerPacket = 2;
	inputDataFormat.mFramesPerPacket = 1;
	inputDataFormat.mBytesPerFrame = 2;
	inputDataFormat.mBitsPerChannel = 16;
	inputDataFormat.mFormatFlags = kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsSignedInteger |kAudioFormatFlagIsPacked;
    
    OSStatus status = AudioFileCreateWithURL(mixAudioCFURL, kAudioFileCAFType, &inputDataFormat, kAudioFileFlags_EraseFile, &mixAudioFile);
    NSLog(@"Audio status %ld",status);
    
    status = AudioFileOpenURL(micAudioCFURL, kAudioFileReadPermission, 0, &micAudioFileID);
    
    
    for (UBCTap * tap in taps)
    {
        AudioFileID numberAudioFileID = nil;
        NSTimeInterval timeElapsed = [tap timeIntervalSinceTap:start];
        SInt64 packets =(SInt64)(timeElapsed*22050.0);
        NSString * numString = [NSString stringWithFormat:@"%d",tap.num];
        NSString *resourceString;
        if (tap.num>=0)
        {
            resourceString = [[NSBundle mainBundle] pathForResource:numString ofType:@"caf"];
        }
        else {
            resourceString = [[NSBundle mainBundle] pathForResource:@"end" ofType:@"caf"];
        }
        CFURLRef textAudioCFURL = (__bridge CFURLRef)[NSURL fileURLWithPath:resourceString];
        status = AudioFileOpenURL(textAudioCFURL, kAudioFileReadPermission, 0, &numberAudioFileID);
        
        [PCMMixer writeAudio:numberAudioFileID toExisistingAudio:mixAudioFile withMicAudio:micAudioFileID aPacket:packets];
        AudioFileClose(numberAudioFileID);
    }
    AudioFileClose(mixAudioFile);
    AudioFileClose(micAudioFileID);
    
    
}

//currently used

+(void) writeAudio: (AudioFileID) numberAudioFileID toExisistingAudio: (AudioFileID) existingAudioFileID withMicAudio: (AudioFileID) micAudioFileID aPacket: (SInt64) packet
{
    
    OSStatus status, close_status = 0;
    
    AudioStreamBasicDescription inputDataFormat;
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
    
    char *buffer1 = nil;
	char *buffer2 = nil;
    char *mixbuffer = nil;	
    
    buffer1 = malloc(BUFFER_SIZE);
	assert(buffer1);
	buffer2 = malloc(BUFFER_SIZE);
	assert(buffer2);
	mixbuffer = malloc(BUFFER_SIZE);
	assert(mixbuffer);
    
    //AudioStreamBasicDescription inputDataFormat;
	UInt32 propSize = sizeof(inputDataFormat);
    
	bzero(&inputDataFormat, sizeof(inputDataFormat));
    status = AudioFileGetProperty(existingAudioFileID, kAudioFilePropertyDataFormat,
								  &propSize, &inputDataFormat);
    
    if (status)
	{
		//goto reterr;
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
    
	SInt64 packetNum1 = 0;
	SInt64 existingPacketNum = packet;
    
    UInt64 packetCount;
    UInt32 size = sizeof(packetCount);
    status = AudioFileGetProperty( existingAudioFileID, kAudioFilePropertyAudioDataPacketCount, &size, &packetCount );
    if (status)
    {
        NSLog(@"error getting packet count %ld",status);
    }
    //NSLog(@"CurrentPacketCount before any writing: %llu",packetCount);
    SInt64 currentEndPacket = packetCount;
    
	UInt32 numPackets1;
    
    ////////////////////Copy mic audio to new file////////////
    while (currentEndPacket < existingPacketNum) {
        UInt32 bytesRead;
        
        numPackets1 = BUFFER_SIZE / inputDataFormat.mBytesPerPacket;
        status = AudioFileReadPackets(micAudioFileID,
									  false,
									  &bytesRead,
									  NULL,
									  currentEndPacket,
									  &numPackets1,
									  buffer1);
        
        if (bytesRead < BUFFER_SIZE) {
            bzero(buffer1 + bytesRead, (BUFFER_SIZE - bytesRead));
            NSLog(@"bzero");
        }
        packetNum1 += numPackets1;
        
        if (numPackets1 == 0)
            break;
        
        int maxNumPackets;
        maxNumPackets = numPackets1; 
        UInt32 packetsWritten = maxNumPackets;
        status = AudioFileWritePackets(existingAudioFileID,
                                       FALSE,
                                       (maxNumPackets * inputDataFormat.mBytesPerPacket),
                                       NULL,
                                       currentEndPacket,
                                       &packetsWritten,
                                       buffer1);
        
        
        
        currentEndPacket += packetsWritten;
        //NSLog(@"Current End Packet Written: %lld",currentEndPacket);
    }
    
    packetNum1 = 0;
    
	if (buffer1 != nil) {
        //free(buffer1);
    }
    
   
    
	//SInt64 packetNum1 = 0;
	SInt64 packetNum2 = 0;
	//SInt64 mixpacketNum = 0;
    
	//UInt32 numPackets1;
	UInt32 numPackets2;
    
    while (TRUE) {
		// Read a chunk of input
        
		UInt32 bytesRead;
        
		numPackets1 = BUFFER_SIZE / inputDataFormat.mBytesPerPacket;
		status = AudioFileReadPackets(numberAudioFileID,
									  false,
									  &bytesRead,
									  NULL,
									  packetNum1,
									  &numPackets1,
									  buffer1);
        
		if (status) {
			//goto reterr;
		}
        if (numPackets1 == 0)
			break;
		// if buffer was not filled, fill with zeros
        
		if (bytesRead < BUFFER_SIZE) {
			bzero(buffer1 + bytesRead, (BUFFER_SIZE - bytesRead));
		}
        
		packetNum1 += numPackets1;
        
		numPackets2 = BUFFER_SIZE / inputDataFormat.mBytesPerPacket;
		status = AudioFileReadPackets(micAudioFileID,
									  false,
									  &bytesRead,
									  NULL,
									  currentEndPacket,
									  &numPackets2,
									  buffer2);
        
		if (status) {
			//goto reterr;
		}
        
		// if buffer was not filled, fill with zeros
		
		if (bytesRead < BUFFER_SIZE) {
			bzero(buffer2 + bytesRead, (BUFFER_SIZE - bytesRead));
		}		
        
		packetNum2 += numPackets2;
        
		// If no frames were returned, conversion is finished
        
		//if (numPackets1 == 0 || numPackets2 == 0)
        
        
		// Write pcm data to output file
        
		int maxNumPackets;
		if (numPackets1 > numPackets2) {
			maxNumPackets = numPackets2; 
		} else {
			maxNumPackets = numPackets1;
		}
        
		int numSamples = (numPackets1 * inputDataFormat.mBytesPerPacket) / sizeof(int16_t);
        
		BOOL clipping = mix_buffers((const int16_t *)buffer1, (const int16_t *)buffer2,(int16_t *) mixbuffer, numSamples);
        
        //mixbuffer =(char *)[PCMMixer TPMixSamples:(SInt16)buffer1 and:(SInt16)buffer2];
        
		if (clipping) {
			status = OSSTATUS_MIX_WOULD_CLIP;
			//goto reterr;
		}
        
		// write the mixed packets to the output file
        
		UInt32 packetsWritten = maxNumPackets;
        
		status = AudioFileWritePackets(existingAudioFileID,
                                       FALSE,
                                       (maxNumPackets * inputDataFormat.mBytesPerPacket),
                                       NULL,
                                       currentEndPacket,
                                       &packetsWritten,
                                       mixbuffer);
        
		if (status) {
            NSLog(@"goto reterr");
            
			goto reterr;
		}
		
		if (packetsWritten != maxNumPackets) {
			status = kAudioFileInvalidPacketOffsetError;
			goto reterr;
		}
        
		currentEndPacket += packetsWritten;
        //NSLog(@"Current End Packet after writing: %lld",currentEndPacket);
	}

reterr:
	if (numberAudioFileID != NULL) {
		//close_status = AudioFileClose(inAudioFile1);
		assert(close_status == 0);
	}
	if (micAudioFileID != NULL) {
		//close_status = AudioFileClose(inAudioFile2);
		assert(close_status == 0);
	}
	if (existingAudioFileID != NULL) {
		//close_status = AudioFileClose(existingAudioFileID);
		//assert(close_status == 0);
	}
	if (status == OSSTATUS_MIX_WOULD_CLIP) {
		//char *mixfile_str = (char*) [mixfile UTF8String];
		//close_status = unlink(mixfile_str);
		//assert(close_status == 0);
	}
	if (buffer1 != NULL) {
		free(buffer1);
	}
	if (buffer2 != NULL) {
		free(buffer2);
	}
	if (mixbuffer != NULL) {
		free(mixbuffer);
	}
    
    
}

@end
