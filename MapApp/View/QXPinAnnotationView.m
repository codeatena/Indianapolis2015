//
//  QXPinAnnotationView.m
//  MapApp
//
//  Created by Mountain on 5/29/13.
//  Copyright (c) 2013 Qingxin. All rights reserved.
//

#import "QXPinAnnotationView.h"

@implementation QXPinAnnotationView
@synthesize annotation;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.superview bringSubviewToFront:self];
    [super touchesBegan:touches withEvent:event];
}
@end
