//
//  chatViewController.h
//  sgw_xmpp
//
//  Created by shang on 16/2/26.
//  Copyright © 2016年 shang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "xmppManager.h"

@interface chatViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
//聊天好友的jid
@property (nonatomic, strong)XMPPJID *frienfJid;

@end
