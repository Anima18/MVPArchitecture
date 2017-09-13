//
//  UTNetworkRequestManager.h
//
//  Created by jianjianhong on 17/8/9.
//
//  UTNetworkRequestManager是执行多个网络请求的管理器，提供嵌套请求、顺序请求和并发请求功能。
//  UTNetworkRequestManager只能执行多个同种类型请求，比如多个嵌套请求或者顺序请求，而不能同时执行嵌套和顺序请求。

#import <Foundation/Foundation.h>
@class UTNetworkRequest;

@interface UTNetworkRequestManager : NSObject


/**
 创建一个请求管理器

 @param request UTNetworkRequest
 @return UTNetworkRequestManager
 */
+ (UTNetworkRequestManager *)managerWithRequest:(UTNetworkRequest *)request;


/**
 添加嵌套请求

 @param block
 @return UTNetworkRequestManager
 */
- (UTNetworkRequestManager *)nest:(id (^)(id value))block;


/**
 添加顺序请求

 @param request UTNetworkRequest
 @return UTNetworkRequestManager
 */
- (UTNetworkRequestManager *)sequence:(UTNetworkRequest *)request;


/**
 添加并发请求

 @param request UTNetworkRequest
 @return UTNetworkRequestManager
 */
- (UTNetworkRequestManager *)merge:(UTNetworkRequest *)request;


/**
 嵌套请求的成功和失败回调

 @param success 成功回调
 @param failure 失败回调
 */
- (void)nestSuccess:(void(^)(id result))success failure:(void(^)(NSUInteger code, NSString *errorMessage))failure;

/**
 顺序请求的成功和失败回调
 
 @param success 成功回调
 @param failure 失败回调
 */
- (void)sequenceSuccess:(void(^)(NSArray *resultList))success failure:(void(^)(NSUInteger code, NSString *errorMessage))failure;

/**
 并发请求的成功和失败回调
 
 @param success 成功回调
 @param failure 失败回调
 */
- (void)mergeSuccess:(void(^)(NSArray *resultList))success failure:(void(^)(NSUInteger code, NSString *errorMessage))failure;
@end
