//  SpriteAppDelegate.h
//  Wingy Nights
//
//  Created by Roberto Pineda on 9/15/13.
//  Updated last on 02/23/2018
//  Copyright (c) 2014 Roberto Pineda. All rights reserved.

#import <SpriteKit/SpriteKit.h>
#import <GameKit/GameKit.h>

@interface ScoresScene : SKScene

@property (strong, nonatomic) SKTexture *textureCharacter, *textureCharacterLight, *textureButtonGameCenter,
*textureEnemy, *textureEnemyLight, *textureBackgroundStarsOne, *textureBackgroundStarsTwo,
*textureBackgroundStarsThree, *textureWindParticle, *textureButtonArrowUp,
*textureButtonActivated, *textureButtonDeactivated;

@property (strong, nonatomic)
SKTextureAtlas *characterSleepingAtlas, *enemyGreenAtlas, *enemyRedAtlas,
*enemyOrangeAtlas, *enemyPurpleAtlas;

- (id)initWithSize:(CGSize)size;
- (void) didMoveToView:(SKView *)view;
- (void)showiAdBanner;
- (void)hideiAdBanner;
- (void)buildWorld;
- (void)createAllLabels;
- (SKLabelNode *) createStandartLabel;
- (void)createButtonGameCenter;

@end
