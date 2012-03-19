//
//  UBCMainViewController.h
//  UCSF Book Club
//
//  Created by David Chiles on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "UBCFlipsideViewController.h"
#import "UBCFileViewController.h"
#import "UBCFileReader.h"
#import "UBCAudioMixer.h"

@interface UBCMainViewController : UIViewController <UBCFlipsideViewControllerDelegate, UBCFileViewControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (strong, nonatomic) UIPopoverController *filePopoverControler;
@property (strong, nonatomic) AVAudioPlayer *avAudio;
@property ( nonatomic) int numberOfButtons;
@property (strong, nonatomic) IBOutlet UIView *circleView;
@property (strong, nonatomic) NSString * currentFilePath;
@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) NSMutableArray * buttons;
@property (strong, nonatomic) UIImage * selectedImageBackground;
@property (strong, nonatomic) UIImage * normalImageBackground;
@property (strong, nonatomic) UIImage * recordingBackground;
@property (strong, nonatomic) UIImage * notRecordingBackground;
@property (strong, nonatomic) UBCTap * startTap;
@property (strong,nonatomic) IBOutlet UILabel * timerLabel;
@property (strong,nonatomic) NSTimer * timer;
@property (nonatomic) int timerCount;
@property (strong, nonatomic) IBOutlet UIButton * undoButton;
@property (strong, nonatomic) UIButton * lastButton;

- (IBAction)showInfo:(id)sender;
- (IBAction)showFiles:(id)sender;
- (IBAction)didTap:(UIButton *)button;
- (void)setupButtons:(int) numOfButons;
- (void) switchRecordButton;
- (UIImage *)imageWithColor:(UIColor *)color;
- (IBAction)undoTap:(id)sender;

- (void)increaseTimerCount;
- (void)startTimer;
- (void)stopTimer;

@end
