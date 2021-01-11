//
//  ZAReactNativeManager.m
//  react-native-plugin-zhugeio
//
//  Created by Good_Morning_ on 2021/1/8.
//

#import "ZAReactNativeManager.h"

#import "ZAReactNativeCategory.h"
#import <React/RCTUIManager.h>

#if __has_include("Zhuge.h")
#import "Zhuge.h"
#else
#import <ZhugeioAnalytics/Zhuge.h>
#endif

#pragma mark - Constants
NSString *const kZAEventScreenNameProperty = @"$screen_name";
NSString *const kZAEventTitleProperty = @"$title";
NSString *const kZAEventElementContentProperty = @"$element_content";


#pragma mark - View Property

@interface ZAReactNativeViewProperty : NSObject

/// View 唯一标识符
@property (nonatomic, strong) NSNumber *reactTag;
/// View 可点击状态
@property (nonatomic, assign) BOOL clickable;
/// View 自定义属性
@property (nonatomic, strong) NSDictionary *properties;

@end

@implementation ZAReactNativeViewProperty

@end

#pragma mark - React Native Manager

@interface ZAReactNativeManager ()

@property (nonatomic, copy) NSDictionary *screenProperties;
@property (nonatomic, strong) NSSet *reactNativeIgnoreClasses;
@property (nonatomic, strong) NSMutableSet<ZAReactNativeViewProperty *> *viewProperties;

@end

@implementation ZAReactNativeManager

+ (instancetype)sharedInstance {
    static ZAReactNativeManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ZAReactNativeManager alloc] init];

    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSSet *nativeIgnoreClasses = [NSSet setWithObjects:@"RCTSwitch", @"RCTSlider", @"RCTSegmentedControl", @"RNGestureHandlerButton", @"RNCSlider", @"RNCSegmentedControl", nil];
        for (NSString *className in nativeIgnoreClasses) {
            if (NSClassFromString(className)) {
                [[Zhuge sharedInstance] ignoreViewType:NSClassFromString(className)];
            }
        }
        _reactNativeIgnoreClasses = [NSSet setWithObjects:@"RCTScrollView", @"RCTBaseTextInputView", nil];
        _viewProperties = [[NSMutableSet alloc] init];
        _isRootViewVisible = NO;
    }
    return self;
}


- (UIView *)viewWithReactTag:(NSNumber *)reactTag {
    RCTRootView *rootView = [self rootView];
    RCTUIManager *manager = rootView.bridge.uiManager;
    return [manager viewForReactTag:reactTag];
}


- (ZAReactNativeViewProperty *)viewPropertyWithReactTag:(NSNumber *)reactTag {
    __block ZAReactNativeViewProperty *viewProperty;
    [_viewProperties enumerateObjectsUsingBlock:^(ZAReactNativeViewProperty *obj, BOOL * _Nonnull stop) {
        if (obj.reactTag.integerValue == reactTag.integerValue) {
            viewProperty = obj;
            *stop = YES;
        }
    }];
    return viewProperty;
}

- (BOOL)clickableForView:(UIView *)view {
    if (!view) {
        return NO;
    }
    for (NSString *className in _reactNativeIgnoreClasses) {
        if ([view isKindOfClass:NSClassFromString(className)]) {
            return NO;
        }
    }
    ZAReactNativeViewProperty *viewProperties = [self viewPropertyWithReactTag:view.reactTag];

    // 兼容 Native 可视化全埋点 UISegmentedControl 整体不可圈选的场景
    if  ([view isKindOfClass:NSClassFromString(@"UISegmentedControl")]) {
        view.za_reactnative_screenProperties = _screenProperties;
        return NO;
    }

    // UISegmentedControl 只有子视图 UISegment 是可点击的
    if ([view isKindOfClass:NSClassFromString(@"UISegment")]) {
        ZAReactNativeViewProperty *superviewProperties = [self viewPropertyWithReactTag:view.superview.reactTag];
        view.za_reactnative_screenProperties = _screenProperties;
        return superviewProperties.clickable;
    }

    if (viewProperties.clickable) {
        // 可点击控件需要将当前页面信息保存在 za_reactnative_screenProperties 中，在可视化全埋点时使用
        view.za_reactnative_screenProperties = _screenProperties;
        return YES;
    }
    return NO;
}

