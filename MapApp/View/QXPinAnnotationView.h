//
//  QXPinAnnotationView.h
//  MapApp
//
//  Created by Mountain on 5/29/13.
//  Copyright (c) 2013 Qingxin. All rights reserved.
//

#import <MapKit/MapKit.h>

@class Annotation;
@interface QXPinAnnotationView : MKPinAnnotationView
@property (nonatomic, strong) Annotation*   annotation;
@end
