//
//  SubmitChallengeViewController.m
//  HeatSeek
//
//  Created by Naseem Al-Naji on 6/28/15.
//  Copyright (c) 2015 Naseem Al-Naji. All rights reserved.
//

#import "SubmitChallengeViewController.h"
#import <ObjectiveSugar/ObjectiveSugar.h>
#import <AFNetworking/AFNetworking.h>
#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>


@interface SubmitChallengeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UITextField *guessInput;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;
@property (weak, nonatomic) IBOutlet UIImageView *congrats;

@property int current;
@end

@implementation SubmitChallengeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.current = 0;
    // /photo/:id
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *thermalPath = [NSString stringWithFormat:@"http://localhost:1337/photo/%@", [self.challengeInfo objectForKey:@"photoThermal"]];
    [manager GET:thermalPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Thermal_image: %@", responseObject);

        NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://localhost:1337/uploads/%@", [responseObject objectForKey:@"filename"]]];
        [self.imageView sd_setImageWithURL:url];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    
    
}
- (IBAction)dismissKeyboard:(id)sender {
    [self.view endEditing:YES];
    NSLog(@"dismiss");
}
- (IBAction)toggleClicked:(id)sender {
    if (self.current == 0) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSString *visualPath = [NSString stringWithFormat:@"http://localhost:1337/photo/%@", [self.challengeInfo objectForKey:@"photoVisual"]];
        [manager GET:visualPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Visual_image: %@", responseObject);
            
            NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://localhost:1337/uploads/%@", [responseObject objectForKey:@"filename"]]];
            [self.imageView sd_setImageWithURL:url];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        self.current = 1;
    } else {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSString *thermalPath = [NSString stringWithFormat:@"http://localhost:1337/photo/%@", [self.challengeInfo objectForKey:@"photoThermal"]];
        [manager GET:thermalPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Thermal_image: %@", responseObject);
            
            NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://localhost:1337/uploads/%@", [responseObject objectForKey:@"filename"]]];
            [self.imageView sd_setImageWithURL:url];
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        self.current = 0;
    }
    
}
- (IBAction)challengesClicked:(id)sender {
    [self performSegueWithIdentifier:@"goToChallengesSegue" sender: sender];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)challengeButtonClicked:(id)sender {
    
}
- (IBAction)submitChallenge:(id)sender {
    [self.view endEditing:YES];
    if (abs([self.guessInput.text integerValue] - [[self.challengeInfo objectForKey:@"temperature"] integerValue]) < 5){
         self.resultLabel.text = @"80";
        [self.congrats setAlpha:1.0];
    }else {
        self.resultLabel.text = @"Wrong!!!";
    }
    self.submitButton.enabled = NO;

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
