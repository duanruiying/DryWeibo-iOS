//
//  DryWeibo.m
//  DryWeibo
//
//  Created by Ruiying Duan on 2019/5/29.
//

#import "DryWeibo.h"
#import "WeiboSDK.h"

#pragma mark - DryWeibo
@interface DryWeibo () <WeiboSDKDelegate>

/// SDK是否注册成功
@property (nonatomic, readwrite, assign) BOOL isRegister;
/// 授权回调页地址
@property (nonatomic, readwrite, copy) NSString *redirectURI;
/// 微博开放平台第三方应用scope，多个scrope用逗号分隔
@property (nonatomic, readwrite, copy) NSString *scope;
/// 授权Block
@property (nonatomic, readwrite, copy) BlockDryWeiboAuth authBlock;
/// 授权状态码Block
@property (nonatomic, readwrite, copy) BlockDryWeiboCode authCodeBlock;
/// 分享状态码Block
@property (nonatomic, readwrite, copy) BlockDryWeiboCode sharedCodeBlock;

@end

@implementation DryWeibo

/// 单例
+ (instancetype)shared {
    
    static DryWeibo *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        instance = [[DryWeibo alloc] init];
    });
    
    return instance;
}

/// 构造
- (instancetype)init {
    
    self = [super init];
    if (self) {
    
    }
    
    return self;
}

/// 析构
- (void)dealloc {
    
}

/// 注册微博客户端
+ (void)registerWithAppID:(NSString *)appID
              redirectURI:(NSString *)redirectURI
                    scope:(NSString *)scope {
    
    /// 检查参数
    if (!appID) {
        return;
    }
    
    /// 关闭Debug
    [WeiboSDK enableDebugMode:NO];
    
    /// 注册
    [DryWeibo shared].isRegister = [WeiboSDK registerApp:appID];
    
    /// 保存数据
    [DryWeibo shared].redirectURI = redirectURI;
    [DryWeibo shared].scope = scope;
}

/// 处理微博通过URL启动App时传递的数据
+ (BOOL)handleOpenURL:(NSURL *)url {
    return [WeiboSDK handleOpenURL:url delegate:[DryWeibo shared]];
}

/// 检查用户是否可以通过微博客户端进行分享
+ (BOOL)isCanShare {
    return [WeiboSDK isCanShareInWeiboAPP];
}

/// 申请授权(获取OpenID、accessToken)
+ (void)auth:(BlockDryWeiboCode)errHandler successHandler:(BlockDryWeiboAuth)successHandler {
    
    /// 检查数据
    if (!errHandler || !successHandler) {
        return;
    }
    
    /// 检查(SDK是否注册成功)
    if (![DryWeibo shared].isRegister) {
        errHandler(kDryWeiboCodeUnregister);
        return;
    }
    
    /// 更新Block
    [DryWeibo shared].authCodeBlock = errHandler;
    [DryWeibo shared].authBlock = successHandler;
    
    /// 请求授权
    WBAuthorizeRequest *request = [[WBAuthorizeRequest alloc] init];
    request.redirectURI = [DryWeibo shared].redirectURI;
    request.scope = [DryWeibo shared].scope;
    request.shouldShowWebViewForAuthIfCannotSSO = YES;
    [WeiboSDK sendRequest:request];
}

/// 获取用户信息(昵称、头像地址)
+ (void)userWithOpenID:(NSString *)openID
           accessToken:(NSString *)accessToken
            errHandler:(BlockDryWeiboCode)errHandler
        successHandler:(BlockDryWeiboUser)successHandler {
    
    /// 检查数据
    if (!errHandler || !successHandler) {
        return;
    }
    
    /// 检查(SDK是否注册成功)
    if (![DryWeibo shared].isRegister) {
        errHandler(kDryWeiboCodeUnregister);
        return;
    }
    
    /// 检查数据
    if (!openID || !accessToken) {
        errHandler(kDryWeiboCodeParamsErr);
        return;
    }
    
    /// 发送请求
    NSString *url = @"https://api.weibo.com/2/users/show.json";
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:openID forKey:@"uid"];
    [params setValue:accessToken forKey:@"access_token"];
    [WBHttpRequest requestWithURL:url httpMethod:@"GET" params:params queue:[NSOperationQueue mainQueue] withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
        
        /// 获取数据失败
        if (error || !result || ![result isKindOfClass:[NSDictionary class]]) {
            errHandler(kDryWeiboCodeUnknown);
            return;
        }
        
        /// 解析数据
        NSString *nickName = @"";
        NSString *headImgUrl = @"";
        if ([[result allKeys] containsObject:@"name"]) {
            nickName = [NSString stringWithFormat:@"%@", [result valueForKey:@"name"]];
        }
        if ([[result allKeys] containsObject:@"avatar_hd"]) {
            headImgUrl = [NSString stringWithFormat:@"%@", [result valueForKey:@"avatar_hd"]];
        }
        
        /// 返回数据
        successHandler(nickName, headImgUrl);
    }];
}

