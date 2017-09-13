//
//  LoginInteractor.h
//  MVPDemo
//
//  Created by jianjianhong on 17/9/13.
//  Copyright © 2017年 jianjianhong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class User;

@interface LoginInteractor : NSObject

- (void)saveUser:(User *)user;

@end
