//
//  GCDTestController.m
//  iOSAssemble
//
//  Created by liutong on 2018/5/6.
//  Copyright © 2018年 liutong. All rights reserved.
//

#import "GCDTestController.h"

@interface GCDTestController ()
{
    dispatch_source_t timer;
}
@end

@implementation GCDTestController

#pragma mark - 3.1 gcd简介
- (void)test1 {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        /*长时间处理操作（数据库访问、数据读写、AR用画像识别等）
         */
        [self doWork1];
        dispatch_async(dispatch_get_main_queue(), ^{
            /*回到主线程
             */
            [self doneWork1];
        });
    });
}
- (void)doWork1 {
    NSLog(@"当前线程--%@",[NSThread currentThread]);
}
- (void)doneWork1 {
    NSLog(@"当前线程--%@",[NSThread currentThread]);
}

#pragma mark -
- (void)test2 {
    [self performSelectorInBackground:@selector(doWork2) withObject:nil];
}
- (void)doWork2 {
    NSLog(@"当前线程--%@",[NSThread currentThread]);
    [self performSelectorOnMainThread:@selector(doneWork2) withObject:nil waitUntilDone:YES];
    NSLog(@"doWork have done");
}
- (void)doneWork2 {
    NSLog(@"当前线程--%@",[NSThread currentThread]);
}

#pragma mark - 3.2 gcd 的 API
#pragma mark - dispatch queue
- (void)test3 {
    //serial dispatch queue 创建方法
    dispatch_queue_t mySerialDispatchQueue = dispatch_queue_create("mySerialQueue", NULL);
    // Main Dispatch Queue 获取方法
    dispatch_queue_t mainDispatchQueue = dispatch_get_main_queue();
    //concurent dispatch queue 创建方法
    dispatch_queue_t myConcurrentDispatchQueue = dispatch_queue_create("myConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    //global dispatch queue 获取方法
    dispatch_queue_t globalDispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(myConcurrentDispatchQueue, ^{
        
    });
}
#pragma mark - dispatch_set_target_queue
- (void)test4 {
    dispatch_queue_t mySerialQueue = dispatch_queue_create("mySerialQueue", NULL);
    dispatch_queue_t myBackgroundSerialQueue = dispatch_queue_create("myBackgroundSerialQueue", NULL);
    dispatch_queue_t globalBackgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_set_target_queue(myBackgroundSerialQueue, globalBackgroundQueue);
    
    dispatch_async(myBackgroundSerialQueue, ^{
        NSLog(@"background线程任务1%@",[NSThread currentThread]);
    });
    dispatch_async(myBackgroundSerialQueue, ^{
        NSLog(@"background线程任务2%@",[NSThread currentThread]);
    });
    dispatch_async(mySerialQueue, ^{
        NSLog(@"default线程%@",[NSThread currentThread]);
    });
}
- (void)test5 {
    dispatch_queue_t mySerialQueue1 = dispatch_queue_create("mySerialQueue1", NULL);
    dispatch_queue_t mySerialQueue2 = dispatch_queue_create("mySerialQueue2", NULL);
    dispatch_queue_t mySerialQueue3 = dispatch_queue_create("mySerialQueue3", NULL);
    //那么原本应并行执行的多个serial queue在目标serial queue上只能同时执行一个处理
    dispatch_set_target_queue(mySerialQueue2, mySerialQueue1);
    //    dispatch_set_target_queue(mySerialQueue3, mySerialQueue1);
    dispatch_async(mySerialQueue1, ^{
        NSLog(@"queue1上的任务,线程%@",[NSThread currentThread]);
    });
    dispatch_async(mySerialQueue2, ^{
        NSLog(@"queue2上的任务,线程%@",[NSThread currentThread]);
    });
    dispatch_async(mySerialQueue3, ^{
        NSLog(@"queue3上的任务,线程%@",[NSThread currentThread]);
    });
}
#pragma mark - dispatch_after
- (void)test6 {
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 3*NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        
    });
    //等价
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
    });
}
#pragma mark - Dispatch Group
- (void)test7 {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, globalQueue, ^{
        NSLog(@"1");
    });
    dispatch_group_async(group, globalQueue, ^{
        NSLog(@"2");
    });
    dispatch_group_async(group, globalQueue, ^{
        NSLog(@"3");
    });
    dispatch_group_notify(group, globalQueue, ^{
        NSLog(@"done");
    });
    //    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
    //        NSLog(@"done");
    //    });
}
- (void)test8 {
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, globalQueue, ^{
        NSLog(@"1");
    });
    dispatch_group_async(group, globalQueue, ^{
        NSLog(@"2");
    });
    dispatch_group_async(group, globalQueue, ^{
        NSLog(@"3");
    });
    //    long result = dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    long result = dispatch_group_wait(group, 0.5 * NSEC_PER_SEC);//会阻塞当前线程，该函数处于调用的状态而不返回
    if (result==0) {
        NSLog(@"all have done");
    } else {
        NSLog(@"all not have done");
    }
}
#pragma mark - dispatch_barrier_async
- (void)test9 {
    __block int index = 0;
    //static int index = 0;
    void (^readingBlock)(void) = ^() {
        NSLog(@"reading---%d",index);
    };
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, readingBlock);
    dispatch_async(globalQueue, readingBlock);
    dispatch_async(globalQueue, readingBlock);
    dispatch_async(globalQueue, readingBlock);
    dispatch_async(globalQueue, readingBlock);
    dispatch_barrier_async(globalQueue, ^{
        index = 1;
    });
    dispatch_async(globalQueue, readingBlock);
    dispatch_async(globalQueue, readingBlock);
    dispatch_async(globalQueue, readingBlock);
    
}
#pragma mark - dispatch_sync
/*
 dispatch_async 就是将指定的block“非同步”地追加到指定的dispatch queue中，该函数不做任何等待
 dispatch_sync 就是讲指定的block“同步”地追加到指定的dispatch queue中，在追加的block结束之前，该函数会一直等待，即阻塞改线程
 注意：同步函数，如果所在线程是serial一定会死锁，所在线程是concurrent则在该线程执行block，不开启新线程。
 */
