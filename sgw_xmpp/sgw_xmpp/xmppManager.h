//
//  xmppManager.h
//  sgw_xmpp
//
//  Created by lanou3g on 16/2/25.
//  Copyright © 2016年 sgw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

@interface xmppManager : NSObject

#pragma mark 通信管道 连接服务器和客户端的管道
@property(nonatomic, strong)XMPPStream *xmppStream;
#pragma mark 好友花名册
@property (nonatomic, strong)XMPPRoster *roster;

@property (nonatomic, strong) XMPPRosterCoreDataStorage *coredata ;
#pragma mark 聊天消息
@property (nonatomic, strong)XMPPMessageArchiving *messageArchiving;

//被管理对象上下文
@property (nonatomic, strong)NSManagedObjectContext *context;

#pragma mark 单例管理类
+(instancetype)shareInstance;


#pragma mark 注册用户
- (void)registWithUserName:(NSString *)name
                  passWord:(NSString *)passWord;


#pragma mark 登录用户
- (void)loadWithuserName:(NSString *)name
                passWord:(NSString *)passWord;


@end
