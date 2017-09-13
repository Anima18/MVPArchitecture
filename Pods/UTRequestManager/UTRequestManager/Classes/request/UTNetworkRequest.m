//
//  UTNetworkRequest.m
//  IOSRequestManager
//
//  Created by jianjianhong on 17/8/1.
//  Copyright © 2017年 Anima18. All rights reserved.
//

#import "UTNetworkRequest.h"
#import "UTRequestParam.h"
#import "UTNetworkingTask.h"
#import "MBProgressHUDUtil.h"
#import "YYModel.h"
#import "DataObject.h"
#import "DataBean.h"
#import "ReactiveObjC.h"
#import "UTError.h"

@interface UTNetworkRequest () <MBProgressHUDDelegate>

/* 请求参数 */
@property(nonatomic, strong) UTRequestParam *requestParam;

/* HUD 显示信息 */
@property(nonatomic, copy) NSString *progressMessage;

/* 网络请求Task */
@property(nonatomic, strong) NSURLSessionDataTask *task;

/* 请求信号 */
@property(nonatomic, weak) RACSignal *signal;

@end

@implementation UTNetworkRequest

-(instancetype)init {
    if (self = [super init])
    {
        _requestParam = [[UTRequestParam alloc] init];
        _progressMessage = @"正在处理中，请稍后...";
        [MBProgressHUDUtil setDelegate:self];
        [MBProgressHUDUtil addRequest:self];
    }
    return self;
}

+ (UTNetworkRequest *)request {
    //UTNetworkRequest *request = [UTNetworkRequest new];
    return [[UTNetworkRequest alloc] init];
}

- (UTNetworkRequest *)url:(NSString *)url {
    _requestParam.url = url;
    return self;
}

- (UTNetworkRequest *)method:(HTTPRequestMethod)method {
    _requestParam.method = method;
    return self;
}

- (UTNetworkRequest *)methodString:(NSString *)method {
    if([@"GET" isEqualToString:method]) {
        _requestParam.method = GET;
    }else if ([@"POST" isEqualToString:method]) {
        _requestParam.method = POST;
    }
    return self;
}

- (UTNetworkRequest *)dataClass:(NSString *)cls {
    _requestParam.cls = cls;
    NSDictionary *dict = @{@"rows" : NSClassFromString(cls)};
    [DataBean setPropertyGenericClass:dict];
    return self;
}

- (UTNetworkRequest *)downloadFilePath:(NSString *)filePath {
    _requestParam.downloadFilePath = filePath;
    return self;
}

- (UTNetworkRequest *)progressMessage:(NSString *)message {
    self.progressMessage = message;
    return self;
}

- (UTNetworkRequest *)addParam:(NSString *)key value:(NSObject *)value {
    _requestParam.param[key] = value;
    return self;
}

-(UTNetworkRequest *)setParam:(NSMutableDictionary *)param {
    _requestParam.param = param;
    return self;
}

- (UTNetworkRequest *)uploadFileParam:(NSMutableDictionary *)fileParam {
    _requestParam.uploadFileParam = fileParam;
    return self;
}

- (void)data:(void(^)(id result))success failure:(void(^)(NSUInteger code, NSString *errorMessage))failure {
    NSError *error = [UTError dataRequestError:_requestParam];
    if(error) {
        failure(error.code, [UTError errorMessage:error]);
        return;
    }
    
    [MBProgressHUDUtil showProgress:self.progressMessage];
    self.task = [UTNetworkingTask dataTask:_requestParam success:^(id result) {
        DataObject *data = [DataObject yy_modelWithJSON:result];
        
        success(data);
        [MBProgressHUDUtil hideProgress];
    } failure:^(NSError *error) {
    
        failure(error.code, [UTError errorMessage:error]);
        [MBProgressHUDUtil hideProgress];
    }];
}

- (void)download:(void (^)(NSString *))success failure:(void (^)(NSUInteger code, NSString *errorMessage))failure {
    NSError *error = [UTError downloadRequestError:_requestParam];
    if(error) {
        failure(error.code, [UTError errorMessage:error]);
        return;
    }
    
    [MBProgressHUDUtil showBarProgress:self.progressMessage details:nil];
    MBProgressHUD *HUD = [MBProgressHUDUtil HUD];
    self.task = [UTNetworkingTask downloadTask:_requestParam progress:^(NSProgress *downloadProgress) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"%@", [NSThread currentThread]);
            if (HUD) {
                
                HUD.progress = downloadProgress.fractionCompleted;
                
                HUD.labelText = [NSString stringWithFormat:@"%2.f%%",downloadProgress.fractionCompleted*100];
                
            }
        });
        
    } completionHandler:^(NSURL *filePath, NSError *error) {
        [MBProgressHUDUtil hideProgress];
        if(error) {
            failure(error.code, [UTError errorMessage:error]);
        }else {
            success(filePath);
        }
    }];

}

