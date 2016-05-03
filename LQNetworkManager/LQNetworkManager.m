//
//  LQNetworkManager.m
//  kugou
//
//  Created by liang on 16/5/1.
//  Copyright © 2016年 liang. All rights reserved.
//

#import "LQNetworkManager.h"
#import "AFNetworking.h"

@interface LQNetworkManager()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation LQNetworkManager

#pragma mark - Init
+ (instancetype)sharedManager {
    static LQNetworkManager *manager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _networkConfig = [[LQNetworkConfig alloc] init];
    }
    return self;
}

#pragma mark - Request
- (NSURLSessionDataTask *)getWithPath:(NSString *)path
                            parameters:(id)parameters
                            completion:(LQRequestCompletion)completion {
    return [self requestWithPath:path HTTPMethod:LQHTTPMethodGet parameters:parameters progress:nil completion:completion];
}

- (NSURLSessionDataTask *)getWithPath:(NSString *)path
                           parameters:(id)parameters
                             progress:(void (^)(NSProgress * _Nonnull))progress
                           completion:(LQRequestCompletion)completion {
    return [self requestWithPath:path HTTPMethod:LQHTTPMethodGet parameters:parameters progress:progress completion:completion];
}

- (NSURLSessionDataTask *)postWithPath:(NSString *)path
                            parameters:(id)parameters
                            completion:(LQRequestCompletion)completion {
    return [self requestWithPath:path HTTPMethod:LQHTTPMethodPost parameters:parameters progress:nil completion:completion];

}

- (NSURLSessionDataTask *)requestWithPath:(NSString *)path
                           HTTPMethod:(LQHTTPMethod)HTTPMethod
                           parameters:(id)parameters
                             progress:(void (^)(NSProgress * _Nonnull))progress
                           completion:(LQRequestCompletion)completion {

    NSURLSessionDataTask *task = nil;
    switch (HTTPMethod) {
        case LQHTTPMethodGet:
        {
            task = [self.sessionManager GET:path parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
                
                if (progress) {
                    progress(downloadProgress);
                }
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                [self log:[NSString stringWithFormat:@"========>\n%@ success: %@\n%@", task.currentRequest.HTTPMethod, task.currentRequest.URL, responseObject]];
                completion(responseObject, nil);
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                [self logRequestFail:error];
                completion(nil, error);
                
            }];
            [self log:[NSString stringWithFormat:@"========>\n%@: %@\nparameters:%@", task.currentRequest.HTTPMethod, task.currentRequest.URL, parameters]];
        }
            break;
        case LQHTTPMethodPost:
        {
            task = [self.sessionManager POST:path parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
                
                if (progress) {
                    progress(downloadProgress);
                }
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                [self log:[NSString stringWithFormat:@"========>\n%@ success: %@\n%@", task.currentRequest.HTTPMethod, task.currentRequest.URL, responseObject]];
                completion(responseObject, nil);
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                [self logRequestFail:error];
                completion(nil, error);
            }];
            
            [self log:[NSString stringWithFormat:@"========>\n%@: %@\nparameters:%@", task.currentRequest.HTTPMethod, task.currentRequest.URL, parameters]];
            
        }
            break;
            
        default:
            break;
    }
    
    return task;
}

- (NSURLSessionDownloadTask *)downloadWithPath:(NSString *)path
                                    saveToPath:(NSString *)saveToPath
                                      progress:(void (^)(NSProgress *))progress
                                    completion:(LQRequestCompletion)completion {
    if (!path || path.length<1 || !saveToPath || saveToPath.length<1) {
        return nil;
    }
    
    NSString *absolutePath = path;
    if (self.sessionManager.baseURL) {
        absolutePath = [[NSURL URLWithString:path relativeToURL:self.sessionManager.baseURL] absoluteString];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:absolutePath]];
    
    NSURLSessionDownloadTask *downloadTask = [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        if (progress) {
            progress(downloadProgress);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //Don't use [NSURL URLWithString:]!
        return [NSURL fileURLWithPath:saveToPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        if (!error) {
            [self log:[NSString stringWithFormat:@"========>\nDownload success: %@\nsaveToPath: %@", response.URL, filePath.absoluteString]];
            completion(filePath.absoluteString, nil);
        } else {
            [self log:[NSString stringWithFormat:@"========>\nDownload fail: %@\n: %@", response.URL, error.userInfo]];
            completion(nil, error);
        }
        
    }];
    
    [self log:[NSString stringWithFormat:@"========>\nDownload: %@", downloadTask.currentRequest.URL]];
    [downloadTask resume];
    
    return downloadTask;
}

