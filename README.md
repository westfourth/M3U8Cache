# M3U8Cache

m3u8缓存、预缓存

## 依赖

``` ruby
pod 'GCDWebServer'
```

## 启动本地服务器

``` objc
//  启动服务器
_webServer = [GCDWebServer new];
[M3U8Cache addHandlerForWebServer:_webServer port:M3U8_SERVER_PORT];
[_webServer startWithPort:M3U8_SERVER_PORT bonjourName:nil];
```

## 缓存使用

将远程url转换成本地url，放入播放器中即可。

``` objc
    NSURL *url = [NSURL URLWithString:@"http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8"];
    NSURL *localURL = M3U8LocalForRemote(url, M3U8_SERVER_PORT);
    
    AVPlayer *player = [AVPlayer playerWithURL:localURL];
    [player play];
    self.player = player;
```

## 预缓存使用

``` objc
    NSURL *url = [NSURL URLWithString:@"http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8"];
    [[M3U8PreCache share] preCache:url];
```

## 重要：可选函数

**可选函数只有方法声明、没有方法实现。**

**可选函数为预留扩展，应该根据具体业务实现。**

可选函数列表：

- `M3U8KeyParentPath`  
- `M3U8RequestAddAdditionalInfo`
