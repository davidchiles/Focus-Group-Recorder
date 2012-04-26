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
        numberFinished = 0;
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
    
    NSMutableDictionary * textDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Text File",@"name", nil];
    NSMutableDictionary * micDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Mic Audio",@"name", nil];
    //NSMutableDictionary * numDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Number Audio",@"name", nil];
    NSMutableDictionary * mixDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Mixed Audio",@"name", nil];
    
    uploadType = [NSArray arrayWithObjects:textDictionary,micDictionary,mixDictionary, nil];
    
    self.navigationItem.title= [fileInfo getName];
    
    [self checkUploadButton];
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
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
    
    NSString * audioFilePath = [[[fileInfo.filePath stringByDeletingPathExtension] stringByAppendingString:@"_mixed"] stringByAppendingPathExtension:@"m4a"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:audioFilePath];
    if (fileExists) {
        NSLog(@"Audio File Exists");
        //emailPath = checkAudioPath;
        numberFinished = 3;
        [self finishedCompression];
    }
    else 
    {
        NSLog(@"create Audio");
        //NSString * audioFileName = [fileInfo.name stringByAppendingString:@".caf"];
        //NSString * cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        //NSString * audioFilePath = [cachesDirectory stringByAppendingPathComponent:audioFileName];
        
        
        HUD.labelText = @"Creating...";
        
    
        dispatch_queue_t q = dispatch_queue_create("queue", NULL);
        
        dispatch_async(q, ^{
            UBCAudioMixer * audioMixer = [[UBCAudioMixer alloc] init];
            [audioMixer makeAllFilesfrom:fileInfo.name]; 
            /*
            [UBCAudioMixer audioFilefromText:fileInfo.filePath toFile:audioFilePath];
            [UBCAudioMixer createMixedAudiofromTextAudio:audioFilePath andRecording:[[fileInfo.filePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"caf"]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                HUD.labelText =@"Compressing...";
                UBCAudioMixer * audioMixer = [[UBCAudioMixer alloc] init];
                [audioMixer convertForExport:fileInfo.name];
             
            });*/
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
    
    numberFinished++;
    if (numberFinished >= 2)
    {
        //NSString * localPath = fileInfo.filePath;
        //NSString * audioPath = [[fileInfo.filePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"m4a"];
        //NSArray * localPaths = [[NSArray alloc] initWithObjects:localPath,audioPath, nil];
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
        
        
        
        
        if ([fileInfo.uploadList count] > 0) {
            HUD.labelText = @"Uploading...";
            [dropbox uploadWithFiles:fileInfo.uploadList andDestinationFolder:destinationPath];
        }
        else {
            [HUD hide:YES];
            NSLog(@"Nothing to Upload");
        }
        [self checkUploadButton];
        
    }
    
    
}
- (IBAction) uploadPressed:(UIButton *)sender
{
    [fileInfo.uploadList removeAllObjects];
    //Upload to dropbox
    for( int i = 0; i<[uploadType count]; i++)
    {
        if([[uploadType objectAtIndex:i] objectForKey:@"selected"])
        {
            switch (i) {
                case 0:
                   //Text File
                    NSLog(@"Selected: %@",[[uploadType objectAtIndex:i] objectForKey:@"name"]);
                    [fileInfo.uploadList addObject:fileInfo.filePath];
                    break;
                case 1:
                    //Mic Audio
                    NSLog(@"Selected: %@",[[uploadType objectAtIndex:i] objectForKey:@"name"]);
                    [fileInfo.uploadList addObject:[[fileInfo.filePath stringByDeletingPathExtension] stringByAppendingString:@"_mic.m4a"]];
                    break;
                case 2:
                    //Mixed Audio
                    NSLog(@"Selected: %@",[[uploadType objectAtIndex:i] objectForKey:@"name"]);
                    [fileInfo.uploadList addObject:[[fileInfo.filePath stringByDeletingPathExtension] stringByAppendingString:@"_mixed.m4a"]];
                    break;
                    
                default:
                    break;
            }
        }
    }
    [self makeAudio];
}
- (IBAction) deletePressed:(UIButton *)sender
{
    
}

#pragma Table

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{   
    if(section == 0)
    {
        return [content count];
    }
    else if (section == 1)
    {
        return [uploadType count];
    }
    return 1;
    
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return @"Choose files to upload ...";
    }
    return @"";
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *CellIdentifierCheck = @"checkCell";
    
    UITableViewCell *cell;
    
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        NSDictionary * text = [content objectAtIndex:indexPath.row];
        cell.textLabel.text=[text objectForKey:@"textLabel"];
        cell.detailTextLabel.text = [text objectForKey:@"detailTextLabel"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    else if (indexPath.section == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierCheck];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifierCheck];
        }
        cell.textLabel.text = [[uploadType objectAtIndex:indexPath.row] objectForKey:@"name"];
        
    }
    
    
    
    //cell.textLabel.text = [fileList objectAtIndex:indexPath.row];
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
            [[uploadType objectAtIndex:indexPath.row] removeObjectForKey:@"selected"];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        else {
            [[uploadType objectAtIndex:indexPath.row] setObject:[NSNumber numberWithInt:1] forKey:@"selected"];
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        NSLog(@"Upload List: %@",uploadType);
        [self checkUploadButton];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) checkUploadButton
{
    int selected = 0;
    for(NSDictionary * cellDictionary in uploadType)
    {
        selected += [[cellDictionary objectForKey:@"selected"] intValue] ;
        
    }
    
    NSString * mixedAudioFilePath = [[[fileInfo.filePath stringByDeletingPathExtension] stringByAppendingString:@"_mixed"] stringByAppendingPathExtension:@"m4a"];
    NSString * micAudioFilePath = [[[fileInfo.filePath stringByDeletingPathExtension] stringByAppendingString:@"_mic"] stringByAppendingPathExtension:@"m4a"];
    BOOL mixedfileExists = [[NSFileManager defaultManager] fileExistsAtPath:mixedAudioFilePath];
    BOOL micfileExists = [[NSFileManager defaultManager] fileExistsAtPath:micAudioFilePath];
    
    if (mixedfileExists && micfileExists && selected == 0) {
        //FILES ALREADY EXIST // ONLY NEED TO UPLOAD
        [uploadButton setTitle:@"Upload to Dropbox" forState:UIControlStateNormal];
        uploadButton.titleLabel.textAlignment = UITextAlignmentCenter;
        uploadButton.enabled = NO;
    }
    else if (mixedfileExists && micfileExists && selected > 0) {
        [uploadButton setTitle:@"Upload to Dropbox" forState:UIControlStateNormal];
        uploadButton.titleLabel.textAlignment = UITextAlignmentCenter;
        if(![[DBSession sharedSession] isLinked])
        {
            uploadButton.enabled = NO;
        }
        else {
            uploadButton.enabled = YES;
        }
    
    }
    else if (selected > 0)
    {
        [uploadButton setTitle:@"Create Audio Files and Upload" forState:UIControlStateNormal];
        uploadButton.titleLabel.textAlignment = UITextAlignmentCenter;
        if(![[DBSession sharedSession] isLinked])
        {
            uploadButton.enabled = NO;
        }
        else {
            uploadButton.enabled = YES;
        }
    }
    else {
        [uploadButton setTitle:@"Create Audio Files" forState:UIControlStateNormal];
        uploadButton.enabled = YES;
    }
    
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
