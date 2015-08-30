//
//  Place.h
//  Viva
//
//  Created by Mert Akanay on 7/6/15.
//  Copyright (c) 2015 Viva. All rights reserved.
//

#import <Parse/Parse.h>

@class User;

@interface Place : PFObject

@property NSString *name;
@property int rating;
@property User *user;
@property NSMutableArray *pictureArray;
@property PFGeoPoint *coordinate;
@property NSMutableArray *pictures;
@property float googleRating;
@property NSString *iD;
@property BOOL alreadyBeen;

@end
