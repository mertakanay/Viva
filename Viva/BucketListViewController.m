//
//  BucketListViewController.m
//  Viva
//
//  Created by Mert Akanay on 7/25/15.
//  Copyright (c) 2015 Viva. All rights reserved.
//

#import "BucketListViewController.h"
#import "BucketListCollectionViewCell.h"
#import "User.h"
#import "PlaceDetailViewController.h"

@interface BucketListViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *titleView;
@property NSMutableArray *placesArray;
@property Place *selectedPlace;

@end

@implementation BucketListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setHeadLine];
    [self getBucketListPlaces];
    [self addTapGestureRecognizer];

}

-(void)getBucketListPlaces
{
    self.placesArray = [NSMutableArray new];
    User *user = [User currentUser];
    PFRelation *relation = [user relationForKey:@"placeToGo"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *places, NSError *error) {
        for (Place *place in places) {
            [self.placesArray addObject:place];
            [self.collectionView reloadData];
        }        
    }];

}

-(void)addTapGestureRecognizer
{
//    UITapGestureRecognizer *checkBoxTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(checkBoxAction)];
    UITapGestureRecognizer *pictureTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(prepareForSegue:sender:)];
    BucketListCollectionViewCell *cell = [[BucketListCollectionViewCell alloc]init];
    [cell.imageView addGestureRecognizer:pictureTapGesture];
//    [cell.checkBox addGestureRecognizer:checkBoxTapGesture];
}

-(void)checkBoxAction
{
    BucketListCollectionViewCell *cell = [[BucketListCollectionViewCell alloc]init];
    cell.checkBox.image = [UIImage imageNamed:@"checked.png"];
    [self rateAlertPopUp];
}

-(void)rateAlertPopUp
{
    //finish this

    NSString *alertTitle = [NSString stringWithFormat:@"Rate %@",self.selectedPlace[@"name"]];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:alertTitle message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
}

-(void)setHeadLine
{
    NSString *fullName = [User currentUser].username;
    NSScanner *scanner = [NSScanner scannerWithString:fullName];
    NSString *firstName = [[NSString alloc]init];
    [scanner scanUpToString:@" " intoString:&firstName];
    self.firstNameLabel.text = [NSString stringWithFormat:@"%@'s Bucket List",firstName];

}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BucketListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CVCellID" forIndexPath:indexPath];
    Place *thePlace = [self.placesArray objectAtIndex:indexPath.row];
    cell.place = thePlace;
    if (thePlace[@"pictures"][0] != nil) {
        cell.imageView.image = thePlace[@"pictures"][0];
    }else{
        cell.imageView.image = [UIImage imageNamed:@"imagePlaceholder.png"];
    }

    cell.checkBox.image = [UIImage imageNamed:@"unchecked.png"];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPlace = [self.placesArray objectAtIndex:indexPath.row];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.placesArray.count;

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PlaceDetailViewController *placeDetailVC = [segue destinationViewController];
    placeDetailVC.selectedPlaceName = self.selectedPlace[@"name"];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *placeDetailNavVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"placeDetailNavVC"];
    [self presentViewController:placeDetailNavVC animated:TRUE completion:nil];
}

-(void)dealloc
{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
