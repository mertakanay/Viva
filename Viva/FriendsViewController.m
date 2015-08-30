//
//  FriendsViewController.m
//  Viva
//
//  Created by Mert Akanay on 8/15/15.
//  Copyright (c) 2015 Viva. All rights reserved.
//

#import "FriendsViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface FriendsViewController () <UITableViewDataSource, UITableViewDelegate>

@property NSMutableArray *friendsArray;

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.friendsArray = [NSMutableArray new];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"/me/friends"
                                  parameters:nil
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {

        NSArray *friendsList = result[@"data"];
        for (int i = 0; i < friendsList.count; i++) {
            NSString *friendName = friendsList[i][@"name"];
            [self.friendsArray addObject:friendName];
        }

    }];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendsCell"];
    cell.textLabel.text = [self.friendsArray objectAtIndex:indexPath.row];

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friendsArray.count;
}

-(void)dealloc
{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
