//
//  SearchOptionViewController.h
//  MapApp
//
//  Created by Mountain on 5/28/13.
//  Copyright (c) 2013 Qingxin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchOptionViewControllerDelegate <NSObject>
- (void) searchOptionDoneWithName: (NSString*) name address: (NSString*) address;
- (void) searchOptionCancel;
@end

@interface SearchOptionViewController : UIViewController
{
    IBOutlet UITextField*   txtName;
    IBOutlet UITextField*   txtAddress;
}
@property (nonatomic, strong) id<SearchOptionViewControllerDelegate> delegate;
@end
