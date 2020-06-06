//
//  M3U8Cache.m
//  M3U8Cache
//
//  Created by mac on 2020/2/21.
//  Copyright © 2020 mac. All rights reserved.
//

#import "M3U8Cache.h"
#import <GCDWebServer/GCDWebServerFunctions.h>
#import <GCDWebServer/GCDWebServerFileResponse.h>
#import <GCDWebServer/GCDWebServerDataResponse.h>
#import <GCDWebServer/GCDWebServerHTTPStatusCodes.h>
#import "M3U8Functions.h"
#import "M3U8Modify.h"
#include <dlfcn.h>

@implementation M3U8Cache

+ (void)addHandlerForWebServer:(GCDWebServer *)webServer port:(NSInteger)port {
    [webServer addDefaultHandlerForMethod:@"GET"
                             requestClass:[GCDWebServerRequest class]
                        asyncProcessBlock:^(__kindof GCDWebServerRequest * _Nonnull request, GCDWebServerCompletionBlock  _Nonnull completionBlock) {
        //
        NSURL *remoteURL = M3U8RemoteForLocal(request.URL);
        NSString* filePath = M3U8LocalFilePath(remoteURL);
        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        
        //  如果文件存在，返回本地文件
        if (exist) {
//            printf(">>> 缓存已存在：%s\n", remoteURL.absoluteString.UTF8String);
            GCDWebServerResponse* response = [GCDWebServerFileResponse responseWithFile:filePath byteRange:request.byteRange];
            [response setValue:@"bytes" forAdditionalHeader:@"Accept-Ranges"];
            response.cacheControlMaxAge = 3600;
            completionBlock(response);
            return;
        }
        
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:remoteURL];
        NSMutableURLRequest* (*fcn)(NSMutableURLRequest*) = dlsym(RTLD_SELF, "M3U8RequestAddAdditionalInfo");
        if (fcn != NULL) {
            req = fcn(req);
        }
        req.networkServiceType = NSURLNetworkServiceTypeResponsiveAV;
        
        //  文件不存在，下载并存储到本地
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//            printf(">>> 缓存成功：%s\n", remoteURL.absoluteString.UTF8String);
            //  出错
            if (error) {
                GCDWebServerResponse* serverResponse = [GCDWebServerResponse responseWithStatusCode:kGCDWebServerHTTPStatusCode_NotFound];
                completionBlock(serverResponse);
                return;
            }
            //  状态不为200
            NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
            if (statusCode != 200) {
                GCDWebServerResponse* serverResponse = [GCDWebServerResponse responseWithStatusCode:statusCode];
                completionBlock(serverResponse);
                return;
            }
            
            //  如果为m3u8，需要改写
            if ([remoteURL.absoluteString hasSuffix:@"m3u8"]) {
                NSMutableString *originText = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSString *modifiedText = [M3U8Modify modify:originText url:remoteURL port:port error:&error];
                data = [modifiedText dataUsingEncoding:NSUTF8StringEncoding];
            }
            
            //  正确返回
            GCDWebServerDataResponse* serverResponse = [GCDWebServerDataResponse responseWithData:data contentType:response.MIMEType];
            completionBlock(serverResponse);
            //  存储到本地
            [data writeToFile:M3U8LocalFilePath(remoteURL) atomically:NO];
        }];
        [task resume];
    }];
}

@end