- (BOOL)prepareView:(NSNumber *)reactTag clickable:(BOOL)clickable paramters:(NSDictionary *)paramters {
    if (!clickable) {
        return NO;
    }
    if (!reactTag) {
        return NO;
    }
    // 每个可点击控件都需要添加对应属性，集合内存在对应属性对象即表示控件可点击
    ZAReactNativeViewProperty *viewProperty = [[ZAReactNativeViewProperty alloc] init];
    viewProperty.reactTag = reactTag;
    viewProperty.clickable = clickable;
    viewProperty.properties = paramters;
    [_viewProperties addObject:viewProperty];
    return YES;
}

#pragma mark - visualize
- (NSDictionary *)visualizeProperties {
    return _isRootViewVisible ? _screenProperties : nil;
}

#pragma mark - AppClick
- (void)trackViewClick:(NSNumber *)reactTag {
    if (![Zhuge sharedInstance].config.autoTrackEnable == YES) {
        return;
    }
    // 忽略 $AppClick 事件
//    if ([[Zhuge sharedInstance] isAutoTrackEventTypeIgnored:ZhugeioAnalyticsEventTypeAppClick]) {
//        return;
//    }

    ZAReactNativeViewProperty *viewProperties = [self viewPropertyWithReactTag:reactTag];
    if ([viewProperties.properties[@"ignore"] boolValue]) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *view = [self viewWithReactTag:reactTag];
        for (NSString *className in self.reactNativeIgnoreClasses) {
            if ([view isKindOfClass:NSClassFromString(className)]) {
                return;
            }
        }
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        NSString *content = [view.accessibilityLabel stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        properties[kZAEventElementContentProperty] = content;
        [properties addEntriesFromDictionary:self.screenProperties];
        [properties addEntriesFromDictionary:viewProperties.properties];
        [properties setObject:@"RNView" forKey:@"$element_type"];
        [properties setObject:isNil(properties[@"$screen_name"]) forKey:@"$url"];
        [properties setObject:@"click" forKey:@"$eid"];
        [[Zhuge sharedInstance] autoTrack:[properties copy]];
    });
}

#pragma mark - AppViewScreen
- (void)trackViewScreen:(nullable NSString *)url properties:(nullable NSDictionary *)properties autoTrack:(BOOL)autoTrack {
    if (url && ![url isKindOfClass:NSString.class]) {
        NSLog(@"[ZhugeioAnalytics] error: url {%@} is not String Class ！！！", url);
        return;
    }
    NSString *screenName = properties[kZAEventScreenNameProperty] ?: url;
    NSString *title = properties[kZAEventTitleProperty] ?: screenName;

    NSMutableDictionary *pageProps = [NSMutableDictionary dictionary];
    pageProps[kZAEventScreenNameProperty] = screenName;
    pageProps[kZAEventTitleProperty] = title;
    _screenProperties = pageProps;

    if (autoTrack && ![Zhuge sharedInstance].config.autoTrackEnable == YES) {
        return;
    }
    // 忽略 $AppViewScreen
//    if (autoTrack && [[Zhuge sharedInstance] isAutoTrackEventTypeIgnored:ZhugeioAnalyticsEventTypeAppViewScreen]) {
//        return;
//    }

    NSMutableDictionary *eventProps = [NSMutableDictionary dictionary];
    [eventProps setObject:@"pv" forKey:@"$eid"];
    [eventProps setObject:url forKey:@"$url"];
    [eventProps addEntriesFromDictionary:pageProps];
    [eventProps addEntriesFromDictionary:properties];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

    [[Zhuge sharedInstance] autoTrack:[eventProps copy]];
    
#pragma clang diagnostic pop

}


#pragma mark - SDK Method
- (RCTRootView *)rootView {
    // RCTRootView 只能是 UIViewController 的 view，不能作为其他 View 的 SubView 使用
    UIViewController *root = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    UIView *view = [root view];
    // 不是混编 React Native 项目时直接获取 RootViewController 的 view
    if ([view isKindOfClass:RCTRootView.class]) {
        return (RCTRootView *)view;
    }
    Class utils = NSClassFromString(@"ZhugeAutoTrackUtils");
    if (!utils) {
        return nil;
    }
    SEL currentCallerSEL = NSSelectorFromString(@"currentViewController");
    if (![utils respondsToSelector:currentCallerSEL]) {
        return nil;
    }

    // 混编 React Native 项目时获取当前显示的 UIViewController 的 view
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    UIViewController *caller = [utils performSelector:currentCallerSEL];
#pragma clang diagnostic pop

    if (![caller.view isKindOfClass:RCTRootView.class]) {
        return nil;
    }
    return (RCTRootView *)caller.view;
}


@end
