//
//  LaunchPageViewController.m
//  Viva
//
//  Created by Mert Akanay on 7/6/15.
//  Copyright (c) 2015 Viva. All rights reserved.
//

#import "LaunchPageViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "User.h"
#import "MapViewController.h"

@interface LaunchPageViewController ()
@property (weak, nonatomic) IBOutlet UIButton *logInWithFacebookButton;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property (weak, nonatomic) IBOutlet UIButton *createAnAccountButton;


@end

@implementation LaunchPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
//    loginButton.center = self.view.center;
//    [self.view addSubview:loginButton];
//    // Do any additional setup after loading the view.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (void) logInWithFacebook
{
    NSArray *permissions = [NSArray arrayWithObjects:@"public_profile", @"email", @"user_friends", nil];

    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissions block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");

            [self getFacebookData];

        } else {
            NSLog(@"User logged in through Facebook!");

            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *tabBarVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"tabBarVC"];
            [self presentViewController:tabBarVC animated:TRUE completion:nil];
        }
    }];
}

- (void) getFacebookData
{
    User *theUser = [User currentUser];
    FBSDKGraphRequest *fbRequest = [[FBSDKGraphRequest alloc]initWithGraphPath:@"me" parameters:nil];
    [fbRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error)
        {
            theUser.username = result[@"name"];
            theUser.email = result[@"email"];
            NSString *facebookID = result[@"id"];
            [theUser saveInBackground];
            [self getFacebookProfilePicture:facebookID];

        }
    }];
}


//FIX THIS
-(void) getFacebookProfilePicture :(NSString *)facebookID
{
    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/\(facebookID)/picture?type=large"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        PFFile *file = [PFFile fileWithData:data];
        User *theUser = [User currentUser];
        theUser.profileImage = file;

        [theUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Succeeded");

                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController *tabBarVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"tabBarVC"];
                [self presentViewController:tabBarVC animated:TRUE completion:nil];

            } else {
                NSLog(@"Failed");
            }

        }];

    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLogInWithFacebookButtonPressed:(UIButton *)sender
{
    [self logInWithFacebook];
}

- (IBAction)onLogInButtonPressed:(UIButton *)sender {
}


- (IBAction)onCreateAnAccountButtonPressed:(UIButton *)sender {
}


@end
