//
//  UIImage+Swizzle.m
//  MiPushTestDemo
//
//  Created by 李雪峰 on 2019/3/31.
//  Copyright © 2019 weiyian. All rights reserved.
//

#import "UIImage+Swizzle.h"
#import <objc/message.h>
#import <objc/runtime.h>
@implementation UIImage (Swizzle)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        [self swizzleInstanceSel:@selector(init) withNewSel:@selector(qq_init)];
        [self swizzleInstanceSel:@selector(getAge:) withNewSel:@selector(getNewAge:)];
    });
}

- (void)getAge:(NSInteger)age{
    
    NSLog(@"age = %ld",age);
    
}

- (void)getNewAge:(NSInteger)age{
    
    NSLog(@"age = %ld",age + 1);
    
}


+ (void)swizzleInstanceSel:(SEL)oldSel withNewSel:(SEL)newSel {
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

}

- (instancetype)qq_init {
    NSLog(@"自定义的qq_init方法 - %s", __func__);
    return [self qq_init];
}

@end
