//
//  SendToFriendsViewController.h
//  HeatSeek
//
//  Created by Naseem Al-Naji on 6/27/15.
//  Copyright (c) 2015 Naseem Al-Naji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SendToFriendsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *friendsTableView;

@property (strong, nonatomic) UIImage *thermalImage;
@property (strong, nonatomic) UIImage *visualImage;
@property (nonatomic) int photoTemperature;

@end
