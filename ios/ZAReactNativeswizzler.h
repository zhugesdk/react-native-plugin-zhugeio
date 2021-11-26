//
//  NSObject+ZAReactNativeswizzler.h
//  react-native-plugin-zhugeio
//
//  Created by Zhugeio on 2021/1/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ZAReactNativeswizzler)

+ (BOOL)za_reactnative_swizzleMethod:(SEL)origSel_ withMethod:(SEL)altSel_ error:(NSError **)error_;
+ (BOOL)za_reactnative_swizzleClassMethod:(SEL)origSel_ withClassMethod:(SEL)altSel_ error:(NSError **)error_;

@end

NS_ASSUME_NONNULL_END
