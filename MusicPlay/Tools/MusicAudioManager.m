//
//  MusicAudioManager.m
//  MusicPlay
//
//  Created by lanou on 1/26/16.
//  Copyright © 2016 Leon. All rights reserved.
//

#import "MusicAudioManager.h"
#import <AVFoundation/AVFoundation.h>
@interface MusicAudioManager ()

@property (nonatomic, strong) AVPlayer *avplayer;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation MusicAudioManager
+ (instancetype)shareManager
{
    static MusicAudioManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[MusicAudioManager alloc] init];
        }
    });
    return manager;
}
// 根据URL获取当前歌曲的路径
- (NSString *)returnSongPathWithURL:(NSString *)url
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *filePath = [libraryPath stringByAppendingPathComponent:@"Songs"];
    
    [fm createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:NULL];
    
    NSString *songName = [url substringFromIndex:60];
    
    NSString *songPath = [filePath stringByAppendingFormat:@"/%@", songName];
    return songPath;
    
}


- (void)setMusicAudioWithMusicUrl:(NSString *)musicUrl
{
    if (self.avplayer.currentItem) {
        [self.avplayer.currentItem removeObserver:self forKeyPath:@"status"];
    }
    self.currentURL = musicUrl;
    
    NSFileManager *fm = [NSFileManager defaultManager];

    
    NSString *songPath = [self returnSongPathWithURL:self.currentURL];
    if ([fm fileExistsAtPath:songPath]) {
        NSURL *localURL = [NSURL fileURLWithPath:songPath];
//        AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:localURL];
        AVAsset *asset = [AVAsset assetWithURL:localURL];
//        NSLog(@"%@", localURL);
        AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:asset];
        [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [self.avplayer replaceCurrentItemWithPlayerItem:item];
    }
    else
    {
        dispatch_queue_t concurrent = dispatch_queue_create("concurrent", DISPATCH_QUEUE_CONCURRENT);
        
        
        
        dispatch_async(concurrent, ^{
            NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:musicUrl]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [fm createFileAtPath:songPath contents:data attributes:nil];
                
            });
        });
        
        NSLog(@"%@", songPath);
        
        
        
        AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:musicUrl]];
        AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:asset];
        [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [self.avplayer replaceCurrentItemWithPlayerItem:item];
    }
    
    
    
}
- (AVPlayer *)avplayer
{
    if (!_avplayer) {
        _avplayer = [[AVPlayer alloc] init];
        
    }
    return _avplayer;
}
// 观察方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    NSInteger new = [change[@"new"] integerValue];
    switch (new) {
        case AVPlayerItemStatusFailed:
            NSLog(@"AVPlayerItemStatusFailed");
            // 删除下载的内容
        {
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm removeItemAtPath:[self returnSongPathWithURL:self.currentURL] error:nil];
        }
            
            break;
        case AVPlayerItemStatusUnknown:
            NSLog(@"AVPlayerItemStatusUnknown");
            break;
        case AVPlayerStatusReadyToPlay:
            NSLog(@"AVPlayerStatusReadyToPlay");
            [self play];
            break;
        default:
            break;
    }
}
- (void)play
{
    if ([_timer isValid]) {
        [_avplayer play];
        self.isPlaying = YES;
        return;
    }
    [_avplayer play];
    self.isPlaying = YES;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerHandle) userInfo:nil repeats:YES];
}
- (void)timerHandle
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayWithProgress:)]) {
        // 获取当前时间(秒)
        float seconds = self.avplayer.currentTime.value / self.avplayer.currentTime.timescale;
        // 调用代理方法
        [_delegate audioPlayWithProgress:seconds];
    }
}
- (void)pause
{
    [_avplayer pause];
    self.isPlaying = NO;
    [_timer invalidate];
    _timer = nil;
}
- (BOOL)isplayCurrentAudioWithURL:(NSString *)url
{
    NSString *currentURL = [[((AVURLAsset *)self.avplayer.currentItem.asset) URL] absoluteString];
    return [currentURL isEqualToString:url];
}
// 音量的setter getter方法
- (void)setVolume:(float)volume
{
    self.avplayer.volume = volume;
}
- (float)volume
{
    return self.avplayer.volume;
}
- (void)seekToTimePlay:(float)time
{
    [self.avplayer seekToTime:CMTimeMakeWithSeconds(time, self.avplayer.currentTime.timescale)];
}

- (NSInteger)returnCurrentTime
{
    NSInteger second = self.avplayer.currentTime.value / self.avplayer.currentTime.timescale;
    return second;
}

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioEndHandle) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}
- (void)audioEndHandle
{
    // 播放完成通知里 响应代理方法 回到VC处理
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayEndtime)]) {
        [_delegate audioPlayEndtime];
    }
}


@end
