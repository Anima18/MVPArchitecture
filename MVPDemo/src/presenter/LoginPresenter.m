//
//  LoginPresenter.m
//  MVPDemo
//
//  Created by jianjianhong on 17/9/13.
//  Copyright © 2017年 jianjianhong. All rights reserved.
//

#import "LoginPresenter.h"
#import "User.h"
#import "LoginInteractor.h"
#import <UTRequestManager/UTRequestManager.h>

@interface LoginPresenter ()
/* interactor */
@property(nonatomic, strong) LoginInteractor *interactor;
@end

@implementation LoginPresenter

- (void)loginWithName:(NSString *)username password:(NSString *)password {
    
    if([username isEqualToString:@""]) {
        [_delegate loginFail:@"用户名不能为空"];
    }else if([password isEqualToString:@""]) {
        [_delegate loginFail:@"密码不能为空"];
    }else {
        NSString *url = @"http://192.168.60.176:8080/webService/userInfo/loginUser.action";
        
        [[[[[[[UTNetworkRequest request] url:url] method:POST] dataClass:@"User"] addParam:@"userName" value:username] addParam:@"password" value:password] data:^(id result) {
            DataObject *data = result;
            if([data.data.rows count] > 0) {
                [_interactor saveUser:data.data.rows[0]];
                [_delegate loginSuccess];
            }else {
                [_delegate loginFail:@"用户名和密码出错"];
            }
            
        } failure:^(NSUInteger code, NSString *errorMessage) {
            [_delegate loginFail:errorMessage];
        }];
        
    }
    
}

@end
