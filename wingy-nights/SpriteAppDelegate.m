//  SpriteAppDelegate.h
//  Wingy Nights
//
//  Created by Roberto Pineda on 9/15/13.
//  Copyright (c) 2014 Roberto Pineda. All rights reserved.

#import <SpriteKit/SpriteKit.h>
#import "SpriteAppDelegate.h"
#import "MainScene.h"

@implementation SpriteAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //Authenticate local player on Game Center
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //Set enemies evaded the first time
    if([defaults objectForKey:@"DefaultsMostEvaded2"] == nil) {
        NSLog(@"DefaultsMostEvaded2 Key does not exist.");
        [defaults setInteger:0 forKey:@"DefaultsMostEvaded2"];
    }
    
    //Set total Evaded on defaults
    if([defaults objectForKey:@"DefaultsTotalEvaded"] == nil) {
        NSLog(@"DefaultsTotalEvaded Key does not exist.");
        [defaults setInteger:0 forKey:@"DefaultsTotalEvaded"];
    }
    
    //ICLOUD
    NSUbiquitousKeyValueStore *iCloudStore = [NSUbiquitousKeyValueStore defaultStore];
    
    // Register to observe notifications from the store
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector (storeDidChange:)
     name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification
     object: iCloudStore];

    [iCloudStore removeObjectForKey:@"iCloudMostEvaded2"];
    [iCloudStore removeObjectForKey:@"iCloudTotalEvaded"];
    
    [iCloudStore synchronize];
    
    return YES;
}

- (void)storeDidChange:(NSNotification *)notification
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUbiquitousKeyValueStore *iCloudStore = [NSUbiquitousKeyValueStore defaultStore];
    NSInteger defaultsMostEvaded = [defaults integerForKey:@"DefaultsMostEvaded2"];
    NSInteger defaultsTotalEvaded = [defaults integerForKey:@"DefaultsTotalEvaded"];
    NSInteger iCloudMostEvaded = (NSInteger)[iCloudStore longLongForKey:@"iCloudMostEvaded2"];
    NSInteger iCloudTotalEvaded = (NSInteger)[iCloudStore longLongForKey:@"iCloudTotalEvaded"];
    
    //Replace defaults value with iCLoud value if iCLoud value is bigger
    if(iCloudMostEvaded > defaultsMostEvaded) {
        NSLog(@"[ICLOUD] iCLoud most evaded is bigger");
        [defaults setInteger:iCloudMostEvaded forKey:@"DefaultsMostEvaded2"];
    } else if (defaultsMostEvaded > iCloudMostEvaded) {
        NSLog(@"[ICLOUD] Defaults most evaded is bigger");
        [iCloudStore setLongLong:defaultsMostEvaded forKey:@"iCloudMostEvaded2"];
    }
    
    if(iCloudTotalEvaded > defaultsTotalEvaded) {
        NSLog(@"[ICLOUD] iCLoud total evaded is bigger");
        [defaults setInteger:iCloudTotalEvaded forKey:@"DefaultsTotalEvaded"];
    } else if (defaultsTotalEvaded > iCloudTotalEvaded) {
        NSLog(@"[ICLOUD] Defaults total evaded is bigger");
        [iCloudStore setLongLong:defaultsTotalEvaded forKey:@"iCloudTotalEvaded"];
    }
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    SKView *view = (SKView *)self.window.rootViewController.view;
    view.paused = YES;
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    SKView *view = (SKView *)self.window.rootViewController.view;
    
    //CLASSIC SCENE
    //unpause the whole view but pause the currently presented scene when returning to the game when the user was playing
    if ([view.scene.name isEqualToString:@"MainScene"] && [defaults boolForKey:@"DefaultsIsGamePlaying"] == YES) {
        view.paused = NO;
        view.scene.paused = YES;
        
        //Create the paused label when coming back to app
        MainScene *mainScene = (MainScene *)view.scene;
        if([mainScene childNodeWithName:@"LabelPaused"] == nil) {
            [mainScene createLabelPaused];
        }
    } else {
        view.paused = NO;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