- (NSURLSessionUploadTask *)uploadFileWithPath:(NSString *)path
                                      fromFile:(NSString *)filePath
                                      progress:(void (^)(NSProgress * _Nonnull))progress
                                    completion:(LQRequestCompletion)completion {
    if (!path || path.length<1 || !filePath || filePath.length<1) {
        return nil;
    }
    
    NSString *absolutePath = path;
    if (self.sessionManager.baseURL) {
        absolutePath = [[NSURL URLWithString:path relativeToURL:self.sessionManager.baseURL] absoluteString];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:absolutePath]];

    NSURLSessionUploadTask *uploadTask = [self.sessionManager uploadTaskWithRequest:request fromFile:[NSURL fileURLWithPath:filePath] progress:^(NSProgress * _Nonnull uploadProgress) {
        
        if (progress) {
            progress(uploadProgress);
        }

    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            [self log:[NSString stringWithFormat:@"========>\nUpload success: %@\n%@", response.URL, responseObject]];
            completion(response, nil);
        } else {
            [self log:[NSString stringWithFormat:@"========>\nUpload fail: %@\n: %@", response.URL, error.userInfo]];
            completion(nil, error);
        }
        
    }];
    
    [self log:[NSString stringWithFormat:@"========>\nUpload file: %@", uploadTask.currentRequest.URL]];
    [uploadTask resume];
    
    return uploadTask;
}

- (NSURLSessionDataTask *)uploadWithImage:(UIImage *)image
                                     path:(NSString *)path
                                     name:(NSString *)name
                                 fileName:(NSString *)fileName
                                 mimeType:(NSString *)mimeType
                               parameters:(NSDictionary *)parameters
                                 progress:(void (^)(NSProgress *))progress
                               completion:(LQRequestCompletion)completion {
    if (!image || !path || path.length<1) {
        return nil;
    }
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);

    if (!fileName) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        fileName = [NSString stringWithFormat:@"image_%@.jpg", str];
    }
    if (!mimeType) {
        mimeType = @"image/jpeg";
    }

    NSURLSessionDataTask *task = [self.sessionManager POST:path parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:imageData name:name fileName:fileName mimeType:mimeType];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        if (progress) {
            progress(uploadProgress);
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self log:[NSString stringWithFormat:@"========>\nUpload success: %@\n%@", task.currentRequest.URL, responseObject]];
        completion(responseObject, nil);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self log:[NSString stringWithFormat:@"========>\nUpload fail: %@\n%@", task.currentRequest.URL, error.userInfo]];
        completion(nil, error);

    }];
    
    [self log:[NSString stringWithFormat:@"========>\nUpload post image: %@\nparameters:%@", task.currentRequest.URL, parameters]];
    
    return task;
}

- (void)cancelAllRequests {
    [self.sessionManager.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cancel];
    }];
}

- (void)cancelRequestWithPath:(NSString *)path {
    if (!path || path.length<1) {
        return;
    }
    
    NSString *absolutePath = path;
    if (self.sessionManager.baseURL) {
        absolutePath = [[NSURL URLWithString:path relativeToURL:self.sessionManager.baseURL] absoluteString];
    }
    
    [self.sessionManager.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj.currentRequest.URL.absoluteString isEqualToString:absolutePath]) {
            [obj cancel];
        }
    }];
}

# pragma mark - Getter
- (AFHTTPSessionManager *)sessionManager {
    if (!_sessionManager) {
        if (self.networkConfig.baseURLString) {
            _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:self.networkConfig.baseURLString]];
        } else {
            _sessionManager = [[AFHTTPSessionManager alloc] init];
        }
        
        switch (self.networkConfig.requestType) {
            case LQRequestSerializeJSON: {
                _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
                break;
            }
            case LQRequestSerializeHTTP: {
                _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
                break;
            }
        }
        
        switch (self.networkConfig.responseType) {
            case LQResponseSerializeJSON: {
                AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
                responseSerializer.removesKeysWithNullValues = self.networkConfig.removesKeysWithNullValues;
                _sessionManager.responseSerializer = responseSerializer;
                break;
            }
            case LQResponseSerializeData: {
                _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
                break;
            }
        }
        
        [self.networkConfig.httpHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [_sessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
        _sessionManager.requestSerializer.timeoutInterval = self.networkConfig.timeoutInterval;
        
    }
    return _sessionManager;
}

# pragma mark - Private
- (void)log:(NSString *)message {
    if (self.networkConfig.debugLogEnable) {
        NSLog(@"%@", message);
    }
}

- (void)logRequestFail:(NSError *)error {
    if (!self.networkConfig.debugLogEnable || !error) {
        return;
    }
    
    NSString *url = [error.userInfo objectForKey:@"NSErrorFailingURLKey"];
    NSString *responseString = nil;
    NSData *data = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (data) {
        responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    [self log:[NSString stringWithFormat:@"========>\nRequest fail: %@\nLocalizedDescription: %@\nResponseErrorData: %@", url, error.localizedDescription, responseString]];
}

@end
