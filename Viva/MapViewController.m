//
//  ViewController.m
//  Viva
//
//  Created by Mert Akanay on 6/29/15.
//  Copyright (c) 2015 Viva. All rights reserved.
//

#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "CustomInfoWindow.h"
#import "User.h"
#import "Place.h"
#import <GoogleMaps/GoogleMaps.h>
#import "PlaceDetailViewController.h"
#import "FriendsViewController.h"
#import "BucketListViewController.h"
#import "CameraViewController.h"

//FIX SEGMENTEDCONTROL
//FIX CITYMARKER

@interface MapViewController () <CLLocationManagerDelegate, GMSMapViewDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate, UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *detailButton;
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTV;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property CLLocationManager *locationManager;
@property GMSMapView *mapView;
@property GMSPlacePicker *placePicker;
@property NSString *selectedPlaceName;
@property GMSMarker *placeMarker;
@property GMSMarker *cityMarker;
@property NSMutableArray *usersLovedPlaces;
@property NSMutableArray *usersDesiredPlaces;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property User *currentUser;
@property UIImage *cityMarkerImage;
@property float selectedPlaceRating;
@property Place *tappedPlace;
@property NSMutableArray *searchArray;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentUser = [User currentUser];

    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];

    self.collectionView.hidden = YES;
    [self getDataFromParse];

    self.detailButton.clipsToBounds = true;
    self.detailButton.layer.cornerRadius = 50/2.0;
    self.detailButton.backgroundColor = [UIColor orangeColor];
    self.detailButton.enabled = NO;

    UITabBarController *tabBar = [self tabBarController];
    UITabBarItem *tabBarItem = [[tabBar.tabBar items] objectAtIndex:2];
    [tabBarItem setEnabled:FALSE];

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude: self.locationManager.location.coordinate.latitude longitude: self.locationManager.location.coordinate.longitude zoom:10];
    CGRect screenRect = [[UIScreen mainScreen] bounds];

    self.mapView = [GMSMapView mapWithFrame:screenRect camera:camera];
    self.mapView.mapType = kGMSTypeNormal;

    self.mapView.settings.consumesGesturesInView = NO;
    self.mapView.delegate = self;

//    [self.view addSubview:self.mapView];
//    [self.view sendSubviewToBack:self.mapView];

    [self.view addSubview:self.mapView];

    self.mapView.delegate = self;

    self.searchResultsTV.hidden = YES;

    [self.view sendSubviewToBack:self.mapView];

    UITapGestureRecognizer *tapToDisableKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapToDisableKeyboard];

    UILongPressGestureRecognizer *selectCityPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressGesture:)];
    selectCityPress.delegate = self;
    selectCityPress.minimumPressDuration = 0.5;
    [self.view addGestureRecognizer:selectCityPress];
}

-(void)dismissKeyboard {
    [self.searchBar resignFirstResponder];
    self.searchBar.text = @"";
    self.searchResultsTV.hidden = YES;

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void)createAlertViewForCityWithCoordinate:(CLLocationCoordinate2D)coordinate andCityName:(NSString *)cityName;
{
    UIAlertController *alertControllerForCity  = [UIAlertController alertControllerWithTitle:@"Please select if you have already been or desire to go to the city" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Been" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        GMSMarker *cityMarker = [[GMSMarker alloc]init];
        cityMarker.position = coordinate;
        cityMarker.title = cityName;
        cityMarker.map = self.mapView;

        CGSize newSize = CGSizeMake(35, 35);
        UIGraphicsBeginImageContext(newSize);
        UIImage *cityMarkerImage = [UIImage imageNamed:@"checkedCircle"];
        [cityMarkerImage drawInRect:CGRectMake(0,0,35,35)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cityMarker.icon = newImage;


    }];
    UIAlertAction *actionTwo = [UIAlertAction actionWithTitle:@"To Go" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        GMSMarker *cityMarker = [[GMSMarker alloc]init];
        cityMarker.position = coordinate;
        cityMarker.title = cityName;
        cityMarker.map = self.mapView;

        CGSize newSize = CGSizeMake(35, 35);
        UIGraphicsBeginImageContext(newSize);
        UIImage *cityMarkerImage = [UIImage imageNamed:@"uncheckedCircle"];
        [cityMarkerImage drawInRect:CGRectMake(0,0,35,35)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cityMarker.icon = newImage;

    }];
    [alertControllerForCity addAction:action];
    [alertControllerForCity addAction:actionTwo];
    [self presentViewController:alertControllerForCity animated:YES completion:nil];
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gesture
{
    if (UIGestureRecognizerStateEnded == gesture.state) {

        CGPoint pointInView = [gesture locationInView:self.mapView];
        CLLocationCoordinate2D coord = [self.mapView.projection coordinateForPoint:pointInView];


        [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake(coord.latitude, coord.longitude) completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
            NSLog(@"reverse geocoding results:");
            for(GMSAddress* addressObj in [response results])
            {

                NSString *chosenCity = addressObj.locality;
                NSString *cityNameString = [chosenCity stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true",cityNameString];
                NSURL *url = [NSURL URLWithString:urlString];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];

                NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

                [[session dataTaskWithRequest:request
                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                
                                NSDictionary *cityDataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                NSArray *cityInfoArray = [cityDataDict objectForKey:@"results"];
                                NSDictionary *cityGeometryDict = [cityInfoArray[0] objectForKey:@"geometry"];
                                NSDictionary *cityLocationDict = [cityGeometryDict objectForKey:@"location"];
                                NSString *cityLatitude = [cityLocationDict objectForKey:@"lat"];
                                NSString *cityLongitude = [cityLocationDict objectForKey:@"lng"];
                                CLLocationCoordinate2D position = CLLocationCoordinate2DMake([cityLatitude floatValue], [cityLongitude floatValue]);

                                [self createAlertViewForCityWithCoordinate:position andCityName:chosenCity];

                            }] resume];

            }
        }];

    }
}

