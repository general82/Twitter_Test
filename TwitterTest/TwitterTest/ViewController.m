//
//  ViewController.m
//  TwitterTest
//
//  Created by Konstantin on 25.12.17.
//  Copyright © 2017 KONSTATIN MAXIMOV. All rights reserved.
//

#import "ViewController.h"
#import "STTwitter.h"
#import "WebViewVC.h"
#import <Accounts/Accounts.h>

@interface ViewController ()
@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSArray *iOSAccounts;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.accountStore = [[ACAccountStore alloc] init];
    
    _consumerKeyTextField = @"PdLBPYUXlhQpt4AguShUIw";
    _consumerSecretTextField = @"drdhGuKSingTbsDLtYpob4m5b5dn1abf9XXYyZKQzk";
    
    [self loginOnTheWebAction:nil];
}

- (IBAction)loginOnTheWebAction:(id)sender {
    
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:_consumerKeyTextField
                                                 consumerSecret:_consumerSecretTextField];
    
    _loginStatusLabel.text = @"Подключаемся к твиттеру...";
    _loginStatusLabel.text = @"";
    
    [_twitter postTokenRequest:^(NSURL *url, NSString *oauthToken) {
        NSLog(@"url: %@", url);
        NSLog(@"oauthToken: %@", oauthToken);
        
        WebViewVC *webViewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewVC"];
        
        [self presentViewController:webViewVC animated:YES completion:^{
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [webViewVC.webView loadRequest:request];
        }];        
        
    } authenticateInsteadOfAuthorize:NO
                    forceLogin:@(YES)
                    screenName:nil
                 oauthCallback:@"myapp://twitter_access_tokens/"
                    errorBlock:^(NSError *error) {
                        NSLog(@"error: %@", error);
                        _loginStatusLabel.text = [error localizedDescription];
                    }];
}

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
    
    [self dismissViewControllerAnimated:YES completion:^{}];
    
    [_twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        NSLog(@"screenName: %@", screenName);
        
        _loginStatusLabel.text = [NSString stringWithFormat:@"%@ (%@)", screenName, userID];
        
        [self getTimelineAction];

        
    } errorBlock:^(NSError *error) {
        
        _loginStatusLabel.text = [error localizedDescription];
        NSLog(@"error:%@", [error localizedDescription]);
    }];
}

- (void)getTimelineAction {
    
    [_twitter getHomeTimelineSinceID:nil count:20
        successBlock:^(NSArray *statuses) {
            
            NSLog(@"statuses: %@", statuses);
            
            self.statuses = statuses;
            
            [self.tableView reloadData];
            
        } errorBlock:^(NSError *error) {}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)twitterAPI:(STTwitterAPI *)twitterAPI accountWasInvalidated:(ACAccount *)invalidatedAccount{
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.statuses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             @"STTwitterTVCellIdentifier"];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"STTwitterTVCellIdentifier"];
    }
    
    NSDictionary *status = [self.statuses objectAtIndex:indexPath.row];
    
    NSString *text = [status valueForKey:@"text"];
    NSString *screenName = [status valueForKeyPath:@"user.screen_name"];
    NSString *dateString = [status valueForKey:@"created_at"];
    
    cell.textLabel.text = text;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"@%@ | %@", screenName, dateString];
    
    return cell;
}

@end
