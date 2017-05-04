//
//  ImageViewController.m
//  MapApp
//
//  Created by Mountain on 5/29/13.
//  Copyright (c) 2013 Qingxin. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController
@synthesize currentImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithImage: (UIImage*) image
{
    self = [super initWithNibName: @"ImageViewController" bundle: nil];
    if (self) {
        self.currentImage = image;
    }
    return self;    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    imageView.image = self.currentImage;
}

- (IBAction) onClose:(id)sender
{
    [self dismissViewControllerAnimated: YES completion: nil];
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}
@end