-(void)getDataFromParse
{

    //fix it so it can get the both data at the same time without two queries

    self.usersLovedPlaces = [NSMutableArray new];
    self.usersDesiredPlaces = [NSMutableArray new];
    [self queryRelationsWithString:@"placeLoved" andStoreInArray:self.usersLovedPlaces];
    [self queryRelationsWithString:@"placeToGo" andStoreInArray:self.usersDesiredPlaces];
}

-(void)queryRelationsWithString:(NSString *)string andStoreInArray:(NSMutableArray *)storedArray
{
    PFRelation *placesToGoRelation = [self.currentUser relationForKey:string];
    PFQuery *placesToGoQuery = [placesToGoRelation query];
    [placesToGoQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %lu objects.", (unsigned long)array.count);
            [storedArray arrayByAddingObjectsFromArray:array];
            for (int i = 0; i<array.count; i++) {
                Place *place = [array objectAtIndex:i];
                PFGeoPoint *geoPoint = place[@"coordinate"];
                CLLocationCoordinate2D cityMarkerPosition = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
                self.placeMarker = [GMSMarker markerWithPosition:cityMarkerPosition];
                self.placeMarker.title = place[@"name"];
                if ([place[@"alreadyBeen"]  isEqual:@YES]) {
                    self.placeMarker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
                }else{
                    self.placeMarker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
                }
                self.placeMarker.map = self.mapView;
            }
        }else{
            NSLog(@"Places to go error: %@",[error localizedDescription]);
        }
    }];
}

- (IBAction)segmentSwitch:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;

    if (selectedSegment == 0 || selectedSegment == 1) {
        self.placeMarker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
    }
    else if (selectedSegment == 0 || selectedSegment == 2){
        self.placeMarker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
    }
}

- (IBAction)pickPlace:(UIBarButtonItem *)sender
{
    UIAlertController *alertControllerForCity  = [UIAlertController alertControllerWithTitle:@"Please select the most appropriate definition of the place" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Already Been" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        PFRelation *relation = [self.currentUser relationForKey:@"placeLoved"];
        [self selectPlaceWithRelation:relation andUser:self.currentUser andColor:[UIColor blueColor]];

    }];
    UIAlertAction *actionTwo = [UIAlertAction actionWithTitle:@"Want To Go" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        PFRelation *relation = [self.currentUser relationForKey:@"placeToGo"];
        [self selectPlaceWithRelation:relation andUser:self.currentUser andColor:[UIColor redColor]];

    }];
    [alertControllerForCity addAction:action];
    [alertControllerForCity addAction:actionTwo];
    [self presentViewController:alertControllerForCity animated:YES completion:nil];

}

-(void)selectPlaceWithRelation:(PFRelation *)relation andUser:(User *)currentUser andColor:(UIColor *)color
{
    GMSVisibleRegion visibleRegion = self.mapView.projection.visibleRegion;
    GMSCoordinateBounds *viewport = [[GMSCoordinateBounds alloc] initWithCoordinate:visibleRegion.farLeft
                                                                         coordinate:visibleRegion.nearRight];
    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:viewport];
    self.placePicker = [[GMSPlacePicker alloc] initWithConfig:config];


    Place *selectedPlace = [Place objectWithClassName:@"Place"];

    [self.placePicker pickPlaceWithCallback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            return;
        }

        if (place != nil) {

            NSLog(@"Place selected: %@", place.name);

            self.placeMarker = [[GMSMarker alloc] init];
            self.selectedPlaceRating = place.rating;
            self.placeMarker.title = place.name;
//            selectedPlace.googleRating = place.rating;
            self.placeMarker.position = place.coordinate;
            self.placeMarker.icon = [GMSMarker markerImageWithColor:color];
            self.placeMarker.infoWindowAnchor = CGPointMake(0.44f, -0.20f);

            selectedPlace[@"name"] = place.name;
            PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude];
            selectedPlace[@"coordinate"] = geoPoint;
            selectedPlace[@"ID"] = place.placeID;
            if (color == [UIColor blueColor]) {
                selectedPlace[@"alreadyBeen"] = @YES;
                [self.usersDesiredPlaces addObject:selectedPlace];
            }else
            {
                selectedPlace[@"alreadyBeen"] = @NO;
            }
            [selectedPlace save];
            [relation addObject:selectedPlace];
            [currentUser saveInBackground];

            self.placeMarker.map = self.mapView;


        } else {
            NSLog(@"No place selected");
        }
    }];

}

