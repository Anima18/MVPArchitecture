//
//  UTNetworkRequestManager.m
//  Pods
//
//  Created by jianjianhong on 17/8/9.
//
//

#import "UTNetworkRequestManager.h"
#import "ReactiveObjC.h"
#import "UTNetworkRequest.h"
#import "MBProgressHUDUtil.h"
#import "UTError.h"

@interface UTNetworkRequestManager ()

/* request list */
@property(nonatomic, strong) NSMutableArray *requestList;
/* 信号 */
@property(nonatomic, weak) RACSignal *signal;

@end

@implementation UTNetworkRequestManager

-(instancetype)init {
    if (self = [super init])
    {
        self.requestList = [NSMutableArray new];
    }
    return self;
}

+ (UTNetworkRequestManager *)managerWithRequest:(UTNetworkRequest *)request {
    UTNetworkRequestManager *manager = [UTNetworkRequestManager new];
    manager.signal = [request signal];
    [manager.requestList addObject:request];
    return manager;
}

- (UTNetworkRequestManager *)nest:(id (^)(id))block {
    _signal = [_signal flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        UTNetworkRequest *request = block(value);
        [_requestList addObject:request];
        return [request signal];
    }];
    return self;
}

- (UTNetworkRequestManager *)sequence:(UTNetworkRequest *)request {
    _signal = [_signal concat:[request signal]];
    [_requestList addObject:request];
    return self;
}

- (UTNetworkRequestManager *)merge:(UTNetworkRequest *)request {
    _signal = [_signal merge:[request signal]];
    [_requestList addObject:request];
    return self;
}

- (void)nestSuccess:(void (^)(id))success failure:(void (^)(NSUInteger, NSString *))failure {
    RACDisposable *disposable = [_signal subscribeNext:^(id  _Nullable x) {
        NSDictionary *dataDict = x;
        for(UTNetworkRequest *request in _requestList) {
            id result = [dataDict objectForKey:[request description]];
            if(result) {
                success(result);
            }
        }
    } error:^(NSError * _Nullable error) {
        failure(error.code, [UTError errorMessage:error]);
    } completed:^{
        NSLog(@"UTNetworkRequestManager subscribe completed");
        [MBProgressHUDUtil hideProgress];
    }];
}

- (void)sequenceSuccess:(void (^)(NSArray *))success failure:(void (^)(NSUInteger, NSString *))failure {
    NSMutableArray *resultList = [NSMutableArray arrayWithCapacity:[_requestList count]];
    
    RACDisposable *disposable = [_signal subscribeNext:^(id  _Nullable x) {
        
        NSDictionary *dataDict = x;
        for(UTNetworkRequest *request in _requestList) {
            id result = [dataDict objectForKey:[request description]];
            if(result) {
                [resultList addObject:result];
            }
        }
        
        if([resultList count] == [_requestList count]) {
            success(resultList);
        }
        
    } error:^(NSError * _Nullable error) {
        failure(error.code, [UTError errorMessage:error]);
        [MBProgressHUDUtil hideProgress];
    } completed:^{
        NSLog(@"UTNetworkRequestManager subscribe completed");
        [MBProgressHUDUtil hideProgress];
    }];
}

- (void)mergeSuccess:(void (^)(NSArray *))success failure:(void (^)(NSUInteger, NSString *))failure {
    __block NSInteger disposeCount = 0;
    NSMutableArray *resultList = [NSMutableArray arrayWithCapacity:[_requestList count]];
    for (NSInteger i = 0; i < [_requestList count]; i++) {
        [resultList addObject:[NSNull null]];
    }
    
    RACDisposable *disposable = [_signal subscribeNext:^(id  _Nullable x) {
        NSDictionary *dataDict = x;
        for(NSInteger i = 0; i < [_requestList count]; i++) {
            UTNetworkRequest *request = _requestList[i];
            id result = [dataDict objectForKey:[request description]];
            if(result) {
                [resultList replaceObjectAtIndex:i withObject:result];
                disposeCount++;
                break;
            }
        }
        
        if(disposeCount == [_requestList count]) {
            success(resultList);
        }
        
    } error:^(NSError * _Nullable error) {
        failure(error.code, [UTError errorMessage:error]);
        [MBProgressHUDUtil hideProgress];
    } completed:^{
        NSLog(@"UTNetworkRequestManager subscribe completed");
        [MBProgressHUDUtil hideProgress];
    }];
}

@end
