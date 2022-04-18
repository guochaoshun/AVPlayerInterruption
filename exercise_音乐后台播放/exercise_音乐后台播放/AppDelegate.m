//
//  AppDelegate.m
//  exercise_音乐后台播放
//
//  Created by 弄潮者 on 15/8/4.
//  Copyright (c) 2015年 弄潮者. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSLog(@"xxxxxxxxx");
    
    
    
    
    NSLog(@"aaaaaaaa");

    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"backgroundTimeRemaining - %@",@(application.backgroundTimeRemaining));
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"第二次- backgroundTimeRemaining - %@",@(application.backgroundTimeRemaining));
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}






@end
