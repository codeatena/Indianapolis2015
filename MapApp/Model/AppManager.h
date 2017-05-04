//
//  AppManager.h
//  MapApp
//
//  Created by Mountain on 5/28/13.
//  Copyright (c) 2013 Qingxin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface AppManager : NSObject <CLLocationManagerDelegate>
@property (nonatomic, strong) NSMutableArray*           pushPins;
@property (nonatomic, strong) NSMutableArray*           imagePins;

@property (nonatomic, assign) CLLocationCoordinate2D    currentLocation;
@property (nonatomic, assign) CLLocationCoordinate2D    userLocation;
@property (nonatomic, strong) CLLocationManager*        locationManager;

+ (AppManager*) manager;

- (NSMutableArray*) pinsInRadius: (CLLocationCoordinate2D) originalLocation radius: (CLLocationDistance) distanceInMiles;
- (NSMutableArray*) pinsWithName: (NSString*) name address: (NSString*) address;

@end
