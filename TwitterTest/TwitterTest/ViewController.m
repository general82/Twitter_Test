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
#import <Social/Social.h>
#import <Twitter/Twitter.h>

@interface ViewController ()
@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSArray *iOSAccounts;
@end

@implementation ViewController

- (void)downloadTwitterFeed:(NSString *)strTwitterToken
{
    NSURL *twitterURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/user_timeline.json?include_entities=true&include_rts=true&screen_name=%@&count=20", @"rt_russian"]];
    
    NSMutableURLRequest *twitterRequest = [NSMutableURLRequest requestWithURL:twitterURL];
    [twitterRequest setHTTPMethod:@"GET"];
    
    [twitterRequest addValue:[NSString stringWithFormat:@"Bearer %@", strTwitterToken] forHTTPHeaderField:@"Authorization"];
    
    NSLog(@"<NSURLRequest %@>", [[twitterRequest URL] absoluteString]);
    NSLog(@"%@", [twitterRequest allHTTPHeaderFields]);

    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *dataTask = [urlSession
          dataTaskWithRequest:twitterRequest
          completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
              
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
              if (httpResponse.statusCode == 200){
                  
                  NSError *jsonError = nil;
                  id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];

                  
                  self.statuses = json;
                  [self.tableView reloadData];

              }
              
          }];
    
    [dataTask resume];
}

- (NSString *)st_stringByAddingRFC3986PercentEscapesUsingEncoding:(NSStringEncoding)encoding {
    
    NSString *s = (__bridge_transfer NSString *)
    (CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                             (CFStringRef)self,
                                             NULL,
                                             CFSTR("!*'();:@&=+$,/?%#[]"),
                                             kCFStringEncodingUTF8));
    return s;
}


- (NSString *)base64EncodedBearerTokenCredentialsWithConsumerKey:(NSString *)consumerKey
                                                  consumerSecret:(NSString *)consumerSecret {
    
    NSString *encodedConsumerToken = [consumerKey st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *encodedConsumerSecret = [consumerSecret st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *bearerTokenCredentials = [NSString stringWithFormat:@"%@:%@", encodedConsumerToken, encodedConsumerSecret];
    
    NSData *data = [bearerTokenCredentials dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64Encoding];
}


- (void)viewDidLoad {
    [super viewDidLoad];
//-----------------------------------------------------------------------------------------------
    NSURL *twitterURL = [NSURL URLWithString:@"https://api.twitter.com/oauth2/token"];
    NSMutableURLRequest *twitterRequest = [NSMutableURLRequest requestWithURL:twitterURL];
    [twitterRequest setHTTPMethod:@"POST"];
    
    
    NSString *base64EncodedTokens1 =
    [self base64EncodedBearerTokenCredentialsWithConsumerKey:@"tXELD586Hvg0bnDW3ysAHH1wd"
                    consumerSecret:@"0ExKoMALDsaCzX21Hb2Jx4wh4OVAtrWoYMkBIwFHt9TCCYcXJy"];
    
    
    NSString *base64EncodedTokens = @"dFhFTEQ1ODZIdmcwYm5EVzN5c0FISDF3ZDowRXhLb01BTERzYUN6WDIxSGIySng0d2g0T1ZBdHJXb1lNa0JJd0ZIdDlUQ0NZY1hKeQ==";
    [twitterRequest addValue:[NSString stringWithFormat:@"Basic %@", base64EncodedTokens]
          forHTTPHeaderField:@"Authorization"];
    
    
    NSMutableString *contentTypeValue = [NSMutableString stringWithString:@"application/x-www-form-urlencoded"];
    [twitterRequest addValue:contentTypeValue forHTTPHeaderField:@"Content-Type"];
    
    
    
    NSString *s = @"grant_type=client_credentials";
    NSData *bodyData = [s dataUsingEncoding:4 allowLossyConversion:YES];
    
    [twitterRequest addValue:[NSString stringWithFormat:@"%u", (unsigned int)[bodyData length]] forHTTPHeaderField:@"Content-Length"];
    
    [twitterRequest setHTTPBody:bodyData];
    twitterRequest.HTTPShouldHandleCookies = NO;
//-----------------------------------------------------------------------------------------------
    
    NSLog(@"<NSURLRequest %@>", [[twitterRequest URL] absoluteString]);
    NSLog(@"%@", [twitterRequest allHTTPHeaderFields]);
    
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *dataTask = [urlSession
          dataTaskWithRequest:twitterRequest
          completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
              
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
              if (httpResponse.statusCode == 200){
                  
                  NSError *jsonError = nil;
                  id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                  
                  NSString* strToken = [json valueForKey:@"access_token"];
                  [self downloadTwitterFeed:strToken];
              }
              
          }];
    
    [dataTask resume];

    
    
    
    
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:@"tXELD586Hvg0bnDW3ysAHH1wd"
                                consumerSecret:@"0ExKoMALDsaCzX21Hb2Jx4wh4OVAtrWoYMkBIwFHt9TCCYcXJy"];
    
    [twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        [twitter getUserTimelineWithScreenName:@"rt_russian" successBlock:^(NSArray *statuses) {
            
                  self.statuses = statuses;
                  [self.tableView reloadData];
                  
              } errorBlock:^(NSError *error) {
                  
                  NSLog(@"%@", error.debugDescription);
                  
        }];
    }
    errorBlock:^(NSError *error) {
        NSLog(@"%@", error.debugDescription);
    }];
    
    
    self.accountStore = [[ACAccountStore alloc] init];
    
    _consumerKeyTextField = @"PdLBPYUXlhQpt4AguShUIw";
    _consumerSecretTextField = @"drdhGuKSingTbsDLtYpob4m5b5dn1abf9XXYyZKQzk";
    
 //   [self loginOnTheWebAction:nil];
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
    
//    [_twitter getHomeTimelineSinceID:nil count:20
//        successBlock:^(NSArray *statuses) {
//            
//            NSLog(@"statuses: %@", statuses);
//            
//            self.statuses = statuses;
//            
//            [self.tableView reloadData];
//            
//        } errorBlock:^(NSError *error) {}];
//    
    
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
