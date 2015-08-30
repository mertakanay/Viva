//
//  CameraViewController.m
//  Viva
//
//  Created by Mert Akanay on 8/11/15.
//  Copyright (c) 2015 Viva. All rights reserved.
//

#import "CameraViewController.h"
#import <Parse/Parse.h>
#import "User.h"
#import "Place.h"

@interface CameraViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate, UIActionSheetDelegate, UIPickerViewDelegate>

//mapte seçilsin mekan, o mekana photo ekle

@property (nonatomic) UIButton *libraryButton;
@property (nonatomic) UIImageView *libraryImageView;
@property (nonatomic) UIImagePickerController *cameraImagePickerController;
@property (nonatomic) UIImagePickerController *libraryImagePickerController;
@property (nonatomic) UIImage *albumImage;
@property (nonatomic) UIButton *cameraButton;
@property (nonatomic) BOOL shouldHideCamera;

@property UIImagePickerController *picker;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self presentCamera];
}

- (void)viewWillAppear:(BOOL)animated
{

}

-(void)presentCamera
{
    self.picker = [[UIImagePickerController alloc] init];
    self.picker.delegate = self;
    self.picker.allowsEditing = YES;
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
    {
        self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.picker animated:YES completion:nil];
    }
    else
    {
        NSLog(@"No camera found");
    }
}

- (void) navigationController: (UINavigationController *) navigationController  willShowViewController: (UIViewController *) viewController animated: (BOOL) animated {
    if (self.picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showCamera:)];
        viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObject:button];
    } else {
        UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:@"Library" style:UIBarButtonItemStylePlain target:self action:@selector(showLibrary:)];
        viewController.navigationItem.leftBarButtonItems = [NSArray arrayWithObject:button];
        viewController.navigationItem.title = @"Take Photo";
        viewController.navigationController.navigationBarHidden = NO; // important
    }
}

- (void) showCamera: (id) sender {
    self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
}

- (void) showLibrary: (id) sender {
    self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *img = info[UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImageJPEGRepresentation(img,0.5);
    PFFile *imageFile = [PFFile fileWithName:@"Picked photo" data:imageData];
    User *currentUser = [User currentUser];
    PFRelation *relation = [currentUser relationForKey:@"placeLoved"];
    PFQuery *query = [relation query];
    [query whereKey:@"name" equalTo:self.selectedPlaceName];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (!error) {

            NSLog(@"%lu",(unsigned long)array.count);
            Place *thePlace = [array objectAtIndex:0];
            NSMutableArray *thePlacePictures = [thePlace objectForKey:@"pictures"];

            if (thePlacePictures == nil) {
                thePlacePictures = [NSMutableArray new];
                [thePlacePictures addObject:imageFile];

            } else {
                [thePlacePictures addObject:imageFile];

            }

            thePlace[@"pictures"] = [NSArray arrayWithArray:thePlacePictures];
            [thePlace saveInBackground];

        }else{
            NSLog(@"Places to go error: %@",[error localizedDescription]);
        }
    }];

    self.shouldHideCamera = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
    self.view.hidden = NO;
}

-(void)dealloc
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
