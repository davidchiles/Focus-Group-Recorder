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
@synthesize dropboxButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 311.0);
    }
    return self;
}
							
- (void)viewDidLoad
{
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
    
    [dropboxButton.titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    if([[DBSession sharedSession] isLinked])
        [dropboxButton setTitle:@"Unlink Dropbox" forState:UIControlStateNormal]; 
    else {
        [dropboxButton setTitle:@" Link Dropbox " forState:UIControlStateNormal];
    } 
   
    
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

@end