- (void)upload:(void (^)(id))success failure:(void (^)(NSUInteger, NSString *))failure {
    NSError *error = [UTError dataRequestError:_requestParam];
    if(error) {
        failure(error.code, [UTError errorMessage:error]);
        return;
    }
    
    [MBProgressHUDUtil showBarProgress:self.progressMessage details:nil];
    MBProgressHUD *HUD = [MBProgressHUDUtil HUD];
    self.task = [UTNetworkingTask uploadTask:_requestParam progress:^(NSProgress *progress) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"%@", [NSThread currentThread]);
            if (HUD) {
                
                HUD.progress = progress.fractionCompleted;
                
                HUD.labelText = [NSString stringWithFormat:@"%2.f%%",progress.fractionCompleted*100];
                
            }
        });
    } completionHandler:^(id responseObject, NSError *error) {
        [MBProgressHUDUtil hideProgress];
        if(error) {
            failure(error.code, [UTError errorMessage:error]);
        }else {
            DataObject *data = [DataObject yy_modelWithJSON:responseObject];
            success(data);
        }
    }];
}


- (UTNetworkRequest *)dataRequest {
    self.signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSError *error = [UTError dataRequestError:_requestParam];
        if(error) {
            [subscriber sendError:error];
        }else {
            [MBProgressHUDUtil showProgress:self.progressMessage];
            self.task = [UTNetworkingTask dataTask:_requestParam success:^(id result) {
                DataObject *data = [DataObject yy_modelWithJSON:result];
                NSDictionary *dict = @{[self description]:data};
                [subscriber sendNext:dict];
                [subscriber sendCompleted];
            } failure:^(NSError *error) {
                [subscriber sendError:error];
                [subscriber sendCompleted];
            }];
            
        }
        return nil;
    }];
    NSLog(@"UTRequest key %@", [self description]);
    return self;
}

- (UTNetworkRequest *)downloadRequest {
    self.signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        NSError *error = [UTError downloadRequestError:_requestParam];
        if(error) {
            [subscriber sendError:error];
        }else {
            [MBProgressHUDUtil showBarProgress:self.progressMessage details:nil];
            MBProgressHUD *HUD = [MBProgressHUDUtil HUD];
            self.task = [UTNetworkingTask downloadTask:_requestParam progress:^(NSProgress *downloadProgress) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    NSLog(@"%@", [NSThread currentThread]);
                    if (HUD) {
                        
                        HUD.progress = downloadProgress.fractionCompleted;
                        
                        HUD.labelText = [NSString stringWithFormat:@"%2.f%%",downloadProgress.fractionCompleted*100];
                        
                    }
                });
                
            } completionHandler:^(NSURL *filePath, NSError *error) {
                if(error) {
                    [subscriber sendError:error];
                }else {
                    NSDictionary *dict = @{[self description]:filePath};
                    [subscriber sendNext:dict];
                }
                [subscriber sendCompleted];
            }];
        }
        
        return nil;
    }];
    
    return self;
}

- (UTNetworkRequest *)uploadRequest {
    self.signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        NSError *error = [UTError dataRequestError:_requestParam];
        if(error) {
            [subscriber sendError:error];
        }else {
            [MBProgressHUDUtil showBarProgress:self.progressMessage details:nil];
            MBProgressHUD *HUD = [MBProgressHUDUtil HUD];
            self.task = [UTNetworkingTask uploadTask:_requestParam progress:^(NSProgress *progress) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    NSLog(@"%@", [NSThread currentThread]);
                    if (HUD) {
                        
                        HUD.progress = progress.fractionCompleted;
                        
                        HUD.labelText = [NSString stringWithFormat:@"%2.f%%",progress.fractionCompleted*100];
                        
                    }
                });
            } completionHandler:^(id responseObject, NSError *error) {
                if(error) {
                    [subscriber sendError:error];
                }else {
                    DataObject *data = [DataObject yy_modelWithJSON:responseObject];
                    NSDictionary *dict = @{[self description]:data};
                    [subscriber sendNext:dict];
                }
                [subscriber sendCompleted];
            }];
        }
        
        return nil;
    }];
    
    return self;
}

- (RACSignal *)signal {
    return _signal;
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    NSArray *requests = [MBProgressHUDUtil requests];
    for (UTNetworkRequest *request in requests) {
        if(request.task) {
            [request.task cancel];
            NSLog(@"cancel task");
        }
    }
    [MBProgressHUDUtil clearRequests];
    
}

@end
