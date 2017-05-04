//
//  ViewController.m
//  MapApp
//
//  Created by Mountain on 5/28/13.
//  Copyright (c) 2013 Qingxin. All rights reserved.
//

#import "MainViewController.h"
#import "AppManager.h"
#import "Annotation.h"
#import "PushPin.h"
#import "ImagePin.h"
#import "ImageViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize popoverController;
@synthesize vwMap;

- (void)viewDidLoad
{
    [super viewDidLoad];
    currentRadius = 1.0f;
}

- (IBAction) onSearchOption: (id)sender
{
    if (self.popoverController && [self.popoverController isPopoverVisible]) {
        [self.popoverController dismissPopoverAnimated: YES];
        return;
    }

    if (self.popoverController == nil) {
        SearchOptionViewController* pController = [SearchOptionViewController new];
        pController.delegate = self;
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController: pController];
        self.popoverController.popoverContentSize = pController.view.bounds.size;
    }
    
    [self.popoverController presentPopoverFromBarButtonItem: sender permittedArrowDirections: UIPopoverArrowDirectionAny animated: YES];
}

- (IBAction) onReset:(id)sender
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: @"Alert" message: @"Are you sure you want to change the center point for your search?" delegate: self cancelButtonTitle: nil otherButtonTitles: @"Yes", @"No", nil];
    [alertView show];
}

- (IBAction) onRadiusSelected: (UISegmentedControl*)sender
{
    float radiusArray[4] = {1, 5, 10, 15};
    currentRadius = radiusArray[sender.selectedSegmentIndex];
    [NSThread detachNewThreadSelector: @selector(searchByCurrentRadius) toTarget: self withObject: nil];
}

- (IBAction) onImagePin:(id)sender
{
    AppManager* manager = [AppManager manager];
    [self resetWithPins: manager.imagePins];
}

- (void) resetCurrentLocation
{
    [AppManager manager].currentLocation = [vwMap centerCoordinate];
    NSLog(@"Search Base Position changed");
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self resetCurrentLocation];
    }
}

#pragma mark SearchOptionViewControllerDelegate
- (void) searchOptionDoneWithName:(NSString *)name address:(NSString *)address
{
    if (self.popoverController && [self.popoverController isPopoverVisible]) {
        [self.popoverController dismissPopoverAnimated: YES];
    }
    
    AppManager* manager = [AppManager manager];
    NSMutableArray* pins = [manager pinsWithName: name address: address];
    [self resetWithPins: pins];
}

- (void) searchOptionCancel
{
    if (self.popoverController && [self.popoverController isPopoverVisible]) {
        [self.popoverController dismissPopoverAnimated: YES];
    }
}

#pragma mark MKMapView Processing
- (void) searchByCurrentRadius
{
    @autoreleasepool {
        AppManager* manager = [AppManager manager];
        NSMutableArray* pins = [manager pinsInRadius: manager.currentLocation radius: currentRadius];
        [self performSelectorOnMainThread: @selector(resetWithPins:) withObject: pins waitUntilDone: YES];
    }
}

- (void) resetWithPins: (NSMutableArray*) pins
{
    [self.vwMap removeAnnotations: self.vwMap.annotations];
    
    float count = (float)[pins count];
    if (count == 0) {
        return;
    }

    self.vwProgress.hidden = NO;
    self.vwProgress.progress = 0.0f;
    [vwMap addAnnotations: pins];
    self.vwProgress.progress = 1.0f;
    self.vwProgress.hidden = YES;
    [self fitToPinsRegion];
}

- (void) fitToPinsRegion
{
	if ([vwMap.annotations count] == 0)
		return;
	
    NSMutableArray* annotations = [NSMutableArray arrayWithArray: vwMap.annotations];
	for(Annotation *annotation in annotations)
    {
        if ([annotation isKindOfClass: [MKUserLocation class]]) {
            [annotations removeObject: annotation];
            break;
        }
    }
    
	Annotation *firstMark = [annotations objectAtIndex: 0];
	CLLocationCoordinate2D topLeftCoord = firstMark.coordinate;
	CLLocationCoordinate2D bottomRightCoord = firstMark.coordinate;
	
	for(Annotation *annotation in annotations)
    {
		if (annotation.coordinate.latitude < topLeftCoord.latitude)
			topLeftCoord.latitude = annotation.coordinate.latitude;
        
		if (annotation.coordinate.longitude > topLeftCoord.longitude)
			topLeftCoord.longitude = annotation.coordinate.longitude;
		
		if (annotation.coordinate.latitude > bottomRightCoord.latitude)
			bottomRightCoord.latitude = annotation.coordinate.latitude;
		
		if (annotation.coordinate.longitude < bottomRightCoord.longitude)
			bottomRightCoord.longitude = annotation.coordinate.longitude;
	}
	
	MKCoordinateRegion region;
	region.center.latitude = (topLeftCoord.latitude + bottomRightCoord.latitude)/2.0;
	region.center.longitude = (topLeftCoord.longitude + bottomRightCoord.longitude)/2.0;
	region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
	region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
	
	if (region.span.latitudeDelta < 0.01)
	{
		region.span.latitudeDelta = 0.01;
	}
	if (region.span.longitudeDelta < 0.01)
	{
		region.span.longitudeDelta = 0.01;
	}
    
	region = [vwMap regionThatFits:region];
	[vwMap setRegion:region animated:YES];
}

