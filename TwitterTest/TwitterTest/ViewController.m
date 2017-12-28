//
//  ViewController.m
//  TwitterTest
//
//  Created by Konstantin on 25.12.17.
//  Copyright © 2017 KONSTATIN MAXIMOV. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@end

NSString *consumerKeyText    = @"tXELD586Hvg0bnDW3ysAHH1wd";
NSString *consumerSecretText = @"0ExKoMALDsaCzX21Hb2Jx4wh4OVAtrWoYMkBIwFHt9TCCYcXJy";


@implementation ViewController{
    NSString* strToken;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self authentication];
    _nameTwitter.userInteractionEnabled = NO;
    _nameTwitter.text =  @"channelone_rus";
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _nameTwitter) {
        [textField resignFirstResponder];
        self.statuses = nil;
        [self.tableView reloadData];

        [self downloadTwitterFeed:strToken nameAccount:_nameTwitter.text];

        return NO;
    }
    return YES;
}

- (void)authentication
{
    NSURL *twitterURL = [NSURL URLWithString:@"https://api.twitter.com/oauth2/token"];
    NSMutableURLRequest *twitterRequest = [NSMutableURLRequest requestWithURL:twitterURL];
    [twitterRequest setHTTPMethod:@"POST"];
    
    NSString *base64EncodedTokens =
    [self base64EncodedBearerTokenCredentialsWithConsumerKey:consumerKeyText
                                              consumerSecret:consumerSecretText];
    
    [twitterRequest addValue:[NSString stringWithFormat:@"Basic %@", base64EncodedTokens]
          forHTTPHeaderField:@"Authorization"];
    
    NSMutableString *contentTypeValue = [NSMutableString stringWithString:@"application/x-www-form-urlencoded"];
    [twitterRequest addValue:contentTypeValue forHTTPHeaderField:@"Content-Type"];
    
    NSString *str = @"grant_type=client_credentials";
    NSData *bodyData = [str dataUsingEncoding:4 allowLossyConversion:YES];
    
    [twitterRequest addValue:[NSString stringWithFormat:@"%u", (unsigned int)[bodyData length]] forHTTPHeaderField:@"Content-Length"];
    
    [twitterRequest setHTTPBody:bodyData];
    twitterRequest.HTTPShouldHandleCookies = NO;
    
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *dataTask = [urlSession
          dataTaskWithRequest:twitterRequest
          completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
              
              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
              if (httpResponse.statusCode == 200){
                  
                  NSError *jsonError = nil;
                  id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                  
                   strToken = [json valueForKey:@"access_token"];
                  [self downloadTwitterFeed:strToken nameAccount:_nameTwitter.text];
              }
          }];
    
    [dataTask resume];
}

- (void)downloadTwitterFeed:(NSString *)strTwitterToken nameAccount:(NSString *)nameTwitterAccount
{
    _nameTwitter.userInteractionEnabled = NO;

    NSURL *twitterURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/user_timeline.json?include_entities=true&include_rts=true&screen_name=%@&count=20", nameTwitterAccount]];
    
    NSMutableURLRequest *twitterRequest = [NSMutableURLRequest requestWithURL:twitterURL];
    [twitterRequest setHTTPMethod:@"GET"];
    
    [twitterRequest addValue:[NSString stringWithFormat:@"Bearer %@", strTwitterToken] forHTTPHeaderField:@"Authorization"];
    
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *dataTask = [urlSession
      dataTaskWithRequest:twitterRequest
      completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
          
          _nameTwitter.userInteractionEnabled = YES;

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

- (NSString *)base64EncodedBearerTokenCredentialsWithConsumerKey:(NSString *)consumerKey
                                                  consumerSecret:(NSString *)consumerSecret {
    
    NSString *encodedConsumerToken = [consumerKey stringByAddingPercentEncodingWithAllowedCharacters:
                                      [NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *encodedConsumerSecret = [consumerSecret stringByAddingPercentEncodingWithAllowedCharacters:
                                       [NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *bearerTokenCredentials = [NSString stringWithFormat:@"%@:%@", encodedConsumerToken, encodedConsumerSecret];
    
    NSData *data = [bearerTokenCredentials dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
