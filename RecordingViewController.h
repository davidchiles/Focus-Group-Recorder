//
//  RecordingViewController.h
//  UCSF Book Club
//
//  Created by David Chiles on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBCFileInfo.h"
#import "UBCAudioMixer.h"
#import "MBProgressHUD.h"
#import "UBCDropboxController.h"

@interface RecordingViewController : UIViewController <UITableViewDelegate, UITableViewDelegate,DBRestClientDelegate,MBProgressHUDDelegate,UBCDropboxControllerDelegate>
{
    DBRestClient *restClient;
    NSArray *uploadType;
    int numberFinished;
}

@property (nonatomic,strong) IBOutlet UIButton * makeAudioButton;
@property (nonatomic,strong) IBOutlet UIButton * uploadButton;
@property (nonatomic,strong) IBOutlet UIButton * deleteButton;

@property (nonatomic,strong) IBOutlet UITableView * infoTableView;

@property (nonatomic,strong) UBCFileInfo * fileInfo;
@property (nonatomic,strong) NSMutableArray * content;
@property (nonatomic,strong) MBProgressHUD * HUD;
//@property (nonatomic) BOOL txtUploaded;
//@property (nonatomic) BOOL audioUploaded;
@property (nonatomic,strong) UBCDropboxController *dropbox;
@property (nonatomic) BOOL hudIsVisible;

- (IBAction) makeAudioPressed:(UIButton *)sender;
- (IBAction) uploadPressed:(UIButton *)sender;
- (IBAction) deletePressed:(UIButton *)sender;

-(void)finishedCompression;


@end
