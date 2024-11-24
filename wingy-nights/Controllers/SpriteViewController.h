//  SpriteAppDelegate.h
//  Wingy Nights
//
//  Created by Roberto Pineda on 9/15/13.
//  Updated last on 02/23/2018
//  Copyright (c) 2014 Roberto Pineda. All rights reserved.

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <GameKit/GameKit.h>
#import "MainScene.h"
#import <iAd/iAd.h>

@interface SpriteViewController : UIViewController

- (void)viewDidLoad;
- (BOOL)shouldAutorotate;
- (void)didReceiveMemoryWarning;
- (BOOL)prefersStatusBarHidden;

@end
