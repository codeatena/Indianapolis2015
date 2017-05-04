//
//  ViewController.h
//  MapApp
//
//  Created by Mountain on 5/28/13.
//  Copyright (c) 2013 Qingxin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchOptionViewController.h"
#import "QXPinAnnotationView.h"

@interface MainViewController : UIViewController <SearchOptionViewControllerDelegate>
{
    CGFloat     currentRadius;
}
@property (nonatomic, strong) IBOutlet MKMapView*           vwMap;
@property (nonatomic, strong) IBOutlet UIProgressView*      vwProgress;
@property (nonatomic, strong) UIPopoverController*  popoverController;
@end
