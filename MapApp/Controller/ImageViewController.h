//
//  ImageViewController.h
//  MapApp
//
//  Created by Mountain on 5/29/13.
//  Copyright (c) 2013 Qingxin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController
{
    IBOutlet UIImageView*   imageView;
    IBOutlet UIScrollView*  scrollView;
}

@property (nonatomic, strong) UIImage* currentImage;

- (id) initWithImage: (UIImage*) image;
@end
