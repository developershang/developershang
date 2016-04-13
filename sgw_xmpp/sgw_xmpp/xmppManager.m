//
//  xmppManager.m
//  sgw_xmpp
//
//  Created by shang on 16/2/25.
//  Copyright © 2016年 shang. All rights reserved.
//

#import "xmppManager.h"

#pragma mark 枚举器枚举连接类型
typedef enum : NSUInteger {
    ConnectPurPoseRegister = 1,
    ConnectPurPoseLogin,
}ConnectPurPose;

//延展 私有属性 .m中实现代理的协议遵守 写一个延展
@interface xmppManager ()<XMPPStreamDelegate,XMPPRosterDelegate,XMPPMessageArchivingStorage>

@property(nonatomic, strong)NSString *registerPassWord;
@property(nonatomic, strong)NSString *loginPassWord;
@property (nonatomic, assign)ConnectPurPose ConnectPurpose;

@end


static xmppManager *manager = nil;


@implementation xmppManager

+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[xmppManager alloc] init];
    });
    return manager;
}




#pragma mark 初始化相关属性
- (instancetype)init{
    
    self = [super init];
    if (self) {
    //通信管道初始化
        self.xmppStream = [[XMPPStream alloc] init];
     
        //花名册数据管理助手
        self.coredata = [XMPPRosterCoreDataStorage sharedInstance];
        
         //初始化花名册
        self.roster = [[XMPPRoster alloc] initWithRosterStorage:_coredata dispatchQueue:dispatch_get_main_queue()];
        //激活通信管道
        [self.roster activate:self.xmppStream];
        
        //添加代理
        
        [self.roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        
    //设置相关参数
        _xmppStream.hostName = kHostName;//这里是绑定对应服务器的ip地址
        _xmppStream.hostPort = kHostPort;//这里是绑定对应服务器的对应的功能端口号
        
        //添加代理 可以添加多个代理 实现代理方法，代理方法主要是关于连接成功与否及其响应问题
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
           XMPPMessageArchivingCoreDataStorage *messageArchiveCoredata = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        
        
        self.messageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:messageArchiveCoredata dispatchQueue:dispatch_get_main_queue()];
       
        //激活通信管道
        [self.messageArchiving activate:self.xmppStream];
        //添加代理
        [self.messageArchiving addDelegate:self delegateQueue:dispatch_get_main_queue()];
        //操作对象 管理助手
        self.context = messageArchiveCoredata.mainThreadManagedObjectContext;
   
    }
    return self;
}

#pragma mark 注册
/*注册用户的实现主要是通过用户名 主机域名 以及对相应的Resource 创建JID 传给通信管道的JID, 然后去连接服务器 如果通信管道是连接着的则断开，否则连接*/
- (void)registWithUserName:(NSString *)name passWord:(NSString *)passWord{
    
    self.ConnectPurpose = ConnectPurPoseRegister;
    self.registerPassWord = passWord;
    self.xmppStream.myJID = [XMPPJID jidWithUser:name domain:kDomin resource:kResource];
    
    if ([self.xmppStream isConnected]) {
        XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable" to:self.xmppStream.myJID];
        [self.xmppStream sendElement:presence];
        [self.xmppStream disconnect];
        
    }
    [self.xmppStream connectWithTimeout:20.f error:nil];
    
  }


#pragma mark 登录
- (void)loadWithuserName:(NSString *)name passWord:(NSString *)passWord{
    
    self.loginPassWord = passWord;
    self.ConnectPurpose = ConnectPurPoseLogin;
    
    XMPPJID *jid = [XMPPJID jidWithUser:name domain:kDomin resource:kResource];
    self.xmppStream.myJID = jid;
    
    if ([self.xmppStream isConnected]) {
        
        XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable" to:self.xmppStream.myJID];
        [self.xmppStream sendElement:presence];
        
        [self.xmppStream disconnect];

    }
    
   NSError *error = nil;
   BOOL connectResult = [self.xmppStream connectWithTimeout:20.f error:&error];
    
    if (!connectResult) {
  
        NSLog(@"链接失败");
        
    }
    
   
    
}

#pragma mark XMPPStream协议方法

// 连接 注册 验证成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSLog(@"连接成功");
    //判断注册于登录
   switch (self.ConnectPurpose) {
        //注册
        case ConnectPurPoseRegister:
            
        {
            NSError *error = nil;
            [self.xmppStream registerWithPassword:self.registerPassWord error:&error];
        break;
        }
        //登录
        case ConnectPurPoseLogin:
        {
            NSError *error = nil;
            [self.xmppStream authenticateWithPassword:self.loginPassWord error:&error];
            if (error) {
                NSLog(@"注册error:");
            }
        break;

        }
        default:
            break;
    }
}
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"完成注册");
}
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"已经完成验证");
    
    //设置用户当前状态为上线（上线 available 下线 unavailable）
   // XMPPPresence *presence = [XMPPPresence presenceWithType:@"available" to:self.xmppStream.myJID];
    XMPPPresence *presence =[XMPPPresence presenceWithType:@"availabel"];
    
    NSLog(@"myjid ===  %@",self.xmppStream.myJID);
    [self.xmppStream sendElement:presence];
}

//连接 注册 验证失败
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    NSLog(@"连接失败");
}
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    NSLog(@"没有完成注册");
}
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    NSLog(@"没有完成验证");
}

//连接超时
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender{
    NSLog(@"连接超时");
}





#pragma mark 接收到好友请求

-(void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    
    NSLog(@"接收到好友请求");
    
}



@end
