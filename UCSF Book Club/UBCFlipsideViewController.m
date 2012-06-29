//
//  UBCFlipsideViewController.m
//  UCSF Book Club
//
//  Created by David Chiles on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UBCFlipsideViewController.h"


@interface UBCFlipsideViewController ()

@end

@implementation UBCFlipsideViewController

@synthesize delegate = _delegate;
@synthesize numberPicker;
@synthesize contentList;
@synthesize numberOfPeople;
@synthesize dropboxButton,pathText,settingsTable,actionSheet;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 300.0);
    }
    return self;
}
							
- (void)viewDidLoad
{
    
    dropboxButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //[dropboxButton setTitle:@"Delete" forState:UIControlStateNormal];
    /*[self.dropboxButton setBackgroundImage:[[UIImage imageNamed:@"iphone_delete_button.png"]
                                           stretchableImageWithLeftCapWidth:8.0f
                                           topCapHeight:0.0f]
                                 forState:UIControlStateNormal]; */
    
    [self.dropboxButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.dropboxButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    //self.dropboxButton.titleLabel.shadowColor = [UIColor lightGrayColor];
    //self.dropboxButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    [self.dropboxButton addTarget:self action:@selector(dropboxPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxLinked) name:@"DropboxLinked" object:nil];
    [super viewDidLoad];
    NSMutableArray * nums = [[NSMutableArray alloc] init];
    for(int i = 2; i<=20; i++)
    {
        [nums addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    //contentList = [nums copy];
    contentList = [[NSArray alloc] initWithArray:nums];
    if(numberOfPeople >0)
        [numberPicker selectRow:numberOfPeople-1 inComponent:0 animated:NO];
    else
        [numberPicker selectRow:0 inComponent:0 animated:NO];
    
    
    if([[DBSession sharedSession] isLinked])
        [dropboxButton setTitle:@"Unlink Dropbox" forState:UIControlStateNormal]; 
    else {
        [dropboxButton setTitle:@" Link Dropbox " forState:UIControlStateNormal];
    } 
    //[dropboxButton.titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    pathText = [[UITextField alloc] init];
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"dropbox_path"]) //Path already stored
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"/Recordings/" forKey:@"dropbox_path"];
    }
    
    pathText.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"dropbox_path"];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
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

-(void) dropboxLinked
{
    [dropboxButton setTitle:@"Unlink Dropbox" forState:UIControlStateNormal];
}


#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:pathText.text forKey:@"dropbox_path"];
    [self.delegate flipsideViewControllerDidFinish:self];
}
-(IBAction)dropboxPressed:(id)sender
{
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] link];
        
    }
    else
    {
        [[DBSession sharedSession] unlinkAll];
        [dropboxButton setTitle:@"Link Dropbox" forState:UIControlStateNormal];
    }
}

#pragma mark - Picker

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return contentList.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [contentList objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    numberOfPeople = row+2;
}

#pragma - Table
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else {
        return 1;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"Number of Participants";
    }
    else if(section == 1)
    {
        return @"Dropbox Folder";
    }
    return @"";
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section == 1)
    {
        return @"No Spaces Allowed";
    }
    return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CellIdentifier1 = @"Cell1";
    static NSString *CellIdentifier2 = @"Cell2";
    static NSString *CellIdentifier3 = @"Cell3";
    if(indexPath.section == 0) //Picker Launch
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier1];
        }
            
        cell.textLabel.text=@"Participants";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",numberOfPeople] ;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
        
    }
    else if (indexPath.section == 1) 
    {
        if (indexPath.row == 0) { // Path Edit 
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            pathText.frame = CGRectMake(7, 10, 290, 34);
            pathText.backgroundColor = [UIColor clearColor];
            pathText.font = [UIFont boldSystemFontOfSize:17.0];
            pathText.textColor = [UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0];
            
            [cell.contentView addSubview:pathText];
            
            return cell;
        }
    }
    else //Link unlink Button
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier3];
        }
        
        dropboxButton.frame = cell.contentView.bounds;
        NSLog(@"bounds: %f",cell.contentView.bounds.size.width);
        NSLog(@"button: %f",dropboxButton.frame.size.width);
        dropboxButton.frame = CGRectMake(dropboxButton.frame.origin.x, dropboxButton.frame.origin.y, 300.0f, dropboxButton.frame.size.height);
        
        [cell.contentView addSubview:dropboxButton];
            
        return cell;
                
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Participants" 
                                                                 delegate:nil
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        
        CGRect pickerFrame = CGRectMake(0, 40, 320, 216);
        
        numberPicker = [[UIPickerView alloc] initWithFrame:pickerFrame];
        numberPicker.showsSelectionIndicator = YES;
        numberPicker.dataSource = self;
        numberPicker.delegate = self;
        
        if(numberOfPeople >0)
            [numberPicker selectRow:numberOfPeople-2 inComponent:0 animated:NO];
        else
            [numberPicker selectRow:0 inComponent:0 animated:NO];
        [actionSheet addSubview:numberPicker];
        //[actionSheet addSubview:closeButton];
        
        UIToolbar * pickerDateToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        pickerDateToolbar.barStyle = UIBarStyleBlackOpaque;
        [pickerDateToolbar sizeToFit];
        
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissActoinSheet)];
        [barItems addObject:doneBtn];
        [pickerDateToolbar setItems:barItems animated:NO];
        
        //[actionSheet setBounds:CGRectMake(0, 0, 320, 216)];
        [actionSheet addSubview:pickerDateToolbar];
        //[actionSheet addSubview:dtpicker];
        [actionSheet showInView:self.view];
        
        [actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma - ActionSheet

-(void) dismissActoinSheet
{
    NSLog(@"dismiss with: %d",numberOfPeople);
    [settingsTable reloadData];
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    [settingsTable reloadData];
    
}



@end
