//
//  M3U8CacheManager.m
//  M3U8Cache
//
//  Created by mac on 2020/2/25.
//  Copyright © 2020 mac. All rights reserved.
//

#import "M3U8CacheManager.h"
#import "M3U8Functions.h"

@implementation M3U8CacheManager

/// 缓存大小
+ (NSUInteger)size {
    NSError *error = nil;
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:M3U8_CACHE_PATH error:&error];
    if (error) {
        NSLog(@">>> %s: %@", __func__, error);
        return 0;
    }
    NSUInteger size = 0;
    for (NSString *fileName in array) {
        NSString *path = [M3U8_CACHE_PATH stringByAppendingPathComponent:fileName];
        NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
        size += dict.fileSize;
    }
    return size;
}

/// 清除缓存
+ (void)clear {
    NSError *error = nil;
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:M3U8_CACHE_PATH error:&error];
    if (error) {
        NSLog(@">>> %s: %@", __func__, error);
        return;
    }
    for (NSString *fileName in array) {
        NSString *path = [M3U8_CACHE_PATH stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    }
}

@end
