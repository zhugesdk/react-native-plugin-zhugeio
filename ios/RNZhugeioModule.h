//
//  RNZhugeioModule.h
//  react-native-plugin-zhugeio
//
//  Created by Good_Morning_ on 2021/1/8.
//

#import <Foundation/Foundation.h>

#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface RNZhugeioModule : NSObject <RCTBridgeModule>

@end

NS_ASSUME_NONNULL_END
