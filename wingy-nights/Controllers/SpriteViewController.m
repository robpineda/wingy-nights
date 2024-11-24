//  SpriteAppDelegate.h
//  Wingy Nights
//
//  Created by Roberto Pineda on 9/15/13.
//  Updated last on 02/23/2018
//  Copyright (c) 2014 Roberto Pineda. All rights reserved.

#import "SpriteViewController.h"
#import "MainScene.h"
#import "ScoresScene.h"

@interface SpriteViewController() {
    BOOL didCreateAdView;
    BOOL isiAdBannerVisible;
    BOOL isiAdFailingToReceiveAds;
    
    BOOL isiPad, isiPhone5, isiPhone4;
}

@end

@implementation SpriteViewController

- (void)viewDidLoad
{
    self.view = [[SKView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [super viewDidLoad];
    
    //Add view controller as observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"hideAd" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"showAd" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"hideAdMob" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"showAdMob" object:nil];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setBool:NO forKey:@"DefaultsIsLocalPlayerAuthenticated"];
    [defaults setBool:NO forKey:@"DefaultsIsGamePlaying"];
    
    //Set the audio defaults
    [defaults setBool:YES forKey:@"DefaultsIsTonesOn"];
    [defaults setBool:YES forKey:@"DefaultsIsSFXOn"];
    
    [self authenticateLocalPlayer];
    
    didCreateAdView = NO;
    isiAdBannerVisible = NO;
    isiAdFailingToReceiveAds = YES;
    
    // Configure the view.
    SKView *skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGFloat width = screenRect.size.width * screenScale;
    CGFloat height = screenRect.size.height * screenScale;
    
    CGSize viewSize = CGSizeMake(width, height);
    
    // Create and configure the scene.
    MainScene *mainScene = [[MainScene alloc]initWithSize:viewSize];
    mainScene.scaleMode = SKSceneScaleModeAspectFit;
    
    // Present the scene.
    [skView presentScene:mainScene];
}

- (void) authenticateLocalPlayer
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    __weak GKLocalPlayer *blockLocalPlayer = localPlayer;
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil)
        {
            NSLog(@"Presenting authentication view controller");
            [self presentViewController:viewController animated:YES completion:nil];
        }
        else if (blockLocalPlayer.isAuthenticated)
        {
            [defaults setBool:YES forKey:@"DefaultsIsLocalPlayerAuthenticated"];
            NSLog(@"Player is now authenticated");
        }
        else
        {
            NSLog(@"Player could not be authenticated");
        }
    };
}

//Handle Notification
- (void)handleNotification:(NSNotification *)notification
{
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
