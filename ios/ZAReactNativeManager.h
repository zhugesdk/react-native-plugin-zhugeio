//
//  ZAReactNativeManager.h
//  react-native-plugin-zhugeio
//
//  Created by Good_Morning_ on 2021/1/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZAReactNativeManager : NSObject

@property (nonatomic, assign) BOOL isRootViewVisible;

+ (instancetype)sharedInstance;

/**
 @abstract
 可视化全埋点获取页面消息

 @return 页面信息字典
 */
- (NSDictionary *)visualizeProperties;

/**
 @abstract
 获取 View 的可点击状态

 @param view  获取状态的 View 对象
 @return 点击状态
 */
- (BOOL)clickableForView:(UIView *)view;

/**
@abstract
记录 View 的点击状态及自定义属性

@param reactTag  React Native 分配的唯一标识符
@param clickable  是否可点击
@param paramters  自定义属性
@return 可点击控件是否记录成功
*/
- (BOOL)prepareView:(NSNumber *)reactTag clickable:(BOOL)clickable paramters:(NSDictionary *)paramters;

/**
 @abstract
 触发 React Native 点击事件

 @param reactTag  React Native 分配的唯一标识符
 */
- (void)trackViewClick:(NSNumber *)reactTag;

/**
 @abstract
 触发 React Native 页面浏览事件

 @param url  页面路径
 @param properties  自定义页面属性
 @param autoTrack  是否为自动埋点
 */
- (void)trackViewScreen:(nullable NSString *)url properties:(nullable NSDictionary *)properties autoTrack:(BOOL)autoTrack;

@end

NS_ASSUME_NONNULL_END
