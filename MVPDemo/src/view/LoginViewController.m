//
//  ViewController.m
//  MVPDemo
//
//  Created by jianjianhong on 17/9/13.
//  Copyright © 2017年 jianjianhong. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginViewProtocol.h"
#import "LoginPresenter.h"
#import "MainViewController.h"

@interface LoginViewController () <LoginViewProtocol>

/* presenter */
@property(nonatomic, strong) LoginPresenter *presenter;

@property (weak, nonatomic) IBOutlet UITextField *userNameField;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.presenter = [LoginPresenter new];
    _presenter.delegate = self;
    
    self.navigationItem.title = @"登录";
    
}

- (IBAction)login:(id)sender {
    NSString *userName = _userNameField.text;
    NSString *password = _passwordField.text;
    
    [_presenter loginWithName:userName password:password];
}

- (void)loginSuccess {
    NSLog(@"loginSuccess");
    
    UIViewController *vc = [MainViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loginFail:(NSString *)message {
    NSLog(@"%@", message);
    UIAlertController * uia = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * okaction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
    }];
    [uia addAction:okaction];
    [self presentViewController:uia animated:YES completion:nil];
}

@end