-(UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
{
    CustomInfoWindow *infoWindow = [[[NSBundle mainBundle]loadNibNamed:@"InfoWindow" owner:self options:nil]objectAtIndex:0];
    [infoWindow setFrame:CGRectMake(0, 0, infoWindow.frame.size.width, infoWindow.frame.size.height)];
    infoWindow.userInteractionEnabled = YES;

    infoWindow.placeNameLabel.text = self.selectedPlaceName;

    return infoWindow;
}

//does not call this method because marker is defined in markerInfoWindow method above.

//- (IBAction)onDetailsButtonTapped:(UIButton *)sender {
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    PlaceDetailViewController *placeDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"placeDetailVC"];
//    UINavigationController *placeDetailNavVC = [[UINavigationController alloc]initWithRootViewController:placeDetailVC];
//    [self presentViewController:placeDetailNavVC animated:YES completion:nil];
//}

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{

    //FIX IT SO IT WILL GET PLACE ID INSTEAD OF PLACE NAME
    
    self.tappedPlace = [Place objectWithClassName:@"Place"];
    self.tappedPlace[@"name"] = marker.title;
    self.selectedPlaceName = marker.title;
    self.detailButton.enabled = YES;

    [self passDataToOtherTabBarVCs];

    UITabBarController *tabBar = [self tabBarController];
    UITabBarItem *tabBarItem = [[tabBar.tabBar items] objectAtIndex:2];
    [tabBarItem setEnabled:true];

    if ([marker isEqual:self.cityMarker]) {
        if (self.collectionView.hidden == YES) {
            self.collectionView.hidden = NO;
        }else{
            self.collectionView.hidden = YES;
        }
        return YES;
    }else
    {
        return NO;
    }

}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    GMSVisibleRegion visibleRegion = self.mapView.projection.visibleRegion;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:visibleRegion.farLeft
                                                                       coordinate:visibleRegion.nearRight];
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterEstablishment;

    GMSPlacesClient *placesClient = [[GMSPlacesClient alloc]init];

    [placesClient autocompleteQuery:searchText
                              bounds:bounds
                              filter:filter
                            callback:^(NSArray *results, NSError *error) {
                                if (error != nil) {
                                    NSLog(@"Autocomplete error %@", [error localizedDescription]);
                                    return;
                                }

                                for (GMSAutocompletePrediction* result in results) {
                                    NSLog(@"Result '%@' with placeID %@", result.attributedFullText.string, result.placeID);
                                    self.searchArray = [NSMutableArray new];
                                    [self.searchArray addObjectsFromArray:results];
                                    self.searchResultsTV.hidden = NO;
                                    [self.searchResultsTV reloadData];
                                }
                            }];

}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    GMSAutocompletePrediction *result = [self.searchArray objectAtIndex:indexPath.row];
    NSString *searchResult = [NSString stringWithFormat:@"%@",result.attributedFullText];
    cell.textLabel.text = searchResult;

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    GMSAutocompletePrediction *result = [self.searchArray objectAtIndex:indexPath.row];
    GMSPlacesClient *placesClient = [[GMSPlacesClient alloc]init];
    [placesClient lookUpPlaceID:result.placeID callback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            NSLog(@"Place Details error %@", [error localizedDescription]);
            return;
        }

        if (place != nil) {
            NSLog(@"Place name %@", place.name);
            NSLog(@"Place address %@", place.formattedAddress);
            NSLog(@"Place placeID %@", place.placeID);
            NSLog(@"Place attributions %@", place.attributions);

            GMSMarker *newMarker = [[GMSMarker alloc]init];
            newMarker.position = place.coordinate;
            newMarker.title = place.name;
            newMarker.icon = [GMSMarker markerImageWithColor:[UIColor yellowColor]];
            newMarker.map = self.mapView;
            self.searchResultsTV.hidden = YES;

        } else {
            NSLog(@"No place details for %@", result.placeID);
        }
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PlaceDetailViewController *placeDetailVC =[segue destinationViewController];
    placeDetailVC.selectedPlaceName = self.selectedPlaceName;
}

-(void)passDataToOtherTabBarVCs
{
    BucketListViewController *bucketListVC = (BucketListViewController *)[self.tabBarController.viewControllers objectAtIndex:1];
    CameraViewController *cameraVC = (CameraViewController *)[self.tabBarController.viewControllers objectAtIndex:2];

    cameraVC.selectedPlaceName = self.selectedPlaceName;
    bucketListVC.desiredPlaceArray = self.usersDesiredPlaces;

}

#pragma Mark - memory management methods

-(void)dealloc
{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"Memory warning!");
}


@end
