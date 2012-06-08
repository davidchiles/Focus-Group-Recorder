//
//  UBCMainViewController.m
//  UCSF Book Club
//
//  Created by David Chiles on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UBCMainViewController.h"
#import "math.h"
#import <QuartzCore/QuartzCore.h>



@interface UBCMainViewController ()

@end

@implementation UBCMainViewController


@synthesize flipsidePopoverController = _flipsidePopoverController;
@synthesize filePopoverControler = _filePopoverControler;
@synthesize circleView;
@synthesize avAudio;
@synthesize currentFilePath;
@synthesize recordButton;
@synthesize numberOfButtons;
@synthesize buttons;
@synthesize normalImageBackground, selectedImageBackground,recordingBackground,notRecordingBackground;
@synthesize startTap;
@synthesize timer,timerCount, timerLabel;
@synthesize undoButton;
@synthesize lastButton;
@synthesize recorder;
@synthesize settingsButton, fileButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    currentFilePath = @"test.txt";
    
    [recordButton setTitle:@"Start" forState:UIControlStateNormal];
    //[recordButton setBackgroundColor:[UIColor redColor]];
    [recordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    recordButton.titleLabel.font = [UIFont systemFontOfSize:24];
    [[recordButton layer] setCornerRadius:recordButton.frame.size.height/2];
    [[recordButton layer] setMasksToBounds:YES];
    [[recordButton layer] setBorderWidth:1.0f];
    recordButton.tag = 0;
    self.buttons = [[NSMutableArray alloc] init];
    
    normalImageBackground = [[UIImage alloc]init];
    selectedImageBackground = [[UIImage alloc] init];
    recordingBackground = [[UIImage alloc]init];
    notRecordingBackground = [[UIImage alloc]init];
    normalImageBackground = [self imageWithColor:[UIColor orangeColor]];
    selectedImageBackground = [self imageWithColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.5f alpha:1.0f]];
    recordingBackground = [self imageWithColor:[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f]];
    notRecordingBackground = [self imageWithColor:[UIColor greenColor]];
    
    [recordButton setBackgroundImage:[notRecordingBackground stretchableImageWithLeftCapWidth:recordButton.frame.size.height topCapHeight:0] forState:UIControlStateNormal];
    [recordButton setBackgroundImage:[selectedImageBackground stretchableImageWithLeftCapWidth:recordButton.frame.size.height topCapHeight:0] forState:UIControlStateSelected];
    
    
    self.numberOfButtons = 0;
    [self setupButtons:10];
    
    //NSString *tmpFilename = @"finished.caf";
    //NSString *tmpfilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:tmpFilename]];
    //[UBCAudioMixer audioFilefromText:filePath toFile:tmpfilePath];
    
    //NSURL *url = [NSURL fileURLWithPath:tmpfilePath];
    
    //NSData *urlData = [NSData dataWithContentsOfURL:url];
    
    //NSLog(@"wrote mix file of size %d : %@", [urlData length], tmpfilePath);
    
    //AVAudioPlayer *avAudioObj = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    //self.avAudio = avAudioObj;
    
    //[avAudio prepareToPlay];
    //[avAudio play];	
    
    
    
}

-(float)getButtonSizefromNumberofButtons:(int)bts inView:(UIView *)view
{
    float buttonSize = 200;
    
    
    float angle = (360.0f/(float)bts)*M_PI/180.0f;
    CGRect CircleViewFrame = view.frame;
    CGFloat height = CircleViewFrame.size.height;
    if (bts>2) {
        buttonSize = (height * sinf(angle))/(sinf(angle)+2);
        buttonSize = buttonSize/sqrt(2);
    }
    return buttonSize;
}

