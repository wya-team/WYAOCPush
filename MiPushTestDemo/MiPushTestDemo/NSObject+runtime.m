//
//  NSObject+runtime.m
//  MiPushTestDemo
//
//  Created by 李雪峰 on 2019/3/31.
//  Copyright © 2019 weiyian. All rights reserved.
//
#import "AppDelegate.h"

#import "NSObject+runtime.h"
#import <objc/message.h>
#import <objc/runtime.h>
@implementation NSObject (runtime)
+ (void)exchangeMethod{
    
    [AppDelegate exchangeInstanceMethod:[self class] methodASel:@selector(application:didFinishLaunchingWithOptions:) methodBSel:@selector(newapplication:didFinishLaunchingWithOptions:)];
    
}


+ (void)appendMethod{
    
    [AppDelegate appendClassMethod:[self class] methodASel:@selector(application:didFinishLaunchingWithOptions:) withMethodBSel:@selector(newapplication:didFinishLaunchingWithOptions:)];
    
}

- (BOOL)newapplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"2");
    return YES;
}


+ (void)exchangeClassMethod:(Class)anClass methodASel:(SEL)methodASel methodBSel:(SEL)methodBSel{
    
    Method methodA = class_getClassMethod(anClass, methodASel);
    Method methodB = class_getClassMethod(anClass, methodBSel);
    method_exchangeImplementations(methodA, methodB);
    
}

+ (void)exchangeInstanceMethod:(Class)anClass methodASel:(SEL)methodASel methodBSel:(SEL)methodBSel{
    
    Method methodA = class_getInstanceMethod(anClass, methodASel);
    Method methodB = class_getInstanceMethod(anClass, methodBSel);
    method_exchangeImplementations(methodA, methodB);
    
}

// 为方法A的实现添加方法B
+ (void)appendClassMethod:(Class)anClass methodASel:(SEL)methodASel withMethodBSel:(SEL)methodBSel{
    
    IMP impB = class_getMethodImplementation(anClass, methodBSel);
    class_addMethod(anClass, methodASel, impB, "v@:@");
    
}

@end
