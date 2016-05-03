//
//  LQNetworkManager.h
//  kugou
//
//  Created by liang on 16/5/1.
//  Copyright © 2016年 liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LQNetworkConfig.h"

typedef void (^LQRequestCompletion)(id responseObject, NSError *error);

typedef NS_ENUM(NSUInteger, LQHTTPMethod) {
    LQHTTPMethodGet,
    LQHTTPMethodPost
};


@interface LQNetworkManager : NSObject

@property (nonatomic, strong) LQNetworkConfig *networkConfig;

+ (instancetype)sharedManager;

- (NSURLSessionDataTask *)getWithPath:(NSString *)path
                           parameters:(id)parameters
                           completion:(LQRequestCompletion)completion;

- (NSURLSessionDataTask *)postWithPath:(NSString *)path
                           parameters:(id)parameters
                           completion:(LQRequestCompletion)completion;

- (NSURLSessionDownloadTask *)downloadWithPath:(NSString *)path
                                    saveToPath:(NSString *)saveToPath
                                      progress:(void (^)(NSProgress *progress))progress
                                    completion:(LQRequestCompletion)completion;

- (NSURLSessionUploadTask *)uploadFileWithPath:(NSString *)path
                                      fromFile:(NSString *)filePath
                                      progress:(void (^)(NSProgress *progress))progress
                                    completion:(LQRequestCompletion)completion;

- (NSURLSessionDataTask *)uploadWithImage:(UIImage *)image
                                     path:(NSString *)path
                                     name:(NSString *)name
                                 fileName:(NSString *)fileName
                                 mimeType:(NSString *)mimeType
                               parameters:(NSDictionary*)parameters
                                 progress:(void (^)(NSProgress *progress))progress
                               completion:(LQRequestCompletion)completion;

- (void)cancelAllRequests;

- (void)cancelRequestWithPath:(NSString *)path;

@end
