//
//  MyViewController.m
//  sgw_xmpp
//
//  Created by shang on 16/2/25.
//  Copyright © 2016年 shang. All rights reserved.
//

#import "MyViewController.h"
#import "xmppManager.h"
#import "chatViewController.h"
@interface MyViewController ()<UITableViewDataSource, UITableViewDelegate,XMPPRosterDelegate, XMPPRoomStorage>

@property(nonatomic, strong)NSMutableArray *fridendsArray;


@end

@implementation MyViewController


- (void)loadView{
    [super loadView];
    [self addView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"main_cell"];
    UIBarButtonItem *rightItem  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction)];
   self.navigationItem.rightBarButtonItem = rightItem;
   
    self.fridendsArray = [NSMutableArray array];
    
    
   [[xmppManager shareInstance].roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    

}



#pragma mark 接收到好友请求
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{

    
    //接收好友请求
    NSLog(@"接收好友请求");
    XMPPJID *jid = presence.from;
    //判断是否是好友
    if ([[xmppManager shareInstance].coredata userExistsWithJID:jid xmppStream:[xmppManager shareInstance].xmppStream]) {
        NSLog(@"已经是好友");
        return;
        
    }
    else{
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"%@想加你为好友",jid.user] preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [[xmppManager shareInstance].roster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
        }];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
          [[xmppManager shareInstance].roster rejectPresenceSubscriptionRequestFrom:jid];
        }];
        
        [controller addAction:action];
        [controller addAction:action1];
        [self presentViewController:controller animated:YES completion:nil];
    
    }
    
}


#pragma mark 检索
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender{
    NSLog(@"开始检索");
}
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender{
    NSLog(@"检索结束");
    
}


#pragma mark 检索出好友
-(void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item{
    
    NSString *jidStr = [[item attributeForName:@"jid"] stringValue];
    
    //获取jid 转换成jid
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    if ([self.fridendsArray containsObject:jid]) {
        return;
    }

    [self.fridendsArray addObject:jid];
    
    [self.table reloadData];
    
    
    
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.fridendsArray.count;
    
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"main_cell" forIndexPath:indexPath];
    XMPPJID *jid = self.fridendsArray[indexPath.row];
    cell.textLabel.text =jid.user;
    return cell;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addView{
    self.view.backgroundColor = [UIColor cyanColor];
    self.table  = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    self.table.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:self.table];

}



- (void)addAction{
  
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"添加好友" message:@"请输入好友名称" preferredStyle:UIAlertControllerStyleAlert];
    
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入好友id";
    }];
    

    //按钮
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //获取好友名字
        NSString *name = controller.textFields.firstObject.text;
 
        XMPPJID *jid = [XMPPJID jidWithUser:name domain:kDomin resource:kResource];
        
        [[xmppManager shareInstance].roster subscribePresenceToUser:jid];
    }];
    

    [controller addAction:action];

    [self presentViewController:controller animated:YES completion:nil];
    
}






- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
    //根据标记获取storyBoard 根据标记获取创建的控制器
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    chatViewController *chat = [storyboard instantiateViewControllerWithIdentifier:@"chat"];
    
    XMPPJID *jid = self.fridendsArray[indexPath.row];
    chat.frienfJid = jid;
    
   [self.navigationController pushViewController:chat animated:YES];

    
    
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UITableViewCell *cell = sender;
    //获取其indexPath
    NSIndexPath *indexPath = [self.table indexPathForCell:cell];
  
    // UITableViewCell *cell = [self.table cellForRowAtIndexPath:indexPath];
    
    XMPPJID *jid = self.fridendsArray[indexPath.row];
    
//    chatViewController *chatVC =  [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"chat"];
    
    chatViewController *chatVc = segue.destinationViewController;
    chatVc.frienfJid = jid;
    
    
    
    
}
*/

@end
