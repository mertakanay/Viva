//
//  User.h
//  Viva
//
//  Created by Mert Akanay on 7/6/15.
//  Copyright (c) 2015 Viva. All rights reserved.
//

#import <Parse/Parse.h>
#import "City.h"

@class Place;

@interface User : PFUser <PFSubclassing>

@property PFFile *profileImage;
@property City *cityToGo;
@property City *cityBeen;
@property NSMutableArray *placeLoved;
@property NSMutableArray *placeToGo;

@end
