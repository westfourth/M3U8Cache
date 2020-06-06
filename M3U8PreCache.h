//
//  M3U8PreCache.h
//  M3U8Cache
//
//  Created by mac on 2020/2/24.
//  Copyright © 2020 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
    m3u8预缓存，不经过本地服务器
    
    同时最多允许1个任务，多个任务会影响播放器播放
 */
@interface M3U8PreCache : NSObject

+ (instancetype)share;

/// 本地服务器端口号，默认为8080
@property (nonatomic) NSInteger port;

/**
    不需要回调，失败了没关系，播放器遇到本地没有的，会重新下载
    
    @param  url     m3u8
 */
- (void)preCache:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
