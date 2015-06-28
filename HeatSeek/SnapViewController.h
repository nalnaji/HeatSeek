//
//  SnapViewController.h
//  HeatSeek
//
//  Created by Naseem Al-Naji on 6/27/15.
//  Copyright (c) 2015 Naseem Al-Naji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLIROneSDK/FLIROneSDK.h"

@interface SnapViewController : UIViewController <FLIROneSDKImageReceiverDelegate, FLIROneSDKStreamManagerDelegate>

@end
