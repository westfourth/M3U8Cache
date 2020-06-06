//
//  M3U8Modify.m
//  M3U8Cache
//
//  Created by mac on 2020/2/22.
//  Copyright © 2020 mac. All rights reserved.
//

#import "M3U8Modify.h"
#import "M3U8Functions.h"
#include <dlfcn.h>

@implementation M3U8Modify

+ (NSMutableString *)modify:(NSMutableString *)string url:(NSURL *)url port:(NSInteger)port error:(NSError **)error {
    //  key替换
    NSString *keyPattern = @"(?<=#EXT-X-KEY:METHOD=AES-128,URI=\").+(?=\")";
    string = [self modify:keyPattern string:string url:url port:port error:error];
    //  ts替换
    NSString *tsPattern = @".+\\.ts";
    string = [self modify:tsPattern string:string url:url port:port error:error];
    return string;
}

//  替换
+ (NSMutableString *)modify:(NSString *)pattern string:(NSMutableString *)string url:(NSURL *)url port:(NSInteger)port error:(NSError **)error {
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:error];
    //
    NSRange range = NSMakeRange(0, string.length);
    
    //  取出第一个匹配的，看是相对路径还是绝对路径
    NSRange firstRange = [regexp rangeOfFirstMatchInString:string options:0 range:range];
    if (firstRange.location == NSNotFound) {
        return string;
    }
    NSString *firstRangeText = [string substringWithRange:firstRange];
    //  是否是绝对路径
    BOOL isAbsolute = [firstRangeText hasPrefix:@"http"];
    
    
    NSArray<NSTextCheckingResult *> *results = [regexp matchesInString:string options:0 range:range];
    //  倒序修改
    for (NSInteger i = results.count - 1; i >= 0; i--) {
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
        NSURL *localURL = M3U8LocalForRemote(remoteURL, port);
        [string replaceCharactersInRange:result.range withString:localURL.absoluteString];
    }
    return string;
}

@end
