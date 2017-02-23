//
//  main.m
//  Socket模拟银行服务系统
//
//  Created by YiGuo on 2017/2/22.
//  Copyright © 2017年 tbb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBBSocketServer.h"
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // 1.创建服务监听器
        TBBSocketServer *listener = [[TBBSocketServer alloc] init];
        // 2.开始监听
        [listener startListener];
        // 开启主运行循环,否则服务开闭
        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}
