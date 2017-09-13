//
//  LoginPresenter.h
//  MVPDemo
//
//  Created by jianjianhong on 17/9/13.
//  Copyright © 2017年 jianjianhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginViewProtocol.h"

@interface LoginPresenter : NSObject

/* delegate */
@property(nonatomic, weak) id <LoginViewProtocol> delegate;

- (void)loginWithName:(NSString *)username password:(NSString *)password;

@end
