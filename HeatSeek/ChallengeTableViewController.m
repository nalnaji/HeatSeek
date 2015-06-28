//
//  ChallengeTableViewController.m
//  HeatSeek
//
//  Created by Naseem Al-Naji on 6/28/15.
//  Copyright (c) 2015 Naseem Al-Naji. All rights reserved.
//

#import "ChallengeTableViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ObjectiveSugar/ObjectiveSugar.h>
#import <AFNetworking/AFNetworking.h>
#import "SubmitChallengeViewController.h"


@interface ChallengeTableViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (strong, nonatomic) NSMutableArray *challenges;
@property (strong, nonatomic) NSDictionary *challenge;


@end

@implementation ChallengeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.challenges = [[NSMutableArray alloc] init];
    NSString *tokenValue = [[FBSDKAccessToken currentAccessToken] tokenString];
    NSDictionary *parameters = @{@"access_token": tokenValue};
    //challenge/received?access
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"http://localhost:1337/challenge/received" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        
        [responseObject each:^(id object) {
            
            [self.challenges addObject:object];
        }];

        [self.tableView reloadData];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}
- (IBAction)cameraButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"takeImageSegue" sender: sender];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.challenges count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"challengeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Set the data for this cell:
    NSDictionary *challenge = [self.challenges objectAtIndex:indexPath.row];
    NSDictionary *from = [challenge objectForKey:@"from"];
    NSString *name = [from objectForKey:@"name"];
    NSString *text = [NSString stringWithFormat:@"Challenge from: %@", name];

    
    cell.textLabel.text = text;
    // set the accessory view:
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSIndexPath *tappedIndexPath = indexPath;
    NSDictionary *challenge = [self.challenges objectAtIndex:indexPath.row];
    self.challenge = challenge;
    [self performSegueWithIdentifier:@"submitChallengeSegue" sender: self];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    if ([[segue identifier] isEqualToString:@"submitChallengeSegue"])
    {
        // Get reference to the destination view controller
        SubmitChallengeViewController *vc = [segue destinationViewController];
        
        // Pass any objects to the view controller here, like...
        [vc setChallengeInfo:self.challenge];
        
    }
    // Pass the selected object to the new view controller.
}

@end
