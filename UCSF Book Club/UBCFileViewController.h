//
//  UBCFileViewController.h
//  UCSF Book Club
//
//  Created by David Chiles on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBCOutput.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "UBCFileReader.h"
#import "UBCAudioMixer.h"
#import "MBProgressHUD.h"
#import "RecordingViewController.h"


@class UBCFileViewController;

@protocol UBCFileViewControllerDelegate
- (void)fileViewControllerDidFinish:(UBCFileViewController *)controller;
@end

@interface UBCFileViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate, MBProgressHUDDelegate>

@property (nonatomic) int numberOfFiles;
//@property (nonatomic,strong) IBOutlet UINavigation
@property (strong, nonatomic) NSArray * fileList;
@property (strong, nonatomic) IBOutlet UITableView *fileTableView;
@property (weak, nonatomic) id <UBCFileViewControllerDelegate> delegate;
@property (strong,nonatomic) MBProgressHUD * HUD;
@property (strong,nonatomic) NSString * emailPath;
@property (strong,nonatomic) NSData * textData;
@property (strong,nonatomic) NSString * emailName;



-(void) finishedCompression;

@end
