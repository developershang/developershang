//
//  RootView.m
//  sgw_xmpp
//
//  Created by lanou3g on 16/2/25.
//  Copyright © 2016年 sgw. All rights reserved.
//

#import "RootView.h"

@implementation RootView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


- (void)setup{
    self.backgroundColor = [UIColor cyanColor];
    self.table  = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    self.table.backgroundColor = [UIColor cyanColor];
    [self addSubview:self.table];
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
