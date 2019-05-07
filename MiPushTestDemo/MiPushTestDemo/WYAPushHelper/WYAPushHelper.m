//
//  WYAPushHelper.m
//  MiPushTestDemo
//
//  Created by 1 on 2019/3/27.
//  Copyright © 2019 weiyian. All rights reserved.
//
#import "WYAPushHelper.h"
static WYAPushHelper *_shareInfo = nil;

@interface WYAPushHelper ()

/**
 是否需要检测根控制器是否已被初始化完成，去进行点击通知进入app完成相关逻辑处理（不需要，则可进行本地存储或者其他与控制器无关的逻辑处理）
 */
@property (nonatomic, assign) BOOL needCheckRootViewController;

/**
 是否有后台消息通知，程序被杀死后，点击通知栏消息时判断是否需要处理该条消息内容，并进行相关业务处理
 */
@property (nonatomic, assign) BOOL isExistNotification;

/**
 记录被点击的通知栏消息内容
 */
@property (nonatomic, strong) NSDictionary * existNotiDictionary;

@end
@implementation WYAPushHelper

+ (WYAPushHelper *)shareManager{
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _shareInfo = [[self alloc] init];
    });
    return _shareInfo;
    
}

+ (void)configMiPush:(NSDictionary *)launchOptions{
    // type 0:none 1:badge 2:sound 3:alert
    [MiPushSDK registerMiPush:[self shareManager] type:3 connect:NO];
}

//配置小米推送
+ (void)configMiPush:(NSDictionary *)launchOptions type:(UIRemoteNotificationType)type connect:(BOOL)connect{
    
    // 处理app被关闭后，点击通知跳转至目标页面。若需求无需处理跳转逻辑，可忽略
    if ([self shareManager].isExistNotification) {
        [[self shareManager] handleReceiveMiPushInfo:[self shareManager].existNotiDictionary];
        [self shareManager].isExistNotification = NO;
    }
    
    // type 0:none 1:badge 2:sound 3:alert
    [MiPushSDK registerMiPush:[self shareManager] type:type connect:connect];
    
    // 点击通知打开app处理逻辑
    NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(userInfo){
        [[self shareManager] handleReceiveMiPushInfo:userInfo];
    }
    
}

+ (void)openCheckRootViewController{
    [self shareManager].needCheckRootViewController = YES;
}

// 设置别名
+ (void)setAlias:(NSString *)alias{
    [MiPushSDK setAlias:alias];
}

// 订阅内容
+ (void)subscribe:(NSString *)topic{
    [MiPushSDK subscribe:topic];
}

// 设置帐号
+ (void)setAccount:(NSString *)account{
    [MiPushSDK subscribe:account];
}

#pragma mark ------------ UIApplicationDelegate，小米远程推送注册成功回调
+ (void)bindDeviceToken:(NSData *)deviceToken{
    // 注册APNS成功, 注册deviceToken
    [MiPushSDK bindDeviceToken:deviceToken];
}

- (void)application:( UIApplication *)application didReceiveRemoteNotification:( NSDictionary *)userInfo
{
    [MiPushSDK handleReceiveRemoteNotification :userInfo];
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
    
    // 程序被杀死后点击推送消息处理
    if (self.needCheckRootViewController && [UIApplication sharedApplication].delegate.window.rootViewController == nil) {
        self.isExistNotification = YES;
        self.existNotiDictionary = userInfo;
        return;
    }
    
    if ([self handleBlock]) {
        self.handleBlock(userInfo);
    }
    
}


@end
