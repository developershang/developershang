//
//  chatViewController.m
//  sgw_xmpp
//
//  Created by shang on 16/2/26.
//  Copyright © 2016年 shang. All rights reserved.
//

#import "chatViewController.h"
#import "xmppManager.h"
@interface chatViewController ()<UITableViewDataSource, UITableViewDelegate,XMPPStreamDelegate,UITextFieldDelegate>

@property (nonatomic, strong)NSMutableArray *messageArray;


@end

@implementation chatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.table.delegate = self;
    self.table.dataSource = self;
    
    self.messageTextField.delegate = self;
    
    
    //允许输入,并且默认是可以弹出键盘的
    self.messageTextField.enabled = YES;
   //设置弹出键盘的格式
    self.messageTextField.keyboardType = UIKeyboardTypeDefault;
    //设置键盘右下角得到按钮类型
    self.messageTextField.returnKeyType = UIReturnKeyDefault;

    
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSLog( @"jid === %@",self.frienfJid);
    self.messageArray = [NSMutableArray array];
    //添加代理
    [[xmppManager shareInstance].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
   
    //查询聊天记录
    [self searchMesage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // Do any additional setup after loading the view.
}


- (void)keyboardWillShow:(NSNotification *)note{
    
    CGRect keyboardBounds;
    
    [[note.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardBounds];
    
    NSNumber *duration = [note.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curave = [note.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
   CGFloat keyboardHeight =  keyboardBounds.size.height;

    
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        
        NSLog(@"视图的位置向上移动键盘高度");
        
        
        
        
    }];
    
    
    
    
    
}

- (void)keyboardWillHide:(NSNotification *)note{
    
    CGRect keyboardBounds;
    NSNumber *duration = [note.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curave = [note.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    CGFloat keyboardHeight =  keyboardBounds.size.height;
    
    
    [UIView animateWithDuration:0.2 animations:^{
        
        NSLog(@"视图的位置恢复原来的位置");
        
    }];

}



#pragma mark  -  协议方法


#pragma mark 接受消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
   
    NSLog(@"接受消息");
    //消息发送成功， 查询新的聊天信息
    
    [self searchMesage];
}

#pragma mark 消息发送成功
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    NSLog(@"发送成功");
    [self searchMesage];
    
}

#pragma mark 消息发送失败
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error{
    NSLog(@"发送失败");
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)searchMesage{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:[xmppManager shareInstance].context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND bareJidStr == %@ ",[xmppManager shareInstance].xmppStream.myJID.bare ,self.frienfJid];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[xmppManager shareInstance].context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        
        NSLog(@"查询失败: %@",error);
        
        
    }
    //清空聊天记录
    [self.messageArray removeAllObjects];
    //添加聊天记录
    [self.messageArray addObjectsFromArray:fetchedObjects];
     [self.table reloadData];
   
    if (self.messageArray.count > 0 ) {
        
     NSIndexPath *indexpath = [NSIndexPath indexPathForRow:self.messageArray.count - 1 inSection:0];

    [self.table scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionBottom animated:YES]; 
    }
    
 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"main_cell" forIndexPath:indexPath];
    XMPPMessageArchiving_Message_CoreDataObject *message = self.messageArray[indexPath.row];
    

    if (message.isOutgoing) {
        //发出的消息
        cell.textLabel.backgroundColor = [UIColor cyanColor];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.detailTextLabel.hidden = YES;
        cell.textLabel.hidden = NO;
        
        cell.textLabel.text =[NSString stringWithFormat:@"我 : %@",message.body];
      
        
    }else {
        //接收到的消息
        cell.detailTextLabel.backgroundColor = [UIColor greenColor];
        cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
        cell.detailTextLabel.hidden = NO;
        cell.textLabel.hidden = YES;
        cell.detailTextLabel.text =[NSString stringWithFormat:@"%@ : %@",message.bareJid.user,message.body];
    }
    
    
    return cell;
    
    
}

- (IBAction)sendBUttons:(UIButton *)sender {
   
    //创建消息对象
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.frienfJid];
    
    //message添加body体， 设置消息类容
    [message addBody:self.messageTextField.text];
    
    //发送消息
    [[xmppManager shareInstance].xmppStream sendElement:message];
       NSLog(@"发送消息 %@",self.messageTextField.text);
    

}


/*
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    NSLog(@"开始编辑了");
//    CGFloat offset = 216.0;
//    [UIView animateWithDuration:0.2 animations:^{
//     
//     CGRect frame = self.table.frame;
//     frame.origin.y = -offset;
//     self.table.frame = frame;
//     
//     
//     
// }];
//  
    
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    NSLog(@"开始编辑了");
    CGFloat offset = 146.0;
    
 {
    [UIView animateWithDuration:0.2 animations:^{
        
        CGRect frame = self.table.frame;
        frame.origin.y = - offset;
        self.view.frame = frame;
        
    }];
     
     
     
      }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    CGFloat offset = 146.0;
    
    {
        [UIView animateWithDuration:0.2 animations:^{
            
            CGRect frame = self.table.frame;
            frame.origin.y = 0.0;
            self.view.frame = frame;
            
        }];
    }
    
    
    
    return YES;
}
*/



@end
