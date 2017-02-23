//
//  TBBSocketServer.m
//  TBBSocketServer
//
//  Created by YiGuo on 2017/2/20.
//  Copyright © 2017年 tbb. All rights reserved.
//

#import "TBBSocketServer.h"
#import "GCDAsyncSocket.h"
@interface TBBSocketServer()<GCDAsyncSocketDelegate>
//为了socket对像不被过早释放定义一个全局的服务Socket
@property (nonatomic ,strong)GCDAsyncSocket *serverSocket;
//同理需要一个客户端Socket
@property (nonatomic ,strong)GCDAsyncSocket *clientSocket;

//保存客户端
@property (nonatomic ,strong)NSMutableArray *clientSockets;
//定义一个打印日志便宜观察是否有客户连接和查看状态
@property (nonatomic ,strong)NSMutableString *log;
@end

@implementation TBBSocketServer
-(id)init{
    if (self = [super init]) {
        self.serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return self;
}
-(NSMutableArray *)clientSockets{
    if (!_clientSockets) {
        _clientSockets = [NSMutableArray new];
    }
    return _clientSockets;
}
-(NSMutableString *)log{
    if (!_log) {
        _log = [NSMutableString string];
    }
    
    return _log;
}
-(void)startListener{
    NSError *err = nil;
    BOOL success = [self.serverSocket acceptOnPort:5200 error:&err];
    if (success) {
        NSLog(@"服务端口5200已开启");
    }else{
        NSLog(@"服务端口开房失败");
    }
}
#pragma mark GCDAsyncSocketDelegate
//有客户连接上端口时调用
-(void)socket:(GCDAsyncSocket *)serverSocket didAcceptNewSocket:(GCDAsyncSocket *)clientSocket{
    
    NSLog(@"%@ IP: %@: %zd 客户端请求连接...",clientSocket,clientSocket.connectedHost,clientSocket.connectedPort);
    // 1.将客户端socket保存起来
    [self.clientSockets addObject:clientSocket];
    
    // 2.一旦同意连接，监听数据读取，如果有数据会调用下面的代理方法
    [clientSocket readDataWithTimeout:-1 tag:0];
    
    // 3.返回 "服务" 选项
    NSMutableString *options = [NSMutableString string];
    [options appendString:@"xxx银行服务系统\n"];
    [options appendString:@"[0]查询\n"];
    [options appendString:@"[1]取款\n"];
    [options appendString:@"[2]转帐\n"];
    [options appendString:@"[3]存钱\n"];
    [options appendString:@"[4]退卡\n"];
    NSData *data = [options dataUsingEncoding:NSUTF8StringEncoding];
    [clientSocket writeData:data withTimeout:-1 tag:0];
}


//发送信息给客户端
-(void)socket:(GCDAsyncSocket *)clientSocket didReadData:(NSData *)data withTag:(long)tag{
    
    // 1.客户端 传递的数据 转成字符串
    NSString *clientStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString *log = [NSString stringWithFormat:@"IP:%@ %zd data:%@\n",clientSocket.connectedHost,clientSocket.connectedPort, clientStr];
    NSLog(@"%@",log);
    [self.log appendString:log];
    [self.log writeToFile:@"/Users/Fung/Desktop/server.log" atomically:NO encoding:NSUTF8StringEncoding error:nil];
    
    NSInteger serverCode = [clientStr integerValue];
    switch (serverCode) {
        case 0:
            [self writeDataWithSocket:clientSocket str:@"你还有xxxxxx\n"];
            break;
        case 1:
            [self writeDataWithSocket:clientSocket str:@"请输入取款金额\n"];
            break;
        case 2:
            [self writeDataWithSocket:clientSocket str:@"请输入转帐金额\n"];
            break;
        case 3:
            [self writeDataWithSocket:clientSocket str:@"请放入存款\n"];
            break;
        case 4:
            [self exitWithSocket:clientSocket];
            break;
            
        default:
            [self writeDataWithSocket:clientSocket str:@"其他\n"];
            break;
    }
    
    // 2.监听数据读取
    [clientSocket readDataWithTimeout:-1 tag:0];
}

//客户端断开连接
-(void)exitWithSocket:(GCDAsyncSocket *)clientSocket{
    [self writeDataWithSocket:clientSocket str:@"成功退出\n"];
    [self.clientSockets removeObject:clientSocket];
    
    NSLog(@"当前在线用户个数:%ld",self.clientSockets.count);
}

#pragma mark -私有方法
#pragma mark -写数据
-(void)writeDataWithSocket:(GCDAsyncSocket *)clientSocket str:(NSString *)str{
    //发送数据
    [clientSocket writeData:[str dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    
}

//数据发送成功时调用
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"数据发送成功..");
}
@end
