//
//  M3U8Modify.h
//  M3U8Cache
//
//  Created by mac on 2020/2/22.
//  Copyright © 2020 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
   修改key、ts，并转换成远程服务器绝对地址
*/
@interface M3U8Modify : NSObject

/**
    m3u8修改器，将 key、ts 全部改为 http://localhost:<port>/<escapeURL>
 
    时间代价：转换1万条记录需要1s时间。
 
    @param  string          m3u8内容
    @param  url                 m3u8真实路径
    @param  port              本地服务器端口号
    @param  error           错误信息
 */
+ (NSMutableString *)modify:(NSMutableString *)string url:(NSURL *)url port:(NSInteger)port error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
