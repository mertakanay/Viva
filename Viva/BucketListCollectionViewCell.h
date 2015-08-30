//
//  BucketListCollectionViewCell.h
//  Viva
//
//  Created by Mert Akanay on 8/2/15.
//  Copyright (c) 2015 Viva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h"

@interface BucketListCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *checkBox;
@property Place *place;


@end
