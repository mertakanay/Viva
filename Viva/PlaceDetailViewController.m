//
//  PlaceDetailViewController.m
//  Viva
//
//  Created by Mert Akanay on 8/2/15.
//  Copyright (c) 2015 Viva. All rights reserved.
//

#import "PlaceDetailViewController.h"
#import "User.h"
#import "PlaceDetailCollectionViewCell.h"

@interface PlaceDetailViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *userContentButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *ratingImageView;
@property (weak, nonatomic) IBOutlet UILabel *commentTitle;
@property (weak, nonatomic) IBOutlet UILabel *tagTitle;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UITextView *tagTextView;
@property NSMutableArray *placeDataArray;

@end

@implementation PlaceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setCommentTitle];
    [self getUserData];
    [self downloadPlaceDetailsFromParse];

    self.placeNameLabel.text = self.selectedPlaceName;
    [self setRatingImageWithRating:4];
}

-(void)downloadPlaceDetailsFromParse
{
    self.placeDataArray = [NSMutableArray new];
    PFQuery *query = [PFQuery queryWithClassName:@"Place"];
    [query whereKey:@"name" equalTo:self.selectedPlaceName];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
            [self.placeDataArray addObjectsFromArray:objects];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)getUserData
{
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
//    NSString *objectId = [PFUser currentUser][@"objectId"];
    [query whereKey:@"username" equalTo:[User currentUser].username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
            User *currentUser = objects[0];
            if (currentUser[@"profileImage"] != nil) {
                [self.userContentButton setBackgroundImage:currentUser[@"profileImage"] forState:UIControlStateNormal];
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

//    User *currentUser = [User currentUser];
//    if (currentUser[@"profileImage"] != nil) {
//        [self.userContentButton setBackgroundImage:currentUser[@"profileImage"] forState:UIControlStateNormal];
//    }
}

-(void)setRatingImageWithRating:(int)rating
{
    if (rating == 1){
        self.ratingImageView.image = [UIImage imageNamed:@"1star.png"];
    }else if (rating == 2){
        self.ratingImageView.image = [UIImage imageNamed:@"2stars.png"];
    }else if (rating == 3){
        self.ratingImageView.image = [UIImage imageNamed:@"3stars.png"];
    }else if (rating == 4){
        self.ratingImageView.image = [UIImage imageNamed:@"4stars.png"];
    }else if (rating == 5){
        self.ratingImageView.image = [UIImage imageNamed:@"5stars.png"];
    }else{
        self.ratingImageView.image = [UIImage imageNamed:@"0stars.png"];
    }
}

-(void)setCommentTitle
{
    NSString *fullName = [User currentUser].username;
    NSScanner *scanner = [NSScanner scannerWithString:fullName];
    NSString *firstName = [[NSString alloc]init];
    [scanner scanUpToString:@" " intoString:&firstName];
    self.commentTitle.text = [NSString stringWithFormat:@"%@ says...",firstName];

}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.placeDataArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PlaceDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CVCellID" forIndexPath:indexPath];
    NSMutableArray *tempArray = [NSMutableArray new];
    NSMutableArray *picturesOfPlace = [NSMutableArray new];

    for (Place *thePlace in self.placeDataArray) {
        [tempArray addObjectsFromArray:thePlace[@"pictures"]];
    }

    for (PFFile *pictureFile in tempArray) {
        [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *newImage = [UIImage imageWithData:data];
                [picturesOfPlace addObject:newImage];
            }
        }];
    }
    cell.imageView.image = [picturesOfPlace objectAtIndex:indexPath.row];
    
    return cell;
}

-(void)dealloc
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
