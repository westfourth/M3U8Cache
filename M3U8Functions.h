//
//  M3U8Function.h
//  M3U8Cache
//
//  Created by mac on 2020/2/22.
//  Copyright © 2020 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 本地服务器端口号
#define M3U8_SERVER_PORT    8080

/// 预缓存m3u8的ts片段个数
#define M3U8_PRECACHE_COUNT    1

/// 缓存文件路径，也是本地服务器根目录
#define M3U8_CACHE_PATH    NSTemporaryDirectory()

/// 将远程地址 转换成 本地地址
NSURL* M3U8LocalForRemote(NSURL* remoteURL, NSInteger port);

/// 将本地地址 转换成 远程地址
NSURL* M3U8RemoteForLocal(NSURL* localURL);

/// 远程地址 对应 本地文件路径
NSString* M3U8LocalFilePath(NSURL* remoteURL);


/**
    当服务器key与ts不在同一个目录下时，需要用此函数修正到正确的位置。
 
    @param  url         m3u8路径
    @param  key         m3u8内容的中key，可能带路径
 
    @return     key的父路径，可返回nil
    
    @note   此函数为可选择实现；如果没有实现，则默认key与ts在同一目录下。
 */
NSString* M3U8KeyParentPath(NSURL *url, NSString *key);


/**
    为网络请求添加额外信息
 
    @param  request     从url生成的网络请求
    
    @note   此函数为可选择实现。
 */
NSMutableURLRequest* M3U8RequestAddAdditionalInfo(NSMutableURLRequest *request);
