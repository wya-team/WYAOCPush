//
//  NSObject+runtime.h
//  MiPushTestDemo
//
//  Created by 李雪峰 on 2019/3/31.
//  Copyright © 2019 weiyian. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (runtime)
+ (void)exchangeMethod;

+ (void)appendMethod;
@end

NS_ASSUME_NONNULL_END
