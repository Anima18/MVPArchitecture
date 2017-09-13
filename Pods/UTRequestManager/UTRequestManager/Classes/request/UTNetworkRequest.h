//  UTNetworkRequest.h
//  Created by jianjianhong on 17/8/1.
//  Copyright © 2017年 Anima18. All rights reserved.
//
//  UTNetworkRequest是所有单一网络请求的入口，通过设置请求数据可以发送获取数据、下载文件、上传文件请求。
//  一个UTNetworkRequest代表着一个网络请求

@import UIKit;
#import "UTNetworkRequestDefine.h"
@class RACSignal;
@class RACDisposable;

@interface UTNetworkRequest : NSObject

/**
 创建UTNetworkRequest的静态方法

 @return UTNetworkRequest
 */
+ (UTNetworkRequest *)request;

/**
 设置请求url

 @param url
 @return UTNetworkRequest
 */
- (UTNetworkRequest *)url:(NSString *)url;

/**
 设置请求类型，POST或者GET

 @param method
 @return UTNetworkRequest
 */
- (UTNetworkRequest *)method:(HTTPRequestMethod)method;

/**
 设置请求类型，“POST”或者“GET”

 @param method
 @return UTNetworkRequest
 */
- (UTNetworkRequest *)methodString:(NSString *)method;

/**
 设置请求返回数据的类型

 @param cls
 @return UTNetworkRequest
 */
- (UTNetworkRequest *)dataClass:(NSString *)cls;

/**
 设置下载文件的路径

 @param filePath
 @return UTNetworkRequest
 */
- (UTNetworkRequest *)downloadFilePath:(NSString *)filePath;

/**
 设置请求loading提示信息

 @param message
 @return UTNetworkRequest
 */
- (UTNetworkRequest *)progressMessage:(NSString *)message;

/**
 设置一个请求参数

 @param key
 @param value
 @return UTNetworkRequest
 */
- (UTNetworkRequest *)addParam:(NSString *)key value:(NSObject *)value;

/**
 设置请求的所有参数

 @param param
 @return UTNetworkRequest
 */
- (UTNetworkRequest *)setParam:(NSMutableDictionary *)param;

/**
 设置文件上传参数

 @param fileParam
 @return UTNetworkRequest
 */
- (UTNetworkRequest *)uploadFileParam:(NSMutableDictionary *)fileParam;

/**
 执行数据请求，对服务数据序列化，并调用成功或失败回调

 @param success 成功回调，result是返回的请求数据
 @param failure 失败回调，code是错误码，errorMessage是错误信息
 */
- (void)data:(void(^)(id result))success failure:(void(^)(NSUInteger code, NSString *errorMessage))failure;

/**
 执行文件下载请求，对服务数据序列化，并调用成功或失败回调

 @param success 成功回调，filePath是文件成功下载的路径
 @param failure 失败回调，code是错误码，errorMessage是错误信息
 */
- (void)download:(void(^)(NSString* filePath))success failure:(void(^)(NSUInteger code, NSString *errorMessage))failure;

/**
 执行文件上传请求，对服务数据序列化，并调用成功或失败回调

 @param success 成功回调，result是返回的请求数据
 @param failure 失败回调，code是错误码，errorMessage是错误信息
 */
- (void)upload:(void(^)(id result))success failure:(void(^)(NSUInteger code, NSString *errorMessage))failure;

/**
 创建一个数据请求的信号，交给UTNetworkRequestManager调度

 @return UTNetworkRequest
 */
- (UTNetworkRequest *)dataRequest;

/**
 创建一个下载请求的信号，交给UTNetworkRequestManager调度
 
 @return UTNetworkRequest
 */
- (UTNetworkRequest *)downloadRequest;

/**
 创建一个上传请求的信号，交给UTNetworkRequestManager调度
 
 @return UTNetworkRequest
 */
- (UTNetworkRequest *)uploadRequest;

/**
 获取当前请求信号

 @return RACSignal
 */
- (RACSignal *)signal;

@end