- (void)test10 {
    /*
     假设这种情况：执行Main Dispatch Queue时，使用另外的线程Global Dispatch Queue进行处理，处理结束后立即使用所得到的结果。这种情况下就要使用dispatch_sync函数
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        __block int result = 0;
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            result = 1;
            NSLog(@"%@---",[NSThread currentThread]);
        });
        NSLog(@"global queue执行后的结果result = %d",result);
    });
    //一旦调用dispatch_sync函数，那么在指定的处理执行结束之前，该函数不会返回。可以说是简易版的dispatch_group_wait函数。但也容易引起问题，即死锁
    
    //    ///1、死锁
    //    dispatch_sync(dispatch_get_main_queue(), ^{
    //        NSLog(@"hello");
    //    });
    //    NSLog(@"world");
    
    //    //2、死锁
    //    dispatch_queue_t queue = dispatch_get_main_queue();
    //    dispatch_async(queue, ^{
    //        dispatch_sync(dispatch_get_main_queue(), ^{
    //            NSLog(@"hello");
    //        });
    //    });
    //    NSLog(@"world");
    
    //3、死锁
    dispatch_queue_t serialQueue = dispatch_queue_create("mySerialQueue", 0);
    dispatch_queue_t concurrentQueue = dispatch_queue_create("myConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);//使用该线程则不会死锁
    dispatch_async(serialQueue, ^{
        dispatch_sync(concurrentQueue, ^{
            NSLog(@"hello--%@",[NSThread currentThread]);
        });
        NSLog(@"world-%@",[NSThread currentThread]);
    });
}
- (void)test10_1 {
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"0---%@",[NSThread currentThread]);
    });
    dispatch_sync(dispatch_queue_create("myConcurrentQueue", DISPATCH_QUEUE_CONCURRENT), ^{
        NSLog(@"1---%@",[NSThread currentThread]);
    });
    dispatch_sync(dispatch_queue_create("mySerialQueue", 0), ^{
        NSLog(@"2---%@",[NSThread currentThread]);
    });dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"3---%@",[NSThread currentThread]);
    });
}
#pragma mark - dispatch_apply
- (void)test11 {
    //    // 崩溃
    //    dispatch_apply(10, dispatch_get_main_queue(), ^(size_t index) {
    //        NSLog(@"%zu",index);
    //    });
    /// dispatch_apply函数会等待全部处理执行结束，因此上面的代码会死锁
    //dispatch_apply函数与dipatch_sync函数相同，会等待处理执行结束
    dispatch_apply(10, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t index) {
        NSLog(@"%zu----%@",index,[NSThread currentThread]);
    });
    NSLog(@"done");
    
    NSArray *array = @[@(1),@(2),@(3),@(4),@(5),@(6),@(7),@(8),@(9),];
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        dispatch_apply(array.count, globalQueue, ^(size_t index) {
            NSLog(@"%@--------%@",array[index],[NSThread currentThread]);
        });
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"done");
        });
    });
}
#pragma mark - dispatch_suspend、dispatch_resume
#pragma mark - Dispatch Semaphore
- (void)test12 {
//    ///下面代码很大可能执行时由于内存错误导致应用程序异常结束
//    NSMutableArray *array = [NSMutableArray array];
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    for (int i = 0; i < 1000; i++) {
//        dispatch_async(queue, ^{
//            [array addObject:@(i)];
//        });
//    }
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i =0; i<1000; i++) {
        dispatch_async(globalQueue, ^{
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            [array addObject:@(i)];
            NSLog(@"----%d,%@",i,[NSThread currentThread]);
            dispatch_semaphore_signal(semaphore);
        });
    }
}
#pragma mark - dispatch_once
- (void)test13 {
    static int initialized = NO;
    if (initialized == NO) {
        /*初始化操作
         */
        initialized = YES;
    }
    
    ///上面代码等价于
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
    });
}
#pragma mark - Dispatch Source
- (void)test14 {
    static int count = 100;
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if (count > 0) {
            NSLog(@"----%i",count--);
        }
    });
    dispatch_source_set_cancel_handler(timer, ^{
        NSLog(@"timer cancle");
    });
    dispatch_resume(timer);
}
#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self test10_1];
    
}
- (void)dealloc {
    NSLog(@"%s---dealloc",__func__);
    dispatch_source_cancel(timer);
}
@end

