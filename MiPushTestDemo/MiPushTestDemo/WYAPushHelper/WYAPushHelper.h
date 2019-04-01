//
//  WYAPushHelper.h
//  MiPushTestDemo
//
//  Created by 1 on 2019/3/27.
//  Copyright © 2019 weiyian. All rights reserved.
//
#import "MiPushSDK.h"
#define WYAiOSVersion10 ([UIDevice currentDevice].systemVersion.doubleValue >= 10) //10.0以上系统版本号
#define WYAiOSVersion10Below ([UIDevice currentDevice].systemVersion.doubleValue < 10) //10.0以上系统版本号

#import <Foundation/Foundation.h>
#define Push_DeviceToken @"Push_DeviceToken"

NS_ASSUME_NONNULL_BEGIN

typedef void(^MiPushHandleBlock)(NSDictionary * userInfo);
typedef NS_ENUM(NSUInteger, WYAPushSDKType) {
    WYAPushSDKTypeMiPush = 0,// 默认小米推送
    WYAPushSDKTypeJPush,// 极光推送
};

@interface WYAPushHelper : NSObject<
MiPushSDKDelegate,
UNUserNotificationCenterDelegate
>

/**
 选择三方推送平台,暂不开放使用
 */
@property (nonatomic, assign) WYAPushSDKType pushSDK;

/**
 接收到远程消息通知或前台接收到通知消息的回调
 */
@property (nonatomic, copy) MiPushHandleBlock handleBlock;

+ (WYAPushHelper *)shareManager;

/**
 启动检测是否需要rootViewController去处理点击通知后的相关业务逻辑，若无页面跳转需要，可忽略，否则在配置小米推送前设置
 */
+ (void)openCheckRootViewController;

/**
 快速配置小米推送基础设置，默认type:3,connect:NO
 
 @param launchOptions 启动参数，直接由Appdelegate中didFinishLaunching方法直接传入
 */
+ (void)configMiPush:(NSDictionary *)launchOptions;

/**
 配置小米推送基础设置
 
 @param launchOptions 启动参数，直接由Appdelegate中didFinishLaunching方法直接传入
 @param type 通知类型，type 0:none 1:badge 2:sound 3:alert
 @param connect 是否使用长连接，注：在App运行时 ，APNs会提示用户是否接收消息，很多时候，用户会禁止此功能。导致，推送消息无法送达到用户手机。所以使用长连接功能，可以在App运行时，获取消息推送。
 */
+ (void)configMiPush:(NSDictionary *)launchOptions type:(UIRemoteNotificationType)type connect:(BOOL)connect;


/**
 * 绑定 PushDeviceToken
 *
 * NOTE: 有时Apple会重新分配token, 所以为保证消息可达,
 * 必须在系统application:didRegisterForRemoteNotificationsWithDeviceToken:回调中,
 * 重复调用此方法. SDK内部会处理是否重新上传服务器.
 *
 * @param
 *     deviceToken: AppDelegate中,PUSH注册成功后,
 *                  系统回调didRegisterForRemoteNotificationsWithDeviceToken
 */
+ (void)bindDeviceToken:(NSData *)deviceToken;


// 设置别名
+ (void)setAlias:(NSString *)alias;

// 订阅内容
+ (void)subscribe:(NSString *)topic;

// 设置帐号
+ (void)setAccount:(NSString *)account;

@end

NS_ASSUME_NONNULL_END
