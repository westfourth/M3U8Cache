//
//  M3U8Function.m
//  M3U8Cache
//
//  Created by mac on 2020/2/22.
//  Copyright © 2020 mac. All rights reserved.
//

#import "M3U8Functions.h"
#import <GCDWebServer/GCDWebServerFunctions.h>
#import <UIKit/UIKit.h>

/// 将远程地址 转换成 本地地址
NSURL* M3U8LocalForRemote(NSURL* remoteURL, NSInteger port) {
    //  escape转码
    NSString *escapeURLString = GCDWebServerEscapeURLString(remoteURL.absoluteString);
    //  作为路径放在localhost后面
    NSString *localURLString = [NSString stringWithFormat:@"http://localhost:%ld/%@", port, escapeURLString];
    NSURL *localURL = [NSURL URLWithString:localURLString];
    return localURL;
}

/// 将本地地址 转换成 远程地址
NSURL* M3U8RemoteForLocal(NSURL* localURL) {
    NSString *escapeURLString = [localURL.path substringFromIndex:@"/".length];
    NSString *remoteURLString = GCDWebServerUnescapeURLString(escapeURLString);
    NSURL *remoteURL = [NSURL URLWithString:remoteURLString];
    return remoteURL;
}

/// 远程地址 对应 本地文件路径
NSString* M3U8LocalFilePath(NSURL* remoteURL) {
    NSString *fileName = remoteURL.absoluteString.lastPathComponent;
    NSString *localFilePath = [M3U8_CACHE_PATH stringByAppendingPathComponent:fileName];
    return localFilePath;
}
