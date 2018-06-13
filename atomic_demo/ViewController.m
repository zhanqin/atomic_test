//
//  ViewController.m
//  atomic_demo
//
//  Created by zhanqin on 2018/6/13.
//  Copyright © 2018年 zhanqin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property(atomic,strong) NSMutableArray * amArray;
@property(nonatomic,strong) NSMutableArray * nmArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [self atomicArrayTest];
}

-(void)atomicArrayTest{
    self.amArray = [NSMutableArray arrayWithCapacity:0];
    /**
     1、线程a先执行完，再执行线程b的话，程序不会崩溃
     2、先执行线程b，使用forin循环直接读的话不会崩溃，使用objectAtIndex取值会崩溃
     3、线程a和线程b交错执行，有可能会导致崩溃，打印的数据可能每次不一样，数组的数据越多差异越明显
     4、数组中的数据越多，情况3出现的概率越大，可在打印中搜索hahah，不能保证个数为100000
     */
    /**
     2018-06-13 10:52:31.758715+0800 property_demo[3794:85894] write start time == 1528858351.758641
     2018-06-13 10:52:31.758715+0800 property_demo[3794:85891] read start time == 1528858351.758656
     2018-06-13 10:53:27.592425+0800 property_demo[3794:85894] write end time == 1528858407.592403
     2018-06-13 10:53:27.592641+0800 property_demo[3794:85894] 写入完毕啦！
     2018-06-13 10:53:27.601891+0800 property_demo[3794:85891] *** Terminating app due to uncaught exception 'NSRangeException', reason: '*** -[__NSArrayM objectAtIndex:]: index 0 beyond bounds for empty array'
     *** First throw call stack:
     (
     0   CoreFoundation                      0x000000010329c1e6 __exceptionPreprocess + 294
     1   libobjc.A.dylib                     0x0000000102931031 objc_exception_throw + 48
     2   CoreFoundation                      0x00000001032dc0bc _CFThrowFormattedException + 194
     3   CoreFoundation                      0x00000001031cbe76 -[__NSArrayM objectAtIndex:] + 150
     4   property_demo                       0x000000010202cbef __33-[ViewController atomicArrayTest]_block_invoke.129 + 175
     5   libdispatch.dylib                   0x0000000106c77807 _dispatch_call_block_and_release + 12
     6   libdispatch.dylib                   0x0000000106c78848 _dispatch_client_callout + 8
     7   libdispatch.dylib                   0x0000000106c7eb35 _dispatch_continuation_pop + 967
     8   libdispatch.dylib                   0x0000000106c7cfb0 _dispatch_async_redirect_invoke + 780
     9   libdispatch.dylib                   0x0000000106c843c8 _dispatch_root_queue_drain + 664
     10  libdispatch.dylib                   0x0000000106c840d2 _dispatch_worker_thread3 + 132
     11  libsystem_pthread.dylib             0x00000001071a3169 _pthread_wqthread + 1387
     12  libsystem_pthread.dylib             0x00000001071a2be9 start_wqthread + 13
     )
     libc++abi.dylib: terminating with uncaught exception of type NSException
     */
    dispatch_queue_t queue = dispatch_queue_create("a", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        //1528859151.576267
        
        NSLog(@"write start time == %f",[[NSDate date] timeIntervalSince1970]);
        for (int i = 0; i < 30; i ++) {
            [self.amArray addObject:[NSNumber numberWithInt:i]];
            NSLog(@"a在写");
            NSLog(@"a thread === %@",[NSThread currentThread]);
        }
        //1528859151.585689
        NSLog(@"write end time == %f",[[NSDate date] timeIntervalSince1970]);
        NSLog(@"写入完毕啦！");
    });
    dispatch_async(queue, ^{
        //1528859151.576312
        NSLog(@"read start time == %f",[[NSDate date] timeIntervalSince1970]);
        for (int i = 0; i < 30; i ++) {
            int value = [[self.amArray objectAtIndex:i] intValue];
            NSLog(@"===== hahah %d",value);
            NSLog(@"b thread === %@",[NSThread currentThread]);
        }
        //1528859169.674744
        NSLog(@"read end time == %f",[[NSDate date] timeIntervalSince1970]);
    });
    dispatch_async(queue, ^{
        for (int i = 30; i < 60; i ++) {
            [self.amArray addObject:[NSNumber numberWithInt:i]];
            NSLog(@"c在写");
            NSLog(@"c thread === %@",[NSThread currentThread]);
        }
    });
    
}

