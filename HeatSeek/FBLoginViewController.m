//
//  FBLoginViewController.m
//  HeatSeek
//
//  Created by Naseem Al-Naji on 6/27/15.
//  Copyright (c) 2015 Naseem Al-Naji. All rights reserved.
//

#import "FBLoginViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface FBLoginViewController ()

@property (weak, nonatomic) IBOutlet FBSDKLoginButton *loginButton;

@end

@implementation FBLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.loginButton setDelegate:self];
    // Do any additional setup after loading the view.
    if ([FBSDKAccessToken currentAccessToken]) {
        // User is logged in, do work such as go to next view controller.
        NSLog(@"GOOOO");
        [self performSegueWithIdentifier:@"loggedInSegue" sender: self];
    }
    
    self.loginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*!
 @abstract Sent to the delegate when the button was used to login.
 @param loginButton the sender
 @param result The results of the login
 @param error The error (if any) from the login
 */
- (void)  loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
                error:(NSError *)error {
    NSLog(@"Logged in");
    NSString *tokenValue = [[FBSDKAccessToken currentAccessToken] tokenString];
    NSLog(tokenValue);
    [self performSegueWithIdentifier:@"loggedInSegue" sender: loginButton];
}

/*!
 @abstract Sent to the delegate when the button was used to logout.
 @param loginButton The button that was clicked.
 */
- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    NSLog(@"Logged out");
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
