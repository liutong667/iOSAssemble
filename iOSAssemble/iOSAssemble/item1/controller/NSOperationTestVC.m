//
//  NSOperationTestVC.m
//  iOSAssemble
//
//  Created by liutong on 2018/5/29.
//  Copyright © 2018年 liutong. All rights reserved.
//

#import "NSOperationTestVC.h"

@interface LTCustomOperation : NSOperation
@end
@implementation LTCustomOperation
- (void)main {
    NSLog(@"自定义操作 线程 = %@", [NSThread currentThread]);
}
@end

@interface NSOperationTestVC ()

@end

@implementation NSOperationTestVC

/*
使用 NSOperation 的方式有 3 种
1、NSInvocationOperation
2、NSBlockOperation
3、自定义子类继承 NSOperation，实现内部相应的方法
*/

- (void)test1 {
    NSInvocationOperation *invocationOP = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(test1Demo:) object:@{@"msg": @"invocationOperation 基本使用", @"parameter": @"呵呵"}];
    [invocationOP start]; //主线程执行
}

- (void)test2 {
    NSInvocationOperation *invocationOP = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(test1Demo:) object:@{@"msg": @"invocationOperation 基本使用", @"parameter": @"呵呵"}];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:invocationOP]; //子线程执行
}
- (void)test1Demo:(NSDictionary *)para {
     NSLog(@"thread = %@, para = %@", [NSThread currentThread], para);
}

- (void)test3 {
    NSBlockOperation *blockOP = [NSBlockOperation blockOperationWithBlock:^{
       NSLog(@"blockOperation, thread = %@", [NSThread currentThread]);
    }];
//    [blockOP start]; //主线程执行
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:blockOP];
}
- (void)test4 {
    NSBlockOperation *blockOP = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"thread1 = %@", [NSThread currentThread]);
    }];
    [blockOP addExecutionBlock:^{
        NSLog(@"thread2 = %@", [NSThread currentThread]);
    }];
    [blockOP addExecutionBlock:^{
        NSLog(@"thread3 = %@", [NSThread currentThread]);
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:blockOP];
    [blockOP addExecutionBlock:^{
        NSLog(@"thread4 = %@", [NSThread currentThread]);
    }];
}

- (void)test5 {
    LTCustomOperation *ltOP = [[LTCustomOperation alloc] init];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:ltOP];
}

- (void)test6 {
    NSInvocationOperation *invocationOP = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(testDemo6) object:nil];
    [invocationOP setCompletionBlock:^{
        NSLog(@"end invocation thread = %@", [NSThread currentThread]);
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:invocationOP];
}
- (void)testDemo6 {
    NSLog(@"thread1 = %@", [NSThread currentThread]);
}

- (void)test7 {
    NSBlockOperation *blockOP = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"thread1 = %@", [NSThread currentThread]);
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            NSLog(@"thread2 = %@", [NSThread currentThread]);
        }];
        NSLog(@"thread3 = %@", [NSThread currentThread]);
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:blockOP];
}

- (void)test8 {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 2;
    for (int i = 0; i < 10; i++) {
        NSBlockOperation *blOP = [NSBlockOperation blockOperationWithBlock:^{
            [NSThread sleepForTimeInterval:1];
            NSLog(@"thread%i = %@", i, [NSThread currentThread]);
        }];
        [queue addOperation:blOP];
    }
    
    [queue setSuspended:YES];
    [NSThread sleepForTimeInterval:2];
    queue.suspended = NO;
//    [queue cancelAllOperations];
    
}
- (void)test9 {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *blk1OP = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"thread1 = %@", [NSThread currentThread]);
    }];
    NSBlockOperation *blk2OP = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"thread2 = %@", [NSThread currentThread]);
    }];
    NSBlockOperation *blk3OP = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"thread3 = %@", [NSThread currentThread]);
    }];
    
    [blk1OP addDependency:blk3OP];
    [blk2OP addDependency:blk1OP];
    [queue addOperation:blk2OP];
    [queue addOperation:blk3OP];
    [queue addOperation:blk1OP];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self test9];
}

@end
