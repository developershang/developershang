//
//  loadViewController.m
//  sgw_xmpp
//
//  Created by lanou3g on 16/2/25.
//  Copyright © 2016年 sgw. All rights reserved.
//

#import "loadViewController.h"
#import "xmppManager.h"
#import "MyViewController.h"
@interface loadViewController ()<XMPPStreamDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *UserName;
@property (weak, nonatomic) IBOutlet UITextField *UserPassWord;

@end

@implementation loadViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [[xmppManager shareInstance].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    
    // Do any additional setup after loading the view.
}


#pragma mark 注册成功
/*
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    
    NSLog(@"注册成功，自动登录");
    [[xmppManager shareInstance]loginWithuserName:self.UserName.text passWord:self.UserPassWord.text];
    MyViewController *mvc = [[MyViewController alloc] init];
    [self.navigationController pushViewController:mvc animated:YES];
 
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)RegisterButton:(UIButton *)sender {
    
    NSLog(@"注册");
    
    NSString *name = self.UserName.text;
    NSString *passWord = self.UserPassWord.text;
    [[xmppManager shareInstance] registWithUserName:name passWord:passWord];
    
}








/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
