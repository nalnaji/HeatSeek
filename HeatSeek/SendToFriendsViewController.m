//
//  SendToFriendsViewController.m
//  HeatSeek
//
//  Created by Naseem Al-Naji on 6/27/15.
//  Copyright (c) 2015 Naseem Al-Naji. All rights reserved.
//

#import "SendToFriendsViewController.h"
#import "User.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <AFNetworking/AFNetworking.h>
#import <ObjectiveSugar/ObjectiveSugar.h>
@interface SendToFriendsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) NSMutableArray *friendsArray;
@property (strong, nonatomic) NSString *serverURL;
@property (strong, nonatomic) NSMutableArray *selectedRowsArray;
@property (weak, nonatomic) IBOutlet UIButton *challengeButton;

@property (nonatomic) BOOL sending;
@end

@implementation SendToFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.friendsTableView.delegate = self;
    self.sending = NO;
    [self.sendButton setEnabled:NO];
    self.friendsTableView.dataSource = self;
    self.friendsArray = [[NSMutableArray alloc] init];
    self.selectedRowsArray = [[NSMutableArray alloc] init];
    NSString *tokenValue = [[FBSDKAccessToken currentAccessToken] tokenString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"access_token": tokenValue};
    [manager GET:@"http://localhost:1337/user/getfriends" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [responseObject each:^(id object) {
            NSString *name = [object objectForKey:@"name"];
            NSString *fbid = [object objectForKey:@"id"];
            User *friend = [[User alloc] initWithFullname:name initWithFBID:fbid];
            [self.friendsArray addObject:friend];
            [self.friendsTableView reloadData];
        }];
        [self.friendsTableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSIndexPath *tappedIndexPath = indexPath;
    
    if ([self.selectedRowsArray containsObject:[self.friendsArray objectAtIndex:tappedIndexPath.row]]) {
        [self.selectedRowsArray removeObject:[[self.friendsArray objectAtIndex:tappedIndexPath.row] fbid]];
    }
    else {
        [self.selectedRowsArray addObject:[[self.friendsArray objectAtIndex:tappedIndexPath.row] fbid]];
    }
    [self.friendsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:tappedIndexPath] withRowAnimation: UITableViewRowAnimationFade];
    [self updateUI];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // If you're serving data from an array, return the length of the array:
    return [self.friendsArray count];
}
- (IBAction)challengeButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"goToChallengesSegue" sender: sender];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"friendCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Set the data for this cell:
    User *friend = [self.friendsArray objectAtIndex:indexPath.row];
    NSString *name = friend.fullname;
    if ([self.selectedRowsArray containsObject:[[self.friendsArray objectAtIndex:indexPath.row] fbid]]) {
        cell.imageView.image = [UIImage imageNamed:@"checked.png"];
    }
    else {
        cell.imageView.image = [UIImage imageNamed:@"unchecked.png"];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleChecking:)];
    [cell.imageView addGestureRecognizer:tap];
    cell.imageView.userInteractionEnabled = YES; //added based on @John 's comment
    //[tap release];
    
    
    cell.textLabel.text = name;
    // set the accessory view:
    return cell;
}

- (IBAction)sendButtonClicked:(id)sender {
    self.sending = YES;
    [self uploadVisualImage];
}

-(void) uploadVisualImage {
    
    NSString *tokenValue = [[FBSDKAccessToken currentAccessToken] tokenString];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.jpg"];
    [UIImagePNGRepresentation(self.visualImage) writeToFile:filePath atomically:YES];
    // Save image.
    [UIImageJPEGRepresentation(self.visualImage, 1.0) writeToFile:filePath atomically:YES];
    NSDictionary *parameters = @{@"access_token": tokenValue, @"type": @"visual"};
    NSURL *filePathURL = [NSURL fileURLWithPath:filePath];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://localhost:1337/photo/upload" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:filePathURL name:@"image" error:nil];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        int visualID = [[responseObject objectForKey:@"id"] integerValue];
        //TODO: SAVE PHOTO ID #
        [self uploadThermalImage: visualID];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self performSegueWithIdentifier:@"afterSendSegue" sender: self];
    }];
}

-(void) uploadThermalImage:(int) vid{
    
    NSString *tokenValue = [[FBSDKAccessToken currentAccessToken] tokenString];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.jpg"];
    [UIImagePNGRepresentation(self.thermalImage) writeToFile:filePath atomically:YES];
    // Save image.
    [UIImageJPEGRepresentation(self.thermalImage, 1.0) writeToFile:filePath atomically:YES];
    NSDictionary *parameters = @{@"access_token": tokenValue, @"type": @"thermal"};
    NSURL *filePathURL = [NSURL fileURLWithPath:filePath];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://localhost:1337/photo/upload" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:filePathURL name:@"image" error:nil];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        //TODO: SAVE PHOTO ID #
        int thermalID = [[responseObject objectForKey:@"id"] integerValue];
        //upload challenge
        [self uploadChallengeWithVisualID:vid withThermalID:thermalID];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self performSegueWithIdentifier:@"afterSendSegue" sender: self];
    }];
}

- (void) uploadChallengeWithVisualID:(int) vid withThermalID:(int)tid{
    NSLog(@"Got photo id's");
    NSString *tokenValue = [[FBSDKAccessToken currentAccessToken] tokenString];
    NSString *selectedFriends = [[self.selectedRowsArray valueForKey:@"description"] componentsJoinedByString:@","];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"access_token": tokenValue,
                                 @"to":           selectedFriends,
                                 @"photoVisual":  [NSString stringWithFormat:@"%d", vid],
                                 @"photoThermal": [NSString stringWithFormat:@"%d", tid],
                                 @"temp":         [NSString stringWithFormat:@"%d", self.photoTemperature]};
    [manager POST:@"http://localhost:1337/challenge/new" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [self performSegueWithIdentifier:@"afterSendSegue" sender: self];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self performSegueWithIdentifier:@"afterSendSegue" sender: self];
    }];
}

- (void) handleChecking:(UITapGestureRecognizer *)tapRecognizer {
    CGPoint tapLocation = [tapRecognizer locationInView:self.friendsTableView];
    NSIndexPath *tappedIndexPath = [self.friendsTableView indexPathForRowAtPoint:tapLocation];
    
    if ([self.selectedRowsArray containsObject:[[self.friendsArray objectAtIndex:tappedIndexPath.row] fbid]]) {
        [self.selectedRowsArray removeObject:[[self.friendsArray objectAtIndex:tappedIndexPath.row] fbid]];
    }
    else {
        [self.selectedRowsArray addObject:[[self.friendsArray objectAtIndex:tappedIndexPath.row] fbid]];
    }
    [self.friendsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:tappedIndexPath] withRowAnimation: UITableViewRowAnimationFade];
    [self updateUI];
}

- (void) updateUI {
    if ([self.selectedRowsArray count] < 1 || self.sending) {
        [self.sendButton setEnabled:NO];
    }else {
        [self.sendButton setEnabled:YES];
    }
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
