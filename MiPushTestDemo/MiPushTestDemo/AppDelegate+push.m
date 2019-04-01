//
//  AppDelegate+push.m
//  MiPushTestDemo
//
//  Created by 李雪峰 on 2019/3/31.
//  Copyright © 2019 weiyian. All rights reserved.
//

#import "AppDelegate+push.h"
#import <objc/message.h>
#import <objc/runtime.h>
@implementation AppDelegate (push)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self appendClassMethod:[self class] methodASel:@selector(getAge:) withMethodBSel:@selector(getNewAge:)];
    });
}

// 为方法A的实现添加方法B
+ (void)appendClassMethod:(Class)anClass methodASel:(SEL)oldSel withMethodBSel:(SEL)newSel{
    
    Class class = self.class;
    Method oldM = class_getInstanceMethod(class, oldSel);
    Method newM = class_getInstanceMethod(class, newSel);
    BOOL didAdd = class_addMethod(class, oldSel, method_getImplementation(newM), method_getTypeEncoding(newM));
    if (didAdd) {
        NSLog(@"swizzleInstanceSel * didAdd");
        class_replaceMethod(class, newSel, method_getImplementation(oldM), method_getTypeEncoding(oldM));
    }
    else {
        NSLog(@"swizzleInstanceSel * didn'tAdd ----> exchange!");
        method_exchangeImplementations(oldM, newM);
    }
    
//    Method oldMethod = class_getInstanceMethod(self.class, oldSel);
//    Method newMethod = class_getInstanceMethod(self.class, newSel);
//    IMP newImp = method_getImplementation(newMethod);
//    BOOL suc = class_addMethod(self.class, oldSel, newImp, method_getTypeEncoding(oldMethod));
//    
//    if (suc) {
//        NSLog(@"添加方法成功了");
//    }
    
}


- (void)getNewAge:(NSInteger)age{
    
    NSLog(@"age = %ld",age + 1);
    
}

- (BOOL)newApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    NSLog(@"wo jieshule ");
    return YES;
    
}


@end
