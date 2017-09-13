//
//  LoginViewProtocol.h
//  MVPDemo
//
//  Created by jianjianhong on 17/9/13.
//  Copyright © 2017年 jianjianhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LoginViewProtocol <NSObject>

@required
- (void)loginSuccess;

- (void)loginFail:(NSString *)message;

@end
