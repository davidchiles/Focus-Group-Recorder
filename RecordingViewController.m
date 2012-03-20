//
//  RecordingViewController.m
//  UCSF Book Club
//
//  Created by David Chiles on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecordingViewController.h"

@interface RecordingViewController ()

@end

@implementation RecordingViewController

@synthesize makeAudioButton,uploadButton,deleteButton;
@synthesize infoTableView;
@synthesize fileInfo;
@synthesize content;
@synthesize HUD;
@synthesize dropbox;

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) viewWillAppear:(BOOL)animated
{
    CGSize size = CGSizeMake(320, 460); // size of view in popover
    self.contentSizeForViewInPopover = size;
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedCompression) name:@"finishedCompression" object:nil];
    //self.navigationItem.title=[NSString stringWithFormat:@"%d", [fileInfo getNumberOfParticipants]];
    [fileInfo getInfo];
    
    int hour = floor(fileInfo.length/3600);
    int minT = floor((fileInfo.length-hour*3600)/600);
    int minU = floor((fileInfo.length-minT*600-hour*3600)/60);
    int secT = floor((fileInfo.length-(minU*60)-(minT*600)-hour*3600)/10);
    int secU = fileInfo.length-(minU*60)-(minT*600)-(secT*10)-(hour*3600);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    
    
    
    NSString * startDate = [dateFormatter stringFromDate:fileInfo.startDate];
    NSString * length = [NSString stringWithFormat:@"%d:%d%d:%d%d",hour,minT,minU,secT,secU];
    NSString * participants = [NSString stringWithFormat:@"%d",fileInfo.numberOfParticipants];
    
    content = [[NSMutableArray alloc]initWithCapacity:3];
    
    [content addObject:[[NSDictionary alloc] initWithObjectsAndKeys:startDate,@"detailTextLabel",@"Start Time",@"textLabel", nil]];
    [content addObject:[[NSDictionary alloc] initWithObjectsAndKeys:length,@"detailTextLabel",@"Duration",@"textLabel", nil]];
    [content addObject:[[NSDictionary alloc] initWithObjectsAndKeys:participants,@"detailTextLabel",@"Participants",@"textLabel", nil]];
    
    self.navigationItem.title= [fileInfo getName];
    
    if(![[DBSession sharedSession] isLinked])
    {
        uploadButton.enabled = NO;
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(![[DBSession sharedSession] isLinked])
    {
        uploadButton.enabled = NO;
    }
    else {
        uploadButton.enabled = YES;
    }
}

- (void) makeAudio
{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
    
    NSString * audioFilePath = [[fileInfo.filePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"m4a"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:audioFilePath];
    if (fileExists) {
        NSLog(@"Audio File Exists");
        //emailPath = checkAudioPath;
        [self finishedCompression];
    }
    else 
    {
        NSLog(@"create Audio");
        NSString * audioFileName = [fileInfo.name stringByAppendingString:@".caf"];
        NSString * cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * audioFilePath = [cachesDirectory stringByAppendingPathComponent:audioFileName];
        
        
        HUD.labelText = @"Creating...";
        
    
        dispatch_queue_t q = dispatch_queue_create("queue", NULL);
        
        dispatch_async(q, ^{
            [UBCAudioMixer audioFilefromText:fileInfo.filePath toFile:audioFilePath];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                HUD.labelText =@"Compressing...";
                UBCAudioMixer * audioMixer = [[UBCAudioMixer alloc] init];
                [audioMixer convertForExport:fileInfo.name];
            });
        });
        
        dispatch_release(q);
        
        
        
        
        
        //UBCAudioMixer * audioMixer = [[UBCAudioMixer alloc] init];
        
        //HUD.labelText =@"Compressing...";
        
        //[audioMixer convertForExport:fileInfo.name];
        NSLog(@"Email Path: %@",fileInfo.filePath);
    }
    
    
}
-(void) finishedCompression
{
    //[HUD hide:YES];
    
    NSString * localPath = fileInfo.filePath;
    NSString * audioPath = [[fileInfo.filePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"m4a"];
    NSArray * localPaths = [[NSArray alloc] initWithObjects:localPath,audioPath, nil];
     NSString * destinationPath = @"/Book Club/Recordings/";
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"dropbox_path"])
    {
        destinationPath = [[NSUserDefaults standardUserDefaults] objectForKey:@"dropbox_path"];
    }
    NSLog(@"destination path: %@",destinationPath);
      
    //[[self restClient] uploadFile:fileName toPath:destinationPath withParentRev:nil fromPath:localPath];
    //[[self restClient] loadMetadata:[destinationPath stringByAppendingPathComponent:fileName]];
    //[[self restClient] loadMetadata:destinationPath];
    self.dropbox = [[UBCDropboxController alloc] init];
    dropbox.delegate = self;
    
    
    HUD.labelText = @"Uploading...";
    
    [dropbox uploadWithFiles:localPaths andDestinationFolder:destinationPath];
}
- (IBAction) uploadPressed:(UIButton *)sender
{
    //Upload to dropbox
    [self makeAudio];
}
- (IBAction) deletePressed:(UIButton *)sender
{
    
}

#pragma Table

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [content count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    NSDictionary * text = [content objectAtIndex:indexPath.row];
    cell.textLabel.text=[text objectForKey:@"textLabel"];
    cell.detailTextLabel.text = [text objectForKey:@"detailTextLabel"];
    
    //cell.textLabel.text = [fileList objectAtIndex:indexPath.row];
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma Dropbox

-(void)uploadsFinished:(int)num
{
    [HUD hide:YES];
}
-(void)uploadFialed
{
    
    HUD.labelText = @"Failed";
#ifdef __BLOCKS__
	
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		// Do a taks in the background
		sleep(2);
		// Hide the HUD in the main tread 
		dispatch_async(dispatch_get_main_queue(), ^{
			[MBProgressHUD hideHUDForView:self.view animated:YES];
		});
	});
#endif
}


@end
