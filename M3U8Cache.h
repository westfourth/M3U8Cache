//
//  M3U8Cache.h
//  M3U8Cache
//
//  Created by mac on 2020/2/21.
//  Copyright © 2020 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GCDWebServer/GCDWebServer.h>

NS_ASSUME_NONNULL_BEGIN

/**
    m3u8缓存
 
    服务器：http://localhost:<port>。
    使用 M3U8LocalForRemote 方法将真实的URL转码作为NSURL.path，构成 http://localhost:<port>/<escapeURL>
 
    @warning    使用NSURL.query，GCDWebServer不会触发 asyncProcessBlock: 方法回调，因此不能使用NSURL.query方式；只能使用NSURL.path方式。
 
    @code
        _webServer = [GCDWebServer new];
        [M3U8Cache addHandlerForWebServer:_webServer];
        [_webServer startWithPort:8080 bonjourName:nil];
    @endcode
 
    @test   ✅本地
    @test   ✅m3u8、key、ts在同一目录
    @test   ✅公司服务器
 */
@interface M3U8Cache : NSObject

/**
    @param  port    本地服务器端口号
 */
+ (void)addHandlerForWebServer:(GCDWebServer *)webServer port:(NSInteger)port;

@end

NS_ASSUME_NONNULL_END
