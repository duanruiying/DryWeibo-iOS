# DryWeibo-iOS
iOS: 简化微博集成(授权、获取用户信息、分享)

## 官网
* [微博开放平台](http://open.weibo.com/wiki/Sdk/ios)
* [Github 3.2.3](https://github.com/sinaweibosdk/weibo_ios_sdk)

## Prerequisites
* iOS 10.0+
* ObjC、Swift

## Installation
* pod 'DryWeibo-iOS'

## SDK工程配置
### 全局开放HTTP
```
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## App工程配置
### 为URL Types 添加回调scheme(identifier:"com.weibo"、URL Schemes:"wb+AppID")
### info.plist文件属性LSApplicationQueriesSchemes中增加如下选项(注意大小写):
```
sinaweibohd
sinaweibo
weibosdk
weibosdk2.5
```
### 全局开放HTTP
```
<key>NSAppTransportSecurity</key>
<dict>
<key>NSAllowsArbitraryLoads</key>
<true/>
</dict>
```
### 如果没有“全局开放HTTP”，info.plist文件属性NSAppTransportSecurity需要设置以下白名单:
```
sina.cn 
weibo.cn 
weibo.com 
sinaimg.cn 
sinajs.cn 
sina.com.cn
```
格式示例如下:
```
<key>sina.com.cn</key>
<dict>
    <key>NSIncludesSubdomains</key>
    <true/>
    <key>NSThirdPartyExceptionAllowsInsecureHTTPLoads</key>
    <true/>
    <key>NSExceptionMinimumTLSVersion</key>
    <string>TLSv1.0</string>
    <key>NSThirdPartyExceptionRequiresForwardSecrecy</key>
    <false/>
</dict>
```

## Features
### SDK配置
```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [DryWeibo registerWithAppID:@""
                    redirectURI:@"www.sina.com"
                          scope:@"all"];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [DryWeibo handleOpenURL:url];
    return YES;
}
```
### 授权、获取用户信息
```
[DryWeibo auth:^(DryWeiboCode code) {
    NSLog(@"授权状态码: %ld", code);
} successHandler:^(NSString * _Nullable openID, NSString * _Nullable accessToken) {
    NSLog(@"openID: %@, accessToken: %@", openID, accessToken);

    [DryWeibo userWithOpenID:openID accessToken:accessToken errHandler:^(DryWeiboCode code) {
        NSLog(@"用户信息状态码: %ld", code);
    } successHandler:^(NSString * _Nonnull nickName, NSString * _Nonnull headImgUrl) {
        NSLog(@"nickName: %@, headImgUrl: %@", nickName, headImgUrl);
    }];
}];
```
### 分享
```
DryWeiboObj *obj = [[DryWeiboObj alloc] init];
obj.text = @"分享我的测试文本";
[DryWeibo sharedWithType:kDryWeiboObjTypeText message:obj completion:^(DryWeiboCode code) {
    NSLog(@"分享状态码: %ld", code);
}];
```
