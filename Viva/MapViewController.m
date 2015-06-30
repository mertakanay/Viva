//
//  ViewController.m
//  Viva
//
//  Created by Mert Akanay on 6/29/15.
//  Copyright (c) 2015 Viva. All rights reserved.
//

#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
@import GoogleMaps;

//search bar with animation

@interface MapViewController () <CLLocationManagerDelegate, GMSMapViewDelegate, UIGestureRecognizerDelegate>

@property CLLocationManager *locationManager;
@property GMSMapView *gMapView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.locationManager = [CLLocationManager new];
//    self.locationManager.delegate = self;
//    [self.locationManager requestWhenInUseAuthorization];

    self.gMapView.delegate = self;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude: 40.730610 longitude: -73.935242 zoom:10];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    CGFloat screenWidth = screenRect.size.width; //MAYBE I NEED TO CHANGE THIS FOR IPAD
//    CGFloat screenHeight = screenRect.size.height;
    self.gMapView = [GMSMapView mapWithFrame:screenRect camera:camera];
    self.gMapView.mapType = kGMSTypeHybrid;
    [self.view addSubview:self.gMapView];

    [self markTheCity];
    
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

-(void)markTheCity
{
    UILongPressGestureRecognizer *selectCityPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(markTheCity)];
    [self.view addGestureRecognizer:selectCityPress];
}

@end
