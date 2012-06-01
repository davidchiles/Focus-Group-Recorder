//
//  UBCFlipsideViewController.h
//  UCSF Book Club
//
//  Created by David Chiles on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@class UBCFlipsideViewController;

@protocol UBCFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(UBCFlipsideViewController *)controller;
@end

@interface UBCFlipsideViewController : UIViewController <UIPickerViewDelegate,UIPickerViewDataSource,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate>

@property (nonatomic) int numberOfPeople;
@property (strong, nonatomic) NSArray * contentList;
@property (strong, nonatomic) IBOutlet UIPickerView *numberPicker;
@property (weak, nonatomic) id <UBCFlipsideViewControllerDelegate> delegate;
@property (strong,nonatomic) IBOutlet UIButton * dropboxButton;
@property (nonatomic, strong) IBOutlet UITableView * settingsTable;
@property (nonatomic, strong) UITextField * pathText;
@property (nonatomic,strong) UIActionSheet *actionSheet;

- (IBAction)dropboxPressed:(id)sender;
- (IBAction)done:(id)sender;
- (void)dropboxLinked;
- (void)dismissActoinSheet;

@end
