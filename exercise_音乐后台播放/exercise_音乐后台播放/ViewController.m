//
//  ViewController.m
//  exercise_音乐后台播放
//
//  Created by 弄潮者 on 15/8/4.
//  Copyright (c) 2015年 弄潮者. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController () {
    BOOL _isPlayingNow;
}

@property(nonatomic, strong) AVPlayer *player;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    设置后台播放
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
//    设置播放器
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"那些花儿" ofType:@"mp3"] ];
    _player = [[AVPlayer alloc] initWithURL:url];
    [_player play];
    _isPlayingNow = YES;
    
    //后台播放显示信息设置
    [self setPlayingInfo];


    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_player pause];
    });

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruptionAction:) name:AVAudioSessionInterruptionNotification object:nil];

}

- (void)interruptionAction:(NSNotification *)noti {
    NSLog(@"-interruptionAction %@",noti);
    if ([noti.userInfo[AVAudioSessionInterruptionWasSuspendedKey] boolValue] == YES) {
        NSLog(@"因为被挂起而打断");
        if (self.player.rate == 0) {
            [self.player play];
            _isPlayingNow = YES;
        }
    }

//typedef NS_ENUM(NSUInteger, AVAudioSessionInterruptionReason) {
//    AVAudioSessionInterruptionReasonDefault         = 0,
//    AVAudioSessionInterruptionReasonAppWasSuspended = 1,
//    AVAudioSessionInterruptionReasonBuiltInMicMuted = 2
//} NS_SWIFT_NAME(AVAudioSession.InterruptionReason);
}


#pragma mark - 接收方法的设置
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {

    if (event.type == UIEventTypeRemoteControl) {  //判断是否为远程控制
        switch (event.subtype) {
            case  UIEventSubtypeRemoteControlPlay:
                if (!_isPlayingNow) {
                    [_player play];
                }
                _isPlayingNow = !_isPlayingNow;
                NSLog(@"接受到远程控制 - 播放");
                break;
            case UIEventSubtypeRemoteControlPause:
                if (_isPlayingNow) {
                    [_player pause];
                }
                _isPlayingNow = !_isPlayingNow;
                NSLog(@"接受到远程控制 - 暂停");
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                NSLog(@"接受到远程控制 - 下一首");
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                NSLog(@"接受到远程控制 - 上一首 ");
                break;
            default:
                break;
        }
    }
}

- (void)setPlayingInfo {
//    设置后台播放时显示的东西，例如歌曲名字，图片等
//    <MediaPlayer/MediaPlayer.h>
    MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"pushu.jpg"]];
    
    NSDictionary *dic = @{MPMediaItemPropertyTitle:@"那些花儿",
                          MPMediaItemPropertyArtist:@"朴树",
                          MPMediaItemPropertyArtwork:artWork
                          };
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dic];
}

- (void)viewDidAppear:(BOOL)animated {
//    接受远程控制
    [self becomeFirstResponder];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void)viewDidDisappear:(BOOL)animated {
//    取消远程控制
    [self resignFirstResponder];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

@end
