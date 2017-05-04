//
//  AppManager.m
//  MapApp
//
//  Created by Mountain on 5/28/13.
//  Copyright (c) 2013 Qingxin. All rights reserved.
//

#import "AppManager.h"
#import "PushPin.h"
#import "ImagePin.h"

@implementation AppManager
static AppManager* sharedInstance = nil;

@synthesize pushPins;
@synthesize imagePins;
@synthesize locationManager;
@synthesize currentLocation;
@synthesize userLocation;

+ (AppManager*) manager
{
    if (!sharedInstance) {
        sharedInstance = [AppManager new];
    }
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self loadPushPin];
        [self loadImagePin];
        [self initCoreLocation];
    }
    return self;
}

- (void) loadPushPin
{
    self.pushPins = [NSMutableArray array];
    NSString * filename= [[NSBundle mainBundle] pathForResource:@"geocoded" ofType:@"csv"];
	NSError *error = nil;
    NSString *data = [NSString stringWithContentsOfFile: filename encoding: NSUTF8StringEncoding error: &error];
	
	if ( error )
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"The file can not be loaded" delegate: nil cancelButtonTitle: @"Dismiss" otherButtonTitles: nil];
		[alert show];
	}
	else
	{
		NSString *strippedPartOne = [data stringByReplacingOccurrencesOfString:@"\"" withString:@""];
		NSArray *rows = [strippedPartOne componentsSeparatedByString:@"\r"];
        
		NSUInteger size = [rows count];
        for (int i =0; i < size; i++) {
            if(i==0)
                continue;
            NSArray * line = [[rows objectAtIndex:i] componentsSeparatedByString:@","];
            
            if([line count] <6)
                break;
            
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            f.numberStyle = NSNumberFormatterDecimalStyle;
            NSNumber *latNumber = [f numberFromString:[[line objectAtIndex:6] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            NSNumber *lonNumber = [f numberFromString:[[line objectAtIndex:7] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            
            if (latNumber == nil || lonNumber == nil) continue;
                            
            //double lat =[[[line objectAtIndex:5] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] doubleValue];
            //double lon =[[[line objectAtIndex:6] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] doubleValue];
            
            double lat = [latNumber doubleValue];
            double lon = [lonNumber doubleValue];
            
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = lat;
            coordinate.longitude = lon;
            
            PushPin* pin = [PushPin new];
            pin.coordinate = coordinate;
            pin.name  = [line objectAtIndex: 4];
            pin.address = [line objectAtIndex: 0];
            [self.pushPins addObject: pin];
        }
	}
}

- (void) loadImagePin
{
    self.imagePins = [NSMutableArray array];
    NSString * filenamePics = [[NSBundle mainBundle] pathForResource: @"pic-locations" ofType: @"csv"];
	NSError *errorPics = nil;
    NSString *dataPics = [NSString stringWithContentsOfFile: filenamePics encoding: NSUTF8StringEncoding error: &errorPics];
	
	if ( errorPics )
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: @"The file can not be loaded" delegate: nil cancelButtonTitle: @"Dismiss" otherButtonTitles: nil];
		[alert show];
	}
	else
	{
		NSString *strippedPics = [dataPics stringByReplacingOccurrencesOfString: @"\"" withString: @""];
		NSArray *rowsPics = [strippedPics componentsSeparatedByString: @"\n"];
		
		NSUInteger sizePics = [rowsPics count];
		for (int i = 0; i < sizePics; i++)
		{
			NSArray * linePics = [[rowsPics objectAtIndex: i] componentsSeparatedByString: @","];
			double lat = [[[linePics objectAtIndex: 0] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] doubleValue];
			double lon = [[[linePics objectAtIndex: 1] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] doubleValue];
			
			CLLocationCoordinate2D coordinate;
			coordinate.latitude = lat;
			coordinate.longitude = lon;

			ImagePin* pin = [ImagePin new];
            pin.coordinate = coordinate;
            pin.name = [linePics objectAtIndex: 3];
            pin.address = [linePics objectAtIndex: 6];
            pin.image = [UIImage imageNamed: [[linePics objectAtIndex: 2] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]];
            [self.imagePins addObject: pin];
		}
	}
}

- (void) initCoreLocation
{
    self.locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    locationManager.pausesLocationUpdatesAutomatically = NO;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    if ([CLLocationManager locationServicesEnabled]) {
        [locationManager startUpdatingLocation];
        
    } else {
        NSLog(@"Location services is not enabled");
    }
}

#pragma mark LocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* location = [locations lastObject];
    self.userLocation = location.coordinate;
    if (self.currentLocation.latitude == 0 && self.currentLocation.longitude == 0) {
        self.currentLocation = self.userLocation;
    }
}

#define MILE_IN_METERS          1603.34f
- (NSMutableArray*) pinsInRadius: (CLLocationCoordinate2D) originalLocation radius: (CLLocationDistance) distanceInMiles
{
    CLLocationDistance distance = distanceInMiles * MILE_IN_METERS;
    NSMutableArray* pins = [NSMutableArray new];
    
    CLLocation* original = [[CLLocation alloc] initWithLatitude: originalLocation.latitude longitude: originalLocation.longitude];
    
    for (PushPin* pin in self.pushPins) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude: pin.coordinate.latitude longitude: pin.coordinate.longitude];
        CLLocationDistance curDistance = [location distanceFromLocation: original];
        if (curDistance < distance) {
            [pins addObject: pin];
        }
    }
    
    for (ImagePin* pin in self.imagePins) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude: pin.coordinate.latitude longitude: pin.coordinate.longitude];
        CLLocationDistance curDistance = [location distanceFromLocation: original];
        if (curDistance < distance) {
            [pins addObject: pin];
        }
    }
    return pins;
}

- (NSMutableArray*) pinsWithName: (NSString*) name address: (NSString*) address
{
    NSMutableArray* pins = [NSMutableArray new];
    BOOL bOkay = NO;
    for (PushPin* pin in self.pushPins) {
        bOkay = YES;
        if (name.length != 0) {
            if ([[pin.name lowercaseString] rangeOfString: [name lowercaseString]].length == 0)
            {
                bOkay = NO;
            }
        }
        
        if (address.length != 0) {
            if ([[pin.address lowercaseString] rangeOfString: [address lowercaseString]].length == 0)
            {
                bOkay = NO;
            }
        }
        
        if (bOkay) {
            [pins addObject: pin];
        }
    }
    
    return pins;
}
@end
