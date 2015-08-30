//
//  CustomInfoWindow.h
//  Viva
//
//  Created by Mert Akanay on 7/8/15.
//  Copyright (c) 2015 Viva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceDetailViewController.h"
#import "MapViewController.h"

@interface CustomInfoWindow : UIView
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *placeStarImage;
@property (weak, nonatomic) IBOutlet UILabel *placeTagLabel;
@property (weak, nonatomic) IBOutlet UIImageView *infoImage1;
@property (weak, nonatomic) IBOutlet UIImageView *infoImage2;
@property (weak, nonatomic) IBOutlet UIImageView *infoImage3;
@property (weak, nonatomic) IBOutlet UIImageView *infoImage4;
@property (weak, nonatomic) IBOutlet UIImageView *infoImage5;
@property (weak, nonatomic) IBOutlet UIButton *detailsButton;

@end