- (void)mapView:(MKMapView *)delegateMapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    AppManager* manager = [AppManager manager];
    manager.userLocation = userLocation.location.coordinate;
}

- (MKAnnotationView *) mapView:(MKMapView *)aMapView viewForAnnotation:(Annotation*) annotation
{
    static NSString *PinIdentifier = @"PinIdentifier";
    if ([annotation isKindOfClass: [MKUserLocation class]]) {
        return nil;
    }
    
    QXPinAnnotationView *annView = (QXPinAnnotationView *) [vwMap dequeueReusableAnnotationViewWithIdentifier:PinIdentifier];
	if (annView == nil)
	{
		annView = [[QXPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:PinIdentifier];
		annView.animatesDrop = NO;
		annView.canShowCallout = YES;
		annView.enabled = YES;
        annView.calloutOffset = CGPointMake(-5, 5);
        [annView addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:@"selectedmapannotation"];
    }
    
    annView.annotation = annotation;
    annView.leftCalloutAccessoryView = nil;
    annView.pinColor = MKPinAnnotationColorRed;
    
    if ([annotation isKindOfClass: [ImagePin class]]) {
        annView.pinColor = MKPinAnnotationColorPurple;
        ImagePin* pin = (ImagePin*) annotation;
        UIImage* image = pin.image;
        CGFloat height = 32;
        CGFloat width = image.size.width / image.size.height * height;
        
        UIButton* button = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, width, height)];
        [button setBackgroundImage: image forState: UIControlStateNormal];
        [button addTarget: self action: @selector(onImageShow:) forControlEvents: UIControlEventTouchUpInside];
        annView.leftCalloutAccessoryView = button;
    }
    
    CGSize nameSize = [annotation.name sizeWithFont: [UIFont boldSystemFontOfSize: 13]];
    CGSize addressSize = [annotation.address sizeWithFont: [UIFont systemFontOfSize: 11]];
    UIButton* rightView = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, MAX(nameSize.width, addressSize.width), 32)];
    
    UILabel* lblName = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, nameSize.width, 16)];
    lblName.textAlignment = NSTextAlignmentLeft;
    lblName.backgroundColor = [UIColor clearColor];
    lblName.textColor = [UIColor blackColor];
    lblName.font = [UIFont boldSystemFontOfSize: 13];
    lblName.text = annotation.name;
    [rightView addSubview: lblName];
    
    UILabel* lblAddress = [[UILabel alloc] initWithFrame: CGRectMake(0, 16, addressSize.width, 16)];
    lblAddress.textAlignment = NSTextAlignmentLeft;
    lblAddress.backgroundColor = [UIColor clearColor];
    lblAddress.textColor = [UIColor blackColor];
    lblAddress.font = [UIFont systemFontOfSize: 11];
    lblAddress.text = annotation.address;
    [rightView addSubview: lblAddress];

    annView.rightCalloutAccessoryView = rightView;
	return annView;
}

- (void) onImageShow: (UIButton*) sender
{
    UIImage* image = [sender backgroundImageForState: UIControlStateNormal];
    ImageViewController* pController = [[ImageViewController alloc] initWithImage: image];
    [self presentViewController: pController animated: YES completion: nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSString *action = (__bridge NSString*)context;
    
    if([action isEqualToString: @"selectedmapannotation"]){
        BOOL annotationAppeared = [[change valueForKey:@"new"] boolValue];
        MKAnnotationView *ann = (MKAnnotationView *)object;
        [ann.superview bringSubviewToFront: ann];
        if (annotationAppeared) {
            // do something with the annotation when it is selected
        }
        else {
            // do something with the annotation when it is de-selected
        }
    }
}
@end


