//
//  ViewController.m
//  Viva
//
//  Created by Mert Akanay on 6/29/15.
//  Copyright (c) 2015 Viva. All rights reserved.
//

#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
@import GoogleMaps;

//search bar with animation

@interface MapViewController () <CLLocationManagerDelegate, GMSMapViewDelegate, UIGestureRecognizerDelegate>

@property CLLocationManager *locationManager;
@property GMSMapView *gMapView;
@property GMSPlacePicker *placePicker;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];

    self.gMapView.delegate = self;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude: 40.730610 longitude: -73.935242 zoom:10];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    CGFloat screenWidth = screenRect.size.width; //MAYBE I NEED TO CHANGE THIS FOR IPAD
//    CGFloat screenHeight = screenRect.size.height;
    self.gMapView = [GMSMapView mapWithFrame:screenRect camera:camera];
    self.gMapView.mapType = kGMSTypeHybrid;

    self.gMapView.settings.consumesGesturesInView = NO;

    [self.view addSubview:self.gMapView];

    UILongPressGestureRecognizer *selectCityPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressGesture:)];
    selectCityPress.delegate = self;
    [self.view addGestureRecognizer:selectCityPress];



}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"Memory warning!");
}

-(void)createPolygonOnCity
{
    GMSMutablePath *rect = [GMSMutablePath path];
    [rect addCoordinate:CLLocationCoordinate2DMake(37.36, -122.0)];
    [rect addCoordinate:CLLocationCoordinate2DMake(37.45, -122.0)];
    [rect addCoordinate:CLLocationCoordinate2DMake(37.45, -122.2)];
    [rect addCoordinate:CLLocationCoordinate2DMake(37.36, -122.2)];

    // Create the polygon, and assign it to the map.
    GMSPolygon *polygon = [GMSPolygon polygonWithPath:rect];
    polygon.fillColor = [UIColor colorWithRed:0.25 green:0 blue:0 alpha:0.05];
    polygon.strokeColor = [UIColor blackColor];
    polygon.strokeWidth = 2;
    polygon.map = self.gMapView;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)markTheCity
{
    
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gesture
{

    CGPoint pointInView = [gesture locationInView:self.gMapView];
    CLLocationCoordinate2D coord = [self.gMapView.projection coordinateForPoint:pointInView];

    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake(coord.latitude, coord.longitude) completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
        NSLog(@"reverse geocoding results:");
        for(GMSAddress* addressObj in [response results])
        {

            NSLog(@"administrativeArea=%@", addressObj.administrativeArea);

        }
    }];
}

- (IBAction)pickPlace:(UIBarButtonItem *)sender {

    GMSVisibleRegion visibleRegion = self.gMapView.projection.visibleRegion;
    GMSCoordinateBounds *viewport = [[GMSCoordinateBounds alloc] initWithCoordinate:visibleRegion.farLeft
                                                                         coordinate:visibleRegion.nearRight];
    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:viewport];
    self.placePicker = [[GMSPlacePicker alloc] initWithConfig:config];

    [self.placePicker pickPlaceWithCallback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            return;
        }

        if (place != nil) {

            NSLog(@"Place selected: %@", place.name);

            GMSMarker *marker = [GMSMarker markerWithPosition:place.coordinate];
            marker.title = place.name;
            marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
            marker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
            marker.snippet = place.formattedAddress;
            marker.map = self.gMapView;

        } else {
            NSLog(@"No place selected");
        }
        
    }];
}

//-(UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
//{
//    
//}


@end
