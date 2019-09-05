//
//  DryWeibo.h
//  DryWeibo
//
//  Created by Ruiying Duan on 2019/5/29.
//

#import <Foundation/Foundation.h>

#import "DryWeiboObj.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 状态码
typedef NS_ENUM(NSInteger, DryWeiboCode) {
    /// 成功
    kDryWeiboCodeSuccess,
    /// 未知错误
    kDryWeiboCodeUnknown,
    /// SDK未注册
    kDryWeiboCodeUnregister,
    /// 未安装客户端
    kDryWeiboCodeUninstall,
    /// 客户端不支持
    kDryWeiboCodeUnsupport,
    /// 参数异常
    kDryWeiboCodeParamsErr,
    /// 发送失败
    kDryWeiboCodeSendFail,
    /// 用户拒绝授权
    kDryWeiboCodeAuthDeny,
    /// 用户点击取消并返回
    kDryWeiboCodeUserCancel,
};

#pragma mark - Blcok
/// 授权回调(OpenID、接口调用凭证)
typedef void (^BlockDryWeiboAuth)   (NSString *_Nullable openID, NSString *_Nullable accessToken);
/// 用户信息回调(昵称、头像下载地址)
typedef void (^BlockDryWeiboUser)   (NSString *nickName, NSString *headImgUrl);
/// 状态码回调
typedef void (^BlockDryWeiboCode)   (DryWeiboCode code);

#pragma mark - DryWeibo
@interface DryWeibo : NSObject

/// @说明 注册微博客户端
/// @注释 scope官方<https://open.weibo.com/wiki/Scope>
/// @参数 appID:          微博开放平台下发的账号
/// @参数 redirectURI:    授权回调页地址(与官网设置要一致，否则授权会失败)
/// @参数 scope:          微博开放平台第三方应用scope，多个scrope用逗号分隔
/// @返回 void
+ (void)registerWithAppID:(NSString *)appID
              redirectURI:(NSString *)redirectURI
                    scope:(NSString *)scope;

/// @说明 处理微博通过URL启动App时传递的数据
/// @注释 在application:openURL:options:中调用
/// @返回 BOOL
+ (BOOL)handleOpenURL:(NSURL *)url;

/// @说明 检查用户是否可以通过微博客户端进行分享
/// @返回 BOOL
+ (BOOL)isCanShare;

/// @说明 申请授权(获取OpenID、accessToken)
/// @注释 当用户没有安装微博客户端或微博客户端过低无法支持SSO的时候弹出SDK自带的Webview进行授权
/// @参数 errHandler:     异常回调
/// @参数 successHandler: 授权信息回调
/// @返回 void
+ (void)auth:(BlockDryWeiboCode)errHandler successHandler:(BlockDryWeiboAuth)successHandler;

/// @说明 获取用户信息(昵称、头像地址)
/// @参数 openID:         用户标识
/// @参数 accessToken:    接口调用凭证
/// @参数 errHandler:     异常回调
/// @参数 successHandler: 用户信息回调
/// @返回 void
+ (void)userWithOpenID:(NSString *)openID
           accessToken:(NSString *)accessToken
            errHandler:(BlockDryWeiboCode)errHandler
        successHandler:(BlockDryWeiboUser)successHandler;

/// @说明 分享
/// @参数 type:       分享对象类型
/// @参数 message:    分享对象
/// @参数 completion: 分享结果回调
/// @数据 void
+ (void)sharedWithType:(DryWeiboObjType)type
               message:(DryWeiboObj *)message
            completion:(BlockDryWeiboCode)completion;

@end

NS_ASSUME_NONNULL_END
