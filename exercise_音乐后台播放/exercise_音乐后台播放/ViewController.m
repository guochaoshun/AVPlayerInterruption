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
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;


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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruptionAction:) name:AVAudioSessionInterruptionNotification object:nil];

}
- (IBAction)playAction:(id)sender {
    if (self.player.rate == 0) {
        [self.player play];
        _isPlayingNow = YES;
        NSLog(@"播放");
    } else {
        [self.player pause];
        _isPlayingNow = NO;
        NSLog(@"暂停");
    }
    
}

- (void)interruptionAction:(NSNotification *)noti {
    NSLog(@"-interruptionAction %@",noti);
    if ([noti.userInfo[AVAudioSessionInterruptionWasSuspendedKey] boolValue] == YES) {
        NSLog(@"因为被挂起而打断");
        if (self.switchButton.isOn) {
            if (self.player.rate == 0) {
                [self.player play];
                _isPlayingNow = YES;
                self.infoLabel.text = @"尝试播放";
                NSLog(@"尝试播放");
            }
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
                [self playAction:nil];
                NSLog(@"接受到远程控制 - 播放");
                break;
            case UIEventSubtypeRemoteControlPause:
                [self playAction:nil];
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

/**

 正常的期望应该是点击一次就可以播放了, 而且也尝试了在没有挂起的情况下,确实是点击一次就可以完成播放. 那为什么挂起状态下需要点击2次呢?

 经过排查, 发现系统在第一次点击播放时,显示了此行log. 这是app被挂起时,AVPlayer发出的通知
 AVAudioSession.mm:2285:-[AVAudioSession privateInterruptionWithInfo:]: Posting AVAudioSessionInterruptionNotification (Begin Interruption). Was suspended:1


 操作1: 进入app -> 开始播放 -> 暂停 -> 退后台 -> 下拉查看锁屏信息,
 这时候竟然会触发AVAudioSessionInterruptionNotification通知, 由于上面加的代码被执行, 播放器开始播放声音了, 但是用户并没有任何播放操作,

 操作2:进入app -> 开始播放 -> 暂停 -> 下拉查看锁屏信息 -> 退后台, ->  下拉查看锁屏信息, 点击播放(此时会受到AVAudioSessionInterruptionNotification通知), 正常播放



                      iOS12                                                iOS 14
 操作1+挂起通知无操作        下拉无声音播放,点击可以播放          下拉无声音播放,点击可以播放
 操作2+挂起通知无操作        下拉无声音播放,点击可以播放          下拉无声音播放,点击可以播放
 操作1+挂起通知尝试播放    下拉无声音播放,点击可以播放           下拉有声音播放,异常
 操作2+挂起通知尝试播放     下拉无声音播放,点击可以播放          下拉无声音播放,点击可以播放


 猜测iOS14系统在获取锁屏上的播放器信息是懒加载的, 第一次获取播放信息的同时给app分配了一点CPU时间,然后在操作1下触发了通知,进而开始播放.

 所以所以所以, 还是不要在通知中自作聪明做什么事情了, 这个就当成系统的一个bug吧. 同时看了iOS12的设备上其他的app,也是需要点击2次才能播放的,那就这样吧.
 */
