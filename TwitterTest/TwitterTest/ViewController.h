//
//  ViewController.h
//  TwitterTest
//
//  Created by Konstantin on 25.12.17.
//  Copyright © 2017 KONSTATIN MAXIMOV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource>

@property (nonatomic, strong) NSArray *statuses;

@property (nonatomic, weak) IBOutlet UITextField *nameTwitter;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