-(void)nonatomicArrayTest{
    self.nmArray = [NSMutableArray arrayWithCapacity:0];
    /**
     1、线程a先执行完，再执行线程b的话，程序不会崩溃
     2、先执行线程b，使用forin循环直接读的话不会崩溃，使用objectAtIndex取值会崩溃
     3、线程a和线程b交错执行，有可能会导致崩溃，打印的数据可能每次不一样，数组的数据越多差异越明显
     4、数组中的数据越多，情况3出现的概率越大，可在打印中搜索hahah，不能保证个数为100000
     */
    /**
     崩溃信息
     2018-06-13 11:01:16.627844+0800 property_demo[3985:94229] read start time == 1528858876.627809
     2018-06-13 11:01:16.627845+0800 property_demo[3985:94232] write start time == 1528858876.627801
     2018-06-13 11:01:22.477352+0800 property_demo[3985:94229] *** Terminating app due to uncaught exception 'NSRangeException', reason: '*** -[__NSArrayM objectAtIndex:]: index 0 beyond bounds for empty array'
     *** First throw call stack:
     (
     0   CoreFoundation                      0x0000000105e9f1e6 __exceptionPreprocess + 294
     1   libobjc.A.dylib                     0x0000000105534031 objc_exception_throw + 48
     2   CoreFoundation                      0x0000000105edf0bc _CFThrowFormattedException + 194
     3   CoreFoundation                      0x0000000105dcee76 -[__NSArrayM objectAtIndex:] + 150
     4   property_demo                       0x0000000104c2fbff __36-[ViewController nonatomicArrayTest]_block_invoke.150 + 175
     5   libdispatch.dylib                   0x0000000109919807 _dispatch_call_block_and_release + 12
     6   libdispatch.dylib                   0x000000010991a848 _dispatch_client_callout + 8
     7   libdispatch.dylib                   0x0000000109920b35 _dispatch_continuation_pop + 967
     8   libdispatch.dylib                   0x000000010991efb0 _dispatch_async_redirect_invoke + 780
     9   libdispatch.dylib                   0x00000001099263c8 _dispatch_root_queue_drain + 664
     10  libdispatch.dylib                   0x00000001099260d2 _dispatch_worker_thread3 + 132
     11  libsystem_pthread.dylib             0x0000000109e45169 _pthread_wqthread + 1387
     12  libsystem_pthread.dylib             0x0000000109e44be9 start_wqthread + 13
     )
     libc++abi.dylib: terminating with uncaught exception of type NSException
     */
    //    dispatch_async(dispatch_queue_create("a", DISPATCH_QUEUE_CONCURRENT), ^{
    //        //1528858567.145988
    //        NSLog(@"write start time == %f",[[NSDate date] timeIntervalSince1970]);
    //        for (int i = 0; i < 100000; i ++) {
    //            [self.nmArray addObject:[NSNumber numberWithInt:i]];
    //        }
    //        //528858567.153905
    //        NSLog(@"write end time == %f",[[NSDate date] timeIntervalSince1970]);
    //        NSLog(@"写入完毕啦！");
    //    });
    //    dispatch_async(dispatch_queue_create("b", DISPATCH_QUEUE_CONCURRENT), ^{
    //        //1528858567.145998
    //        NSLog(@"read start time == %f",[[NSDate date] timeIntervalSince1970]);
    //        for (int i = 0; i < 100000; i ++) {
    //            int value = [[self.nmArray objectAtIndex:i] intValue];
    //            NSLog(@"===== hahah %d",value);
    //        }
    //        //1528858584.884774
    //        NSLog(@"read end time == %f",[[NSDate date] timeIntervalSince1970]);
    //    });
    dispatch_async(dispatch_queue_create("a", DISPATCH_QUEUE_CONCURRENT), ^{
        //1528859151.576267
        
        NSLog(@"write start time == %f",[[NSDate date] timeIntervalSince1970]);
        for (int i = 0; i < 30; i ++) {
            [self.nmArray addObject:[NSNumber numberWithInt:i]];
            NSLog(@"a在写");
            NSLog(@"a thread === %@",[NSThread currentThread]);
        }
        //1528859151.585689
        NSLog(@"write end time == %f",[[NSDate date] timeIntervalSince1970]);
        NSLog(@"写入完毕啦！");
    });
    dispatch_async(dispatch_queue_create("a", DISPATCH_QUEUE_CONCURRENT), ^{
        //1528859151.576312
        NSLog(@"read start time == %f",[[NSDate date] timeIntervalSince1970]);
        for (int i = 0; i < 30; i ++) {
            int value = [[self.nmArray objectAtIndex:i] intValue];
            NSLog(@"===== hahah %d",value);
            NSLog(@"b thread === %@",[NSThread currentThread]);
        }
        //1528859169.674744
        NSLog(@"read end time == %f",[[NSDate date] timeIntervalSince1970]);
    });
    dispatch_async(dispatch_queue_create("a", DISPATCH_QUEUE_CONCURRENT), ^{
        for (int i = 30; i < 60; i ++) {
            [self.nmArray addObject:[NSNumber numberWithInt:i]];
            NSLog(@"c在写");
            NSLog(@"c thread === %@",[NSThread currentThread]);
        }
    });
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
