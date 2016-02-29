//
//  RegisterViewController.m
//  sgw_xmpp
//
//  Created by lanou3g on 16/2/25.
//  Copyright © 2016年 sgw. All rights reserved.
//

#import "RegisterViewController.h"
#import "xmppManager.h"
#import "MyViewController.h"
#import "XMPPFramework.h"
@interface RegisterViewController ()<XMPPStreamDelegate,UITextFieldDelegate>



@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[xmppManager shareInstance].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.zhanghao.delegate = self;
    self.passed.delegate = self;
    
    //五中文本属性
    //self.zhanghao.text
    self.zhanghao.textColor = [UIColor blackColor];
    self.zhanghao.textAlignment = NSTextAlignmentLeft;
    self.zhanghao.font = [UIFont systemFontOfSize:16];
    self.zhanghao.placeholder = @"请输入账号";
    
    
    //7中控制属性
    self.passed.enabled = YES;
    self.passed.clearsOnBeginEditing = YES;
    self.passed.secureTextEntry = YES;
           //关于键盘的属性
    self.passed.keyboardType = UIKeyboardTypeAlphabet;
    self.passed.returnKeyType = UIReturnKeyDone;
//    self.passed.inputView = nil;
//    self.passed.inputAccessoryView = nil;

    
    //6种外观属性
    self.passed.borderStyle = UITextBorderStyleRoundedRect;
    self.passed.clearButtonMode = UITextFieldViewModeAlways;
//    self.passed.leftView = nil;
//    self.passed.leftViewMode = UITextFieldViewModeAlways;
//    self.passed.rightView = nil;
//    self.passed.rightViewMode = UITextFieldViewModeAlways;
    
    
    
    // Do any additional setup after loading the view.
}

#pragma mark 验证成功

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    
    MyViewController *mvc = [[MyViewController alloc] init];
    [self.navigationController pushViewController:mvc animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)Register:(UIButton *)sender {
   
    NSLog(@"注册");
    NSString *name = self.zhanghao.text;
    NSString *passWord = self.passed.text;
    [[xmppManager shareInstance] registWithUserName:name passWord:passWord];

}

- (IBAction)loadButton:(UIButton *)sender {
    
    NSLog(@"登录");
    NSString *name = self.zhanghao.text;
    NSString *passWord = self.passed.text;

    [[xmppManager shareInstance]loadWithuserName:name passWord:passWord];
    [self.zhanghao resignFirstResponder];
    [self.passed resignFirstResponder];
 
  
    
}


#pragma mark 实现代理方法

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    
    UIAlertController *alertontroller = [UIAlertController alertControllerWithTitle:@"提示" message:@"您使用的用户已注册,请重新注册" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    
    [alertontroller addAction:action];
    
    [self presentViewController:alertontroller animated:YES completion:nil];
}



- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    UIAlertController *alertontroller = [UIAlertController alertControllerWithTitle:@"提示" message:@"该用户不存在" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    
    [alertontroller addAction:action];
    
    [self presentViewController:alertontroller animated:YES completion:nil];
    
    
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
  
    NSLog(@"注销第一响应者");
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
 
    return YES;
}



@end
