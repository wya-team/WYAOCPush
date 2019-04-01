//
//  AppDelegate.m
//  MiPushTestDemo
//
//  Created by 1 on 2019/3/27.
//  Copyright © 2019 weiyian. All rights reserved.
//
#import "AppDelegate.h"
#import "WYAPushHelper.h"

@interface AppDelegate ()<
MiPushSDKDelegate,
UNUserNotificationCenterDelegate
>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
/// ----------------------- 需要拷贝的代码 -----------------------
    [self configMiPush:launchOptions];

    return YES;
}

// 配置小米推送
- (void)configMiPush:(NSDictionary *)launchOptions{
    
    // type 0:none 1:badge 2:sound 3:alert
    [MiPushSDK registerMiPush:self type:3 connect:NO];
    
    // 点击通知打开app处理逻辑
    NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(userInfo){
        [self handleReceiveMiPushInfo:userInfo];
    }
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

/// ----------------------- 需要拷贝以上代码 -----------------------


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


/// ------------------- 拷贝以下代码至篇末 -------------------
#pragma mark ------------ 小米远程推送注册成功回调
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // 注册APNS成功, 注册deviceToken
    [MiPushSDK bindDeviceToken:deviceToken];
    
}

- (void)application:( UIApplication *)application didReceiveRemoteNotification:( NSDictionary *)userInfo
{
    [MiPushSDK handleReceiveRemoteNotification:userInfo];
    // 使用此方法后，所有消息会进行去重，然后通过miPushReceiveNotification:回调返回给App
}


#ifdef WYAiOSVersion10
//app内直接接收通知的业务处理
// iOS 10 Support
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    NSLog(@"ios 10 MiPush userInfo = %@",userInfo);
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [MiPushSDK handleReceiveRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionBadge); // 需要执行这个方法，选择是否提醒用户，有 Badge、Sound、Alert 三种类型可以选择设置。
}

//点击通知进入app后的业务处理
// iOS 10 Support
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    NSLog(@"ios 10 MiPush userInfos = %@",userInfo);
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [MiPushSDK handleReceiveRemoteNotification:userInfo];
    }
    
    [self handleReceiveMiPushInfo:userInfo];
    
    completionHandler();  // 系统要求执行这个方法
}

#endif

#ifdef WYAiOSVersion10Below
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSString *messageId = [userInfo objectForKey:@"_id_"];
    [MiPushSDK openAppNotify:messageId];
}
#endif


#pragma mark MiPushSDKDelegate
- (void)miPushRequestSuccWithSelector:(NSString *)selector data:(NSDictionary *)data
{
    // 请求成功
    // 可在此获取regId
    if ([selector isEqualToString:@"bindDeviceToken:"]) {
        NSLog(@"regid = %@", data[@"regid"]);
        NSString * regid = [NSString stringWithFormat:@"%@",data[@"regid"]] ?: @"";
        [[NSUserDefaults standardUserDefaults] setObject:regid forKey:Push_DeviceToken];
    }
}

#pragma mark ----------- 处理点击消息通知事件进入app后的业务逻辑
- (void)handleReceiveMiPushInfo:(NSDictionary *)userInfo{
    
    // 内部业务逻辑处理
#warning 代码
    NSLog(@"收到的通知消息：%@",userInfo);
    
}



@end
