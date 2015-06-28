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
@property (weak, nonatomic) IBOutlet UIImageView *visualImageView;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;

@property (strong, nonatomic) UIImage *thermalImage;                //lates frame for video
@property (strong, nonatomic) UIImage *visualImage;

@property (strong, nonatomic) UIImage *photo;
@property (nonatomic) int photoTemperature;

@property (strong, nonatomic) NSData *thermalData;
@property (nonatomic) CGSize thermalSize;

@property (nonatomic, strong) IBOutlet UIButton *capturePhotoButton;
@property (nonatomic, strong) IBOutlet UILabel *tempLabel;

@property (strong, nonatomic) dispatch_queue_t renderQueue;
@property (nonatomic) FLIROneSDKImageOptions options;

@property (nonatomic) BOOL connected;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.connected = NO;
    // Do any additional setup after loading the view, typically from a nib.
    self.renderQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [[FLIROneSDKStreamManager sharedInstance] addDelegate:self];
    
    self.options = FLIROneSDKImageOptionsBlendedMSXRGBA8888Image;
    self.options = (FLIROneSDKImageOptions)(self.options ^ FLIROneSDKImageOptionsVisualJPEGImage);
    self.options = (FLIROneSDKImageOptions)(self.options ^ FLIROneSDKImageOptionsThermalRadiometricKelvinImage);
    [FLIROneSDKStreamManager sharedInstance].imageOptions = self.options;
    self.photoTemperature = -1;
    [[FLIROneSDKSimulation sharedInstance] connectWithFrameBundleName:@"sampleframes_hq" withBatteryChargePercentage:@42];
    
    [self updateUI];
}

- (void)FLIROneSDKDelegateManager:(FLIROneSDKDelegateManager *)delegateManager didReceiveBlendedMSXRGBA8888Image:(NSData *)msxImage imageSize:(CGSize)size{
    //NSLog(@"DID RECEIVE didReceiveBlendedMSXRGBA8888Image");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.thermalImage = [FLIROneSDKUIImage imageWithFormat:FLIROneSDKImageOptionsBlendedMSXRGBA8888Image andData:msxImage andSize:size];
        [self updateUI];
    });
    
}

- (void)FLIROneSDKDelegateManager:(FLIROneSDKDelegateManager *)delegateManager didReceiveVisualJPEGImage:(NSData *)visualJPEGImage {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *rotatedJPEG = [FLIROneSDKUIImage imageWithFormat:FLIROneSDKImageOptionsVisualJPEGImage andData:visualJPEGImage andSize:CGSizeZero];
        
        self.visualImage = [[UIImage alloc]
                                initWithCGImage:rotatedJPEG.CGImage
                                scale:1.0
                                orientation:UIImageOrientationRight];
        [self updateUI];
    });
    
}

- (void)FLIROneSDKDelegateManager:(FLIROneSDKDelegateManager *)delegateManager didReceiveRadiometricData:(NSData *)radiometricData imageSize:(CGSize)size {
    
    @synchronized(self) {
        self.thermalData = radiometricData;
        self.thermalSize = size;
    }
}
// TAKE PHOTO METHODS
- (IBAction)capturePhoto:(id)sender {
    self.photo = self.visualImage;
    [self performTemperatureCalculations];
    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) FLIROneSDKDidConnect {
    self.connected = YES;
    [self updateUI];
}

- (void) performTemperatureCalculations {
    // 2 bytes / pixel
    // temperature = value / 100 kelvins
    uint16_t *tempData = (uint16_t *)[self.thermalData bytes];
    int row = self.thermalSize.height / 2;
    int col = self.thermalSize.width / 2;
    [NSString stringWithFormat:@"%d",(int)(self.thermalSize.width * row + col)];
    uint16_t temp = tempData[(int)(self.thermalSize.width * row + col)];
    self.photoTemperature = (int)(((temp / 100) - 273.15) * 1.8 + 32);
}

- (void) updateUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.thermalImageView setImage:self.thermalImage];
        [self.visualImageView setImage:self.visualImage];
        [self.photoView setImage:self.photo];
        [self.tempLabel setText: [NSString stringWithFormat:@"%d", self.photoTemperature]];
        
        if(self.connected) {
            [self.capturePhotoButton setEnabled:YES];
        } else {
            [self.capturePhotoButton setEnabled:NO];
        }
    });
}

@end
