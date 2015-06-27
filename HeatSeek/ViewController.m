//
//  ViewController.m
//  HeatSeek
//
//  Created by Naseem Al-Naji on 6/27/15.
//  Copyright (c) 2015 Naseem Al-Naji. All rights reserved.
//
#import <FLIROneSDK/FLIROneSDKSimulation.h>
#import <FLIROneSDK/FLIROneSDKUIImage.h>

#import <FLIROneSDK/FLIROneSDKLibraryViewController.h>

#import <AVFoundation/AVFoundation.h>


#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *thermalImageView; //for the UI
@property (strong, nonatomic) UIImage *thermalImage;                //lates frame for video
@property (strong, nonatomic) dispatch_queue_t renderQueue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.renderQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [[FLIROneSDKStreamManager sharedInstance] addDelegate:self];
    [[FLIROneSDKStreamManager sharedInstance] setImageOptions:FLIROneSDKImageOptionsBlendedMSXRGBA8888Image];

    [[FLIROneSDKSimulation sharedInstance] connectWithFrameBundleName:@"sampleframes_hq" withBatteryChargePercentage:@42];
}

- (void)FLIROneSDKDelegateManager:(FLIROneSDKDelegateManager *)delegateManager didReceiveBlendedMSXRGBA8888Image:(NSData *)msxImage imageSize:(CGSize)size{
    //NSLog(@"DID RECEIVE didReceiveBlendedMSXRGBA8888Image");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.thermalImage = [FLIROneSDKUIImage imageWithFormat:FLIROneSDKImageOptionsBlendedMSXRGBA8888Image andData:msxImage andSize:size];
        [self updateUI];
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.thermalImageView setImage:self.thermalImage];
    });
}

@end
