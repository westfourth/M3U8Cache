//
//  M3U8PreCache.m
//  M3U8Cache
//
//  Created by mac on 2020/2/24.
//  Copyright © 2020 mac. All rights reserved.
//

#import "M3U8PreCache.h"
#import "M3U8Functions.h"
#import "M3U8Modify.h"
#import "M3U8Extract.h"
#include <dlfcn.h>

@interface M3U8PreCache () {
    NSLock *_lock;
}

@property (nonatomic) NSMutableArray<NSURL *> *urls;
@property (atomic) NSURL *downloadingURL;     //  正在下载的URL

@end


@implementation M3U8PreCache

- (instancetype)init {
    self = [super init];
    if (self) {
        self.urls = [NSMutableArray new];
        _lock = [NSLock new];
        _port = M3U8_SERVER_PORT;
    }
    return self;
}

+ (instancetype)share {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self class] new];
    });
    return instance;
}

- (void)safeAdd:(NSURL *)url {
    [_lock lock];
    if (![self.urls containsObject:url]) {
        [self.urls addObject:url];
    }
    [_lock unlock];
}

- (void)safeDelete:(NSURL *)url {
    [_lock lock];
    [self.urls removeObject:url];
    [_lock unlock];
}

//_______________________________________________________________________________________________________________
// MARK: -

//  url专指m3u8地址
- (void)preCache:(NSURL *)url {
    [self downlaod:url completion:^(NSData *data, NSError *error) {
        if (error) {
            return;
        }

        //  提取
        NSMutableString *originText = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *urls = [M3U8Extract extract:originText url:url];
        
        //  改写成http://localhost:<port>/<remoteURL>形式，存储到本地
        NSString *modifiedText = [M3U8Modify modify:originText url:url port:self.port error:&error];
        data = [modifiedText dataUsingEncoding:NSUTF8StringEncoding];
        [data writeToFile:M3U8LocalFilePath(url) atomically:NO];
        
        //  key、ts地址加入到下载队列
        for (NSURL *url in urls) {
            [self downlaod:url completion:nil];
        }
    }];
}

//  url指m3u8、key、ts地址
- (void)downlaod:(NSURL *)url completion:(void (^)(NSData *data, NSError *error))completion {
    //  如果文件存在，返回
    NSString* filePath = M3U8LocalFilePath(url);
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (exist) {
//        printf("<<< 预缓存已存在：%s\n", url.absoluteString.UTF8String);
        [self complete:url];
        return;
    }
    
    //
    [self safeAdd:url];
    if (self.downloadingURL != nil) {
        return;
    }
    self.downloadingURL = url;
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSMutableURLRequest* (*fcn)(NSMutableURLRequest*) = dlsym(RTLD_SELF, "M3U8RequestAddAdditionalInfo");
    if (fcn != NULL) {
        req = fcn(req);
    }
    req.networkServiceType = NSURLNetworkServiceTypeVideo;
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        self.downloadingURL = nil;
        [self complete:url];
        
//        printf("<<< 预缓存成功：%s\n", url.absoluteString.UTF8String);
        //  出错
        if (error) {
            if (completion) completion(nil, error);
            return;
        }
        //  状态不为200
        NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
        if (statusCode != 200) {
            NSError *error = [NSError errorWithDomain:@"com.M3U8PreCache" code:statusCode userInfo:nil];
            if (completion) completion(nil, error);
            return;
        }
        //  正确返回
        if (completion) completion(data, error);
        //  ts、key文件存储到本地
        if (![url.absoluteString hasSuffix:@"m3u8"]) {
            [data writeToFile:M3U8LocalFilePath(url) atomically:NO];
        }
    }];
    [task resume];
}

- (void)complete:(NSURL *)url {
    [self safeDelete:url];
    NSURL *nextURL = self.urls.firstObject;
    if (nextURL == nil) {
        return;
    }
    if ([nextURL.absoluteString hasSuffix:@"m3u8"]) {
        [self preCache:nextURL];
    } else {
        [self downlaod:nextURL completion:nil];
    }
}

@end
