//
//  ViewController.h
//  TwitterTest
//
//  Created by Konstantin on 25.12.17.
//  Copyright © 2017 KONSTATIN MAXIMOV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STTwitter.h"

@interface ViewController : UIViewController <UITableViewDataSource, UIActionSheetDelegate, STTwitterAPIOSProtocol>

@property (nonatomic, strong) NSArray *statuses;

@property (nonatomic, weak) IBOutlet NSString *consumerKeyTextField;
@property (nonatomic, weak) IBOutlet NSString *consumerSecretTextField;
@property (nonatomic, weak) IBOutlet UILabel *loginStatusLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

- (IBAction)loginOnTheWebAction:(id)sender;
- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verfier;

@end

