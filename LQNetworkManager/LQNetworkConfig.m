//
//  LQNetworkConfig.m
//  kugou
//
//  Created by liang on 16/5/2.
//  Copyright © 2016年 liang. All rights reserved.
//

#import "LQNetworkConfig.h"

@implementation LQNetworkConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _timeoutInterval = 60.0;
        _removesKeysWithNullValues = YES;
        _requestType = LQRequestSerializeHTTP;
        _responseType = LQResponseSerializeJSON;
#ifdef DEBUG
        _debugLogEnable = YES;
#else
        _debugLogEnable = NO;
#endif
    }
    
    return self;
}

@end
