//
//  TBBSocketServer.h
//  TBBSocketServer
//
//  Created by YiGuo on 2017/2/20.
//  Copyright © 2017年 tbb. All rights reserved.
//
/**
 调试说明：
   再终端中输入 telnet ip 端口号(项目中定义的端口号) 如： telnet 192.168.0.401 5200
 */
#import <Foundation/Foundation.h>

@interface TBBSocketServer : NSObject
//开始服务监听是否有客户访问
-(void)startListener;
@end
