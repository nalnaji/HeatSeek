//
//  ConfirmImageViewController.m
//  HeatSeek
//
//  Created by Naseem Al-Naji on 6/27/15.
//  Copyright (c) 2015 Naseem Al-Naji. All rights reserved.
//

#import "ConfirmImageViewController.h"
#import "SendToFriendsViewController.h"

@interface ConfirmImageViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *retakeButton;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *challengeButton;

@end

@implementation ConfirmImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.imageView setImage:[self visualImage]];
}
- (IBAction)retakeButtonClicked:(id)sender {
     [self performSegueWithIdentifier:@"retakeSegue" sender: sender];
}
- (IBAction)continueButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"sendChallengeSegue" sender: sender];
}
- (IBAction)challengeButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"goToChallengesSegue" sender: sender];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    if ([[segue identifier] isEqualToString:@"sendChallengeSegue"])
    {
        // Get reference to the destination view controller
        SendToFriendsViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        [vc setThermalImage:[self thermalImage]];
        [vc setVisualImage:[self visualImage]];
        [vc setPhotoTemperature:[self photoTemperature]];
        
    }
    // Pass the selected object to the new view controller.
}

@end