-(void)changeButtonLocation:(NSMutableArray *)buttonsArray inView:(UIView *)view
{
    float angle = (360.0f/(float)buttonsArray.count)*M_PI/180.0f;
    float buttonSize = [self getButtonSizefromNumberofButtons:buttonsArray.count inView:view];
    CGFloat limit = view.frame.size.height/2.0-buttonSize/2.0;
    CGFloat midX = view.frame.size.width/2;
    CGFloat midY = view.frame.size.height/2;
    int n =0;
    for(UIButton * button in buttonsArray)
    {
        float midXButton = (limit * cosf(angle*n+M_PI*1.5))+midX; 
        float midYButton = (limit * sinf(angle*n+M_PI*1.5))+midY;
        
        button.frame = CGRectMake(midXButton-buttonSize/2, midYButton-buttonSize/2, buttonSize, buttonSize);
        button.titleLabel.font = [UIFont systemFontOfSize:buttonSize/1.5];
        [[button layer] setCornerRadius:buttonSize/6];
        [button setBackgroundImage:[normalImageBackground stretchableImageWithLeftCapWidth:buttonSize topCapHeight:0] forState:UIControlStateNormal];
        [button setBackgroundImage:[selectedImageBackground stretchableImageWithLeftCapWidth:buttonSize topCapHeight:0] forState:UIControlStateSelected];
        
        n++;
    }
}

-(UIButton *)makeDefaultButtonWithNumber:(int)n Size:(float)buttonSize
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self 
               action:@selector(didTap:)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:[NSString stringWithFormat:@"%d",n] forState:UIControlStateNormal];
    
    [button setTag:n+1];
    button.autoresizingMask= UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [[button layer] setCornerRadius:buttonSize/6];
    [[button layer] setMasksToBounds:YES];
    [button setBackgroundImage:[normalImageBackground stretchableImageWithLeftCapWidth:buttonSize topCapHeight:0] forState:UIControlStateNormal];
    [button setBackgroundImage:[selectedImageBackground stretchableImageWithLeftCapWidth:buttonSize topCapHeight:0] forState:UIControlStateSelected];
    
    //[button setBackgroundColor:[UIColor orangeColor]];
    if (recordButton.tag == 0) {
        button.enabled = NO;
        button.alpha = 0.7f;
    }
    return button;
    
}

- (void)setupButtons:(int) bts
{
    for (UIButton * btn in buttons)
        [btn removeFromSuperview];
    
    [buttons removeAllObjects];
    float buttonSize = 200;
    
   
    float angle = (360.0f/(float)bts)*M_PI/180.0f;
    CGRect CircleViewFrame = self.circleView.frame;
    CGFloat height = CircleViewFrame.size.height;
    CGFloat width = CircleViewFrame.size.width;
    CGFloat limit;
    if (bts>2) {
        buttonSize = (height * sinf(angle))/(sinf(angle)+2);
        buttonSize = buttonSize/sqrt(2);
    }
    
    if(height > width)
        limit = width/2-buttonSize/2;
    else
        limit = height/2-buttonSize/2;

    CGFloat midX = width/2;
    CGFloat midY = height/2;
    
    for (int n = 0; n<bts; n++) 
    {
        //Get Button center
        float midXButton = (limit * cosf(angle*n+M_PI*1.5))+midX; 
        float midYButton = (limit * sinf(angle*n+M_PI*1.5))+midY;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self 
                   action:@selector(didTap:)
         forControlEvents:UIControlEventTouchDown];
        [button setTitle:[NSString stringWithFormat:@"%d",n+1] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:buttonSize/1.5];
        [button setTag:n+1];
        button.frame = CGRectMake(midXButton-buttonSize/2, midYButton-buttonSize/2, buttonSize, buttonSize);
        button.autoresizingMask= UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [[button layer] setCornerRadius:button.frame.size.height/6];
        [[button layer] setMasksToBounds:YES];
        [button setBackgroundImage:[normalImageBackground stretchableImageWithLeftCapWidth:buttonSize topCapHeight:0] forState:UIControlStateNormal];
        [button setBackgroundImage:[selectedImageBackground stretchableImageWithLeftCapWidth:buttonSize topCapHeight:0] forState:UIControlStateSelected];
        
        //[button setBackgroundColor:[UIColor orangeColor]];
        if (recordButton.tag == 0) {
            button.enabled = NO;
            button.alpha = 0.7f;
        }
        
        [self.buttons addObject:button];
        [circleView addSubview:button];
    }
    if (recordButton.tag == 0) {
        undoButton.enabled = NO;
    }
    self.numberOfButtons = bts;
    
}

