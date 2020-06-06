//
//  M3U8Extract.h
//  M3U8Cache
//
//  Created by mac on 2020/2/24.
//  Copyright © 2020 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
    key、ts提取，并转换成远程服务器绝对地址
 */
@interface M3U8Extract : NSObject

/**
    key、ts提取
 
    @param  string          m3u8内容
    @param  url                 m3u8真实路径
 */
+ (NSArray<NSURL *> *)extract:(NSString *)string url:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