/// 分享
+ (void)sharedWithType:(DryWeiboObjType)type
               message:(DryWeiboObj *)message
            completion:(BlockDryWeiboCode)completion {
    
    /// 检查数据
    if (!completion) {
        return;
    }
    
    /// 检查(SDK是否注册成功)
    if (![DryWeibo shared].isRegister) {
        completion(kDryWeiboCodeUnregister);
        return;
    }
    
    /// 检查(是否能分享)
    if (![DryWeibo isCanShare]) {
        completion(kDryWeiboCodeUnsupport);
        return;
    }
    
    /// 检查数据
    if (!message || !message.text) {
        completion(kDryWeiboCodeParamsErr);
        return;
    }
    
    /// 更新Block
    [DryWeibo shared].sharedCodeBlock = completion;
    
    /// 创建分享对象
    WBMessageObject *targetMessage = [WBMessageObject message];
    targetMessage.text = message.text;
    if (type == kDryWeiboObjTypeImage && message.imageData) {
        WBImageObject *obj = [WBImageObject object];
        obj.imageData = message.imageData;
        obj.isShareToStory = message.isShareToStory;
        targetMessage.imageObject = obj;
    }else if (type == kDryWeiboObjTypeVideo && message.videoUrl) {
        WBNewVideoObject *obj = [WBNewVideoObject object];
        [obj addVideo:message.videoUrl];
        obj.isShareToStory = message.isShareToStory;
        targetMessage.videoObject = obj;
    }else if (type == kDryWeiboObjTypeWebpage && message.webpageUrl) {
        WBWebpageObject *obj = [[WBWebpageObject alloc] init];
        obj.webpageUrl = message.webpageUrl;
        targetMessage.mediaObject = obj;
    }
    
    /// 分享
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:targetMessage];
    [WeiboSDK sendRequest:request];
}

#pragma mark - WeiboSDKDelegate
/// 收到一个来自微博客户端程序的请求
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    
}

/// 收到一个来自微博客户端程序的响应
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    
    /// 授权(SSO)回调
    if (response && [response isKindOfClass:[WBAuthorizeResponse class]]) {
        
        /// 检查数据
        if (![DryWeibo shared].authBlock || ![DryWeibo shared].authCodeBlock) {
            return;
        }
        
        /// 解析数据
        WeiboSDKResponseStatusCode statusCode = response.statusCode;
        if (statusCode == WeiboSDKResponseStatusCodeSuccess) {
            WBAuthorizeResponse *resp = (WBAuthorizeResponse *)response;
            NSString *userID = resp.userID;
            NSString *accessToken = resp.accessToken;
            [DryWeibo shared].authBlock(userID, accessToken);
        }else if (statusCode == WeiboSDKResponseStatusCodeUserCancel) {
            [DryWeibo shared].authCodeBlock(kDryWeiboCodeUserCancel);
        }else if (statusCode == WeiboSDKResponseStatusCodeSentFail) {
            [DryWeibo shared].authCodeBlock(kDryWeiboCodeSendFail);
        }else if (statusCode == WeiboSDKResponseStatusCodeAuthDeny) {
            [DryWeibo shared].authCodeBlock(kDryWeiboCodeAuthDeny);
        }else {
            [DryWeibo shared].authCodeBlock(kDryWeiboCodeUnknown);
        }
        
        /// 清理Block
        [DryWeibo shared].authBlock = nil;
        [DryWeibo shared].authCodeBlock = nil;
    }
    
    /// 分享回调
    if (response && [response isKindOfClass:[WBSendMessageToWeiboResponse class]]) {
        
        /// 检查数据
        if (![DryWeibo shared].sharedCodeBlock) {
            return;
        }
        
        /// 解析数据
        WeiboSDKResponseStatusCode statusCode = response.statusCode;
        if (statusCode == WeiboSDKResponseStatusCodeSuccess) {
            [DryWeibo shared].sharedCodeBlock(kDryWeiboCodeSuccess);
        }else if (statusCode == WeiboSDKResponseStatusCodeUserCancel) {
            [DryWeibo shared].sharedCodeBlock(kDryWeiboCodeUserCancel);
        }else if (statusCode == WeiboSDKResponseStatusCodeSentFail) {
            [DryWeibo shared].sharedCodeBlock(kDryWeiboCodeSendFail);
        }else if (statusCode == WeiboSDKResponseStatusCodeAuthDeny) {
            [DryWeibo shared].sharedCodeBlock(kDryWeiboCodeAuthDeny);
        }else if (statusCode == WeiboSDKResponseStatusCodeShareInSDKFailed) {
            [DryWeibo shared].sharedCodeBlock(kDryWeiboCodeUnsupport);
        }else {
            [DryWeibo shared].sharedCodeBlock(kDryWeiboCodeUnknown);
        }
        
        /// 清理Block
        [DryWeibo shared].sharedCodeBlock = nil;
    }
}

@end