- (IBAction)didTap:(UIButton *)button
{
    NSLog(@"Tapped: %d",button.tag);
    
    //Any Butotn pressed
    if (button.tag > 0) 
    {
        if (lastButton)
            lastButton.selected = NO;
        
        lastButton = button;
        lastButton.selected = YES;
        NSDate * currentDate = [NSDate date];
        UBCTap * tap = [[UBCTap alloc] initWithDate:currentDate Number:button.tag];
        [UBCOutput addTap:tap toFilePath:currentFilePath withStartTap:startTap];
        
    }
    else //Start or stop pressed
    {        
        [self switchRecordButton];
    }
    
}

- (void) switchRecordButton
{
    if (recordButton.tag == 0) 
    {
        [self startTimer];
        NSLog(@"start recording");
        NSDate * currentDate = [NSDate date];
        //currentFilePath = [NSString stringWithFormat:@"%f.txt",[[NSDate date] timeIntervalSince1970]]; //Set Current File Path
        currentFilePath = [NSString stringWithFormat:@"%@.txt",[UBCOutput fileDateFormat]];
        
        NSError *error;
        NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:currentFilePath]];
        
        
        NSString * stringToAdd =[NSString stringWithFormat:@"File Created at %@",[NSDate date]];
        [stringToAdd writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        NSString * audioFilePath = [[filePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"caf"];
        [self startAudioRecordingWithFilePath:[NSURL URLWithString:audioFilePath]];
        
        startTap = [[UBCTap alloc] initWithDate:currentDate Number:recordButton.tag];
        [UBCOutput addTap:startTap toFilePath:currentFilePath withStartTap:startTap];
        
        [recordButton setTitle:@"Stop" forState:UIControlStateNormal];
        [recordButton setBackgroundImage:[recordingBackground stretchableImageWithLeftCapWidth:recordButton.frame.size.height topCapHeight:0] forState:UIControlStateNormal];
        recordButton.tag = -1;
        
        for(UIButton *btn in buttons)
        {
            btn.enabled = YES;
            btn.alpha = 1.0f;
        }
        undoButton.enabled = YES;
        
    }
    else 
    {
        NSLog(@"stop recording");
        [self stopAudioRecording];
        [self stopTimer];
        NSDate * currentDate = [NSDate date];
        UBCTap * tap = [[UBCTap alloc] initWithDate:currentDate Number:recordButton.tag];
        [UBCOutput addTap:tap toFilePath:currentFilePath withStartTap:startTap];
        
        [recordButton setTitle:@"Start" forState:UIControlStateNormal];
        [recordButton setBackgroundImage:[notRecordingBackground stretchableImageWithLeftCapWidth:recordButton.frame.size.height topCapHeight:0] forState:UIControlStateNormal];
        recordButton.tag = 0;
        
        for(UIButton *btn in buttons)
        {
            btn.enabled = NO;
            btn.alpha = 0.7f;
        }
        undoButton.enabled = NO;
        lastButton.selected = NO;
    }
    
}

- (IBAction)undoTap:(id)sender
{
    if (lastButton) {
        lastButton.selected=NO;
    }
    int num = [UBCOutput undoLastTapfromFileName:currentFilePath];
    NSLog(@"lastButton: %d",num);
    NSLog(@"Number of Buttons: %d",buttons.count);
    if(num>0 && num<=buttons.count)
    {
        lastButton = (UIButton*)[buttons objectAtIndex:num-1];
        lastButton.selected = YES;
    }
}

-(void) changeNumberOfButtons:(int)num
{
    self.numberOfButtons = num;
    float buttonSize = [self getButtonSizefromNumberofButtons:num inView:circleView];
    while (num<buttons.count) //Remove Buttons
    {
        [(UIButton*)[buttons objectAtIndex:num] removeFromSuperview];
        [buttons removeObjectAtIndex:num];
    }
    while (num>buttons.count) //Add Buttons
    {
        int n = buttons.count+1;
        UIButton * button=[self makeDefaultButtonWithNumber:n Size:buttonSize];
        [circleView addSubview:button];
        [buttons addObject:button];
        n--;
    }
    NSLog(@"Change Button Location");
    [self changeButtonLocation:buttons inView:circleView];
}

- (UIImage *)imageWithColor:(UIColor *)color 
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)increaseTimerCount
{
    timerCount++;
    int minT = floor((timerCount)/600);
    int minU = floor((timerCount-minT*600)/60);
    int secT = floor((timerCount-(minU*60)-(minT*600))/10);
    int secU = timerCount-(minU*60)-(minT*600)-(secT*10);
    timerLabel.text = [NSString stringWithFormat:@"%d%d:%d%d",minT,minU,secT,secU];
}

