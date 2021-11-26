//
//  UIView+ZAReactNative.m
//  react-native-plugin-zhugeio
//
//  Created by Zhugeio on 2021/1/8.
//

#import "ZAReactNativeCategory.h"
#import "ZAReactNativeswizzler.h"
#import "ZAReactNativeManager.h"
#import <objc/runtime.h>
#import <React/RCTUIManager.h>

#pragma mark - UIView Category
@implementation UIView (ZAReactNative)

- (NSDictionary *)za_reactnative_screenProperties {
    return objc_getAssociatedObject(self, @"ZhugeioAnalyticsRNScreenProperties");
}

- (void)setZa_reactnative_screenProperties:(NSDictionary *)za_reactnative_screenProperties {
    objc_setAssociatedObject(self, @"ZhugeioAnalyticsRNScreenProperties", za_reactnative_screenProperties, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end


#pragma mark - UIViewController Category
@interface UIViewController (ZAReactNative)

@property (nonatomic, assign) BOOL za_reactnative_isReferrerRootView;

@end


@implementation UIViewController (ZAReactNative)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIViewController za_reactnative_swizzleMethod:@selector(viewDidAppear:)
                                            withMethod:@selector(za_reactnative_viewDidAppear:)
                                                 error:NULL];

        [UIViewController za_reactnative_swizzleMethod:@selector(viewDidDisappear:)
                                            withMethod:@selector(za_reactnative_viewDidDisappear:)
                                                 error:NULL];
    });
}


- (BOOL)za_reactnative_isReferrerRootView {
    NSNumber *result = objc_getAssociatedObject(self, @"za_reactnative_isReferrerRootView");
    return result.boolValue;
}

- (void)setZa_reactnative_isReferrerRootView:(BOOL)isRootView {
    objc_setAssociatedObject(self, @"za_reactnative_isReferrerRootView", @(isRootView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)za_reactnative_viewDidAppear:(BOOL)animated {
    [self za_reactnative_viewDidAppear:animated];

    if ([self isKindOfClass:UIAlertController.class]) {
        return;
    }
    // 当前 Controller 为 React Native 根视图时，设置标志位为 YES
    if ([self.view isReactRootView]) {
        [[ZAReactNativeManager sharedInstance] setIsRootViewVisible:YES];
        return;
    }

    //检查 referrer 是否为 React Native 根视图
    UIViewController *referrer = self.presentingViewController;
    if (!referrer) {
        return;
    }

    // 当前 Controller 不为 React Native 根视图时， isRootViewVisible 肯定为 NO
    [[ZAReactNativeManager sharedInstance] setIsRootViewVisible:NO];

    if ([referrer isKindOfClass:UITabBarController.class]) {
        UIViewController *controller = [(UITabBarController *)referrer selectedViewController];
        [self checkReferrerController:controller];
    } else {
        [self checkReferrerController:referrer];
    }
}

- (void)checkReferrerController:(UIViewController *)controler {
    if ([controler isKindOfClass:UINavigationController.class]) {
        UIViewController *vc = [(UINavigationController *)controler viewControllers].lastObject;
        if ([vc.view isReactRootView]) {
            self.za_reactnative_isReferrerRootView = YES;
        }
    } else if ([controler isKindOfClass:UIViewController.class]) {
        if ([controler.view isReactRootView]) {
            self.za_reactnative_isReferrerRootView = YES;
        }
    }
}

- (void)za_reactnative_viewDidDisappear:(BOOL)animated {
    [self za_reactnative_viewDidDisappear:animated];

    // 当前 Controller 为 React Native 根视图时，消失时将标志位设置为 NO
    if ([self.view isReactRootView]) {
        [[ZAReactNativeManager sharedInstance] setIsRootViewVisible:NO];
        return;
    }

    // 当前 Controller 的 referrer 为 React Native 根视图时，消失时将标志位设置为 YES
    if (self.za_reactnative_isReferrerRootView) {
        [[ZAReactNativeManager sharedInstance] setIsRootViewVisible:YES];
        return;
    }
}

@end
