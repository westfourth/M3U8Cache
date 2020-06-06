//
//  M3U8Extract.m
//  M3U8Cache
//
//  Created by mac on 2020/2/24.
//  Copyright © 2020 mac. All rights reserved.
//

#import "M3U8Extract.h"
#import "M3U8Functions.h"
#include <dlfcn.h>

@implementation M3U8Extract

/// key、ts提取
+ (NSArray<NSURL *> *)extract:(NSString *)string url:(NSURL *)url {
    NSMutableArray<NSURL *> *urls = [NSMutableArray new];
    //  key替换
    NSString *keyPattern = @"(?<=#EXT-X-KEY:METHOD=AES-128,URI=\").+(?=\")";
    NSArray *keyArray = [self extract:keyPattern string:string url:url];
    [urls addObjectsFromArray:keyArray];
    //  ts替换
    NSString *tsPattern = @".+\\.ts";
    NSArray *tsArray = [self extract:tsPattern string:string url:url];
    [urls addObjectsFromArray:tsArray];
    return urls;
}

//  替换
+ (NSArray<NSURL *> *)extract:(NSString *)pattern string:(NSString *)string url:(NSURL *)url {
    NSError *error = nil;
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    //
    NSRange range = NSMakeRange(0, string.length);
    
    //  取出第一个匹配的，看是相对路径还是绝对路径
    NSRange firstRange = [regexp rangeOfFirstMatchInString:string options:0 range:range];
    if (firstRange.location == NSNotFound) {
        return nil;
    }
    NSString *firstRangeText = [string substringWithRange:firstRange];
    //  是否是绝对路径
    BOOL isAbsolute = [firstRangeText hasPrefix:@"http"];
    
    NSMutableArray *urls = [NSMutableArray new];
    NSArray<NSTextCheckingResult *> *results = [regexp matchesInString:string options:0 range:range];
    for (NSInteger i = 0; i < M3U8_PRECACHE_COUNT && i < results.count; i++) {
        NSTextCheckingResult *result = results[i];
        //  匹配的字符串
        NSString *matchText = [string substringWithRange:result.range];
        //  如果不是绝对路径，先改为绝对路径
        NSString *parentPath = @"";
        if (!isAbsolute) {
            parentPath = [url URLByDeletingLastPathComponent].absoluteString;
            NSString* (*fcn)(NSURL*, NSString*) = dlsym(RTLD_SELF, "M3U8KeyParentPath");
            if (fcn != NULL) {
                NSString *customParentPath = fcn(url, matchText);
                if (customParentPath != nil) {
                    parentPath = customParentPath;
                }
            }
        }
        NSString *remoteURLString = [NSString stringWithFormat:@"%@%@", parentPath, matchText];
        NSURL *remoteURL = [NSURL URLWithString:remoteURLString];
        [urls addObject:remoteURL];
    }
    return urls;
}

@end
