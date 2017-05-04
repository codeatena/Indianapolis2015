//
//  SearchOptionViewController.m
//  MapApp
//
//  Created by Mountain on 5/28/13.
//  Copyright (c) 2013 Qingxin. All rights reserved.
//

#import "SearchOptionViewController.h"

@interface SearchOptionViewController ()

@end

@implementation SearchOptionViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction) onDone:(id)sender
{
    if ( self.delegate && [self.delegate respondsToSelector: @selector(searchOptionDoneWithName:address:)]) {
        [self.delegate searchOptionDoneWithName: txtName.text address: txtAddress.text];
    }
}

- (IBAction) onCancel:(id)sender
{
    if ( self.delegate && [self.delegate respondsToSelector: @selector(searchOptionCancel)]) {
        [self.delegate searchOptionCancel];
    }    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
