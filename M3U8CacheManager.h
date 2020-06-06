//
//  M3U8CacheManager.h
//  M3U8Cache
//
//  Created by mac on 2020/2/25.
//  Copyright © 2020 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 缓存管理
@interface M3U8CacheManager : NSObject

/// 缓存大小
+ (NSUInteger)size;

/// 清除缓存
+ (void)clear;

@end

NS_ASSUME_NONNULL_END
