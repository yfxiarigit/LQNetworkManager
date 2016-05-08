//
//  DemoViewController.m
//  LQNetworkManagerDemo
//
//  Created by liang on 16/5/3.
//  Copyright © 2016年 liang. All rights reserved.
//

#import "DemoViewController.h"
#import "LQNetworkManager.h"

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *method = cell.textLabel.text;
    if (method && method.length>0) {
        SEL selector = NSSelectorFromString(method);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:selector];
#pragma clang diagnostic pop
    }
}

- (void)Get {
//    [[LQNetworkManager sharedManager] getWithPath:@"/headers" parameters:nil completion:^(id responseObject, NSError *error) {
//    }];
    
    [[LQNetworkManager sharedManager] getWithPath:@"/get" parameters:@{@"show_env":@1} completion:^(id responseObject, NSError *error) {
    }];
}

- (void)Post {
    NSDictionary *parameters = @{@"name": @"LQ"};
    [[LQNetworkManager sharedManager] postWithPath:@"post" parameters:parameters completion:^(id responseObject, NSError *error) {
    }];
    
//    NSDictionary *parameters = @{@"user": @"user", @"passwd": @"passwd"};
//    [[LQNetworkManager sharedManager] postWithPath:@"/basic-auth/user/passwd" parameters:parameters completion:^(id responseObject, NSError *error) {
//    }];
}

- (void)UploadImage {
    LQNetworkConfig *config = [[LQNetworkConfig alloc] initWithBaseURLString:@"https://httpbin.org"];
    config.responseType = LQResponseSerializeData;
    [LQNetworkManager sharedManager].networkConfig = config;

    NSString *path = [[NSBundle mainBundle] pathForResource:@"singer" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    NSDictionary *parameters = @{@"isTest":@"False", @"version":@"how-old.net"};
    [[LQNetworkManager sharedManager] uploadWithImage:image path:@"http://how-old.net/Home/Analyze" name:@"Image" parameters:parameters progress:^(NSProgress *progress) {
        
        NSLog(@"Upload progress:%f, completedBytes:%lld, totalBytes:%lld", progress.fractionCompleted, progress.completedUnitCount, progress.totalUnitCount);
        
    } completion:^(id responseObject, NSError *error) {
        
    }];
}

- (void)Download {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/test.png"];
    [[LQNetworkManager sharedManager] downloadWithPath:@"image/png" saveToPath:path progress:^(NSProgress *progress) {
        
        NSLog(@"progress:%f, completedBytes:%lld, totalBytes:%lld", progress.fractionCompleted, progress.completedUnitCount, progress.totalUnitCount);
        
    } completion:^(id responseObject, NSError *error) {
        
    }];
}

- (void)Cancel {
    NSURLSessionDataTask *task = [[LQNetworkManager sharedManager] getWithPath:@"/get" parameters:@{@"show_env":@1} completion:^(id responseObject, NSError *error) {
    }];
    
    [[LQNetworkManager sharedManager] cancelRequestWithPath:task.currentRequest.URL.absoluteString];
}

- (void)CancelAll {
    [self Get];
    [self Post];
    [self Download];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[LQNetworkManager sharedManager] cancelAllRequests];;
    });
}


@end
