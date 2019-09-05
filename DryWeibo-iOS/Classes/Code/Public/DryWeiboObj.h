//
//  DryWeiboObj.h
//  DryWeibo
//
//  Created by Ruiying Duan on 2019/6/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 分享对象类型
typedef NS_ENUM(NSInteger, DryWeiboObjType) {
    /// 文本
    kDryWeiboObjTypeText,
    /// 图片
    kDryWeiboObjTypeImage,
    /// 视频
    kDryWeiboObjTypeVideo,
    /// 网页
    kDryWeiboObjTypeWebpage,
};

#pragma mark - 分享对象
@interface DryWeiboObj : NSObject

/// ==========> 通用属性
/// 文本内容(必传参数，长度小于2000个汉字)
@property (nonatomic, readwrite, copy) NSString *text;
/// 是否分享到story
@property (nonatomic, readwrite, assign) BOOL isShareToStory;

/// ==========> 图片
/// 图片真实数据内容(大小不能超过10M)
@property (nonatomic, readwrite, nullable, strong) NSData *imageData;

/// ==========> 视频
@property (nonatomic, readwrite, nullable, strong) NSURL *videoUrl;

/// ==========> 网页
@property (nonatomic, readwrite, nullable, strong) NSString *webpageUrl;

@end

NS_ASSUME_NONNULL_END
