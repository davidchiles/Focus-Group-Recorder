//
//  UBCFileViewController.m
//  UCSF Book Club
//
//  Created by David Chiles on 3/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UBCFileViewController.h"


@interface UBCFileViewController ()

@end

@implementation UBCFileViewController

@synthesize delegate = _delegate;
@synthesize fileTableView;
@synthesize numberOfFiles;
@synthesize fileList;
@synthesize HUD;
@synthesize emailPath, emailName, textData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 460.0);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    fileList = [[NSArray alloc] initWithArray:[UBCFileReader listFileAtPath]];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    fileList = [[NSArray alloc] initWithArray:[UBCFileReader listFileAtPath]];
    [fileTableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma Table

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return fileList.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [((UBCFileInfo*)[fileList objectAtIndex:indexPath.row]) getName];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"selected: %@",[fileList objectAtIndex:indexPath.row]);
    
    RecordingViewController * recordingView = [[RecordingViewController alloc] init];
    recordingView.fileInfo = [fileList objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:recordingView animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    /* view delete
    
    
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSMutableString* txtFileName =  [fileList objectAtIndex:indexPath.row];
    NSString* txtFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:txtFileName]];
    //NSMutableString* audioFileName =[txtFileName mutableCopy];
    //Get txt document
    //NSData *fileData = [NSData dataWithContentsOfFile:txtFilePath]; 
    
    
    //Chekc if Audio already exists
    NSLog(@"text name: %@",txtFileName);
    //[txtFileName replaceOccurrencesOfString:@".txt" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [txtFileName length])];
    emailName = txtFileName;
    emailName = [emailName substringToIndex:emailName.length-4];
    NSLog(@"Email Name: %@",emailName);
    NSString * checkAudioName = [emailName stringByAppendingString:@".m4a"];
    NSString * checkAudioPath = [documentsDirectory stringByAppendingPathComponent:checkAudioName];
    //[checkAudioPath replaceOccurrencesOfString:@"txt" withString:@"m4a" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [checkAudioPath length])];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:checkAudioPath];
    if (fileExists) {
        
        emailPath = checkAudioPath;
        [self finishedCompression];
    }
    else 
    {
        NSString * audioFileName = [emailName stringByAppendingString:@".caf"];
        NSString * cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * audioFilePath = [cachesDirectory stringByAppendingPathComponent:audioFileName];
        
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        
        HUD.delegate = self;
        [HUD show:YES];
        HUD.labelText = @"Creating...";
        
        
        
        [UBCAudioMixer audioFilefromText:txtFilePath toFile:audioFilePath];
        UBCAudioMixer * audioMixer = [[UBCAudioMixer alloc] init];
        
        HUD.labelText =@"Compressing...";
        
        emailPath =[audioMixer convertForExport:emailName];
        NSLog(@"Email Path: %@",emailPath);
        textData = [NSData dataWithContentsOfFile:txtFilePath];
        //[audioFileName replaceOccurrencesOfString:@".caf" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [audioFileName length])];
    }
    
    */ //delete view
    
    //emailName = audioFileName;
    /*
    [HUD hide:YES];
    
    NSLog(@"compressedPath: %@",compressedPath);
    
    //NSData *audioData = [NSData dataWithContentsOfFile:audioFilePath];
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    if([MFMailComposeViewController canSendMail])
        NSLog(@"Can Send Mail");
    else
        NSLog(@"Can't Send Mail");
    
    [picker setSubject:@"Cool File"];
    [picker addAttachmentData:fileData mimeType:@"text/plain" fileName:[fileList objectAtIndex:indexPath.row]];
    //[picker addAttachmentData:audioData mimeType:@"audio/caf" fileName:audioFileName];
    [picker setToRecipients:[NSArray array]];
    [picker setMessageBody:@"Checkout this cool file I found." isHTML:NO];
    [picker setMailComposeDelegate:self];
    [self presentModalViewController:picker animated:YES];
    */
    
    
}

-(void) finishedCompression
{
    [HUD hide:YES];
    
    
    NSError * error;
    NSString *deleteFilePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",emailName,@"caf"]];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:deleteFilePath error:&error]; //REMOVE OLD UNCOMPRESSED CAF FILE
    
    NSData *audioData = [NSData dataWithContentsOfFile:emailPath];
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    if([MFMailComposeViewController canSendMail])
        NSLog(@"Can Send Mail");
    else
        NSLog(@"Can't Send Mail");
    
    [picker setSubject:[NSString stringWithFormat:@"iPad Recording from %@",emailName]];
    [picker addAttachmentData:textData mimeType:@"text/plain" fileName:[NSString stringWithFormat:@"%@.txt",emailName]];
    [picker addAttachmentData:audioData mimeType:@"audio/mp4" fileName:[NSString stringWithFormat:@"%@.m4a",emailName]];
    [picker setToRecipients:[NSArray array]];
    [picker setMessageBody:@"There should be two files attached" isHTML:NO];
    [picker setMailComposeDelegate:self];
    [self presentModalViewController:picker animated:YES];
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}
- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
	HUD = nil;
}



@end