- (void)startTimer
{
    timerCount=0;
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(increaseTimerCount) userInfo:nil repeats:YES];
    [timer fire];
    
}

- (void)stopTimer
{
    [timer invalidate];
}
-(void)startAudioRecordingWithFilePath:(NSURL *)fileUrl
{
    NSError *error;
    
    NSDictionary *recordSettings =
    
    [[NSDictionary alloc] initWithObjectsAndKeys:
     
     [NSNumber numberWithFloat: 22050.0],                 AVSampleRateKey,
     [NSNumber numberWithInt: kAudioFormatLinearPCM],  AVFormatIDKey,
     [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
     [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
     [NSNumber numberWithInt: 1],                        AVLinearPCMIsBigEndianKey,
     
     nil];
    
    AVAudioSession *session = [AVAudioSession sharedInstance]; [session setCategory:AVAudioSessionCategoryRecord error:nil];
    
    recorder = [[AVAudioRecorder alloc] initWithURL:fileUrl settings:recordSettings error:&error];
    recorder.delegate = self;
    
    if(error)
        NSLog(@"%@",[error description]);
    
    [recorder record];
    
}

-(void)stopAudioRecording
{
    [recorder stop];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    //circleView.center = self.view.center;
}


#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(UBCFlipsideViewController *)controller
{
    [self.flipsidePopoverController dismissPopoverAnimated:YES];
    //[self setupButtons:controller.numberOfPeople];
    if(controller.numberOfPeople != self.numberOfButtons)
        [self changeNumberOfButtons:controller.numberOfPeople];
}

-(void)fileViewControllerDidFinish:(UBCFileViewController *)controller
{
    [self.flipsidePopoverController dismissPopoverAnimated:YES];
}

- (IBAction)showInfo:(id)sender
{
    if ([self.filePopoverControler isPopoverVisible]) {
        [self.filePopoverControler dismissPopoverAnimated:NO];
    }
    if (!self.flipsidePopoverController) {
        UBCFlipsideViewController *controller = [[UBCFlipsideViewController alloc] initWithNibName:@"UBCFlipsideViewController" bundle:nil];
        controller.delegate = self;
        controller.numberOfPeople=self.numberOfButtons;
        
        self.flipsidePopoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
    }
    if ([self.flipsidePopoverController isPopoverVisible]) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    } else {
        [self.flipsidePopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

-(IBAction)showFiles:(id)sender
{
    if ([self.flipsidePopoverController isPopoverVisible]) {
        [self.flipsidePopoverController dismissPopoverAnimated:NO];
    }
    if (!self.filePopoverControler) {
        UBCFileViewController *controller = [[UBCFileViewController alloc] initWithNibName:@"UBCFileViewController" bundle:nil];
        //UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
        //popoverController.delegate = self;
        UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:controller];
        controller.navigationItem.title = @"Recordings";
        controller.delegate = self;
        
        self.filePopoverControler = [[UIPopoverController alloc] initWithContentViewController:navController];
        self.filePopoverControler.delegate = self;
    }
    if ([self.filePopoverControler isPopoverVisible]) {
        [self.filePopoverControler dismissPopoverAnimated:YES];
    } else {
        [self.filePopoverControler presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        fileButton.enabled = NO;
        settingsButton.enabled = NO;
    }
    
}

-(BOOL) popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    if(self.filePopoverControler != nil)
    {
        NSLog(@"Class: %@",[((UINavigationController *)(self.filePopoverControler.contentViewController)).topViewController class]);
        if([((UINavigationController *)(self.filePopoverControler.contentViewController)).topViewController isKindOfClass:[RecordingViewController class]])
        {
            NSLog(@"HUD: %d",((RecordingViewController *)((UINavigationController *)(self.filePopoverControler.contentViewController)).topViewController).HUD.isHidden);
            if (((RecordingViewController *)((UINavigationController *)(self.filePopoverControler.contentViewController)).topViewController).hudIsVisible)
            { 
                return NO;
            }
        }
    }
    fileButton.enabled = YES;
    settingsButton.enabled = YES;
    return YES;
}


@end
