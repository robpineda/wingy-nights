//  SpriteAppDelegate.h
//  Wingy Nights
//
//  Created by Roberto Pineda on 9/15/13.
//  Updated last on 02/23/2018
//  Copyright (c) 2014 Roberto Pineda. All rights reserved.

#import <SpriteKit/SpriteKit.h>
#import <stdint.h>

@interface MainScene : SKScene

@property (strong, nonatomic) SKTexture *textureCharacter, *textureCharacterLight, *textureCharacterAwake, *textureEnemy, *textureEnemyCounter, *textureEnemyLight,
*textureEnemyCounterLight, *textureSoundBeginLow, *textureSoundEndHigh, *textureWindParticle, *textureTitle,
*textureButtonPlay, *textureButtonScores, *textureButtonHome, *textureButtonReplay, *textureButtonPause,
*textureBackgroundStarsOne, *textureBackgroundStarsTwo, *textureBackgroundStarsThree, *textureBackgroundSpeedLines;

@property (strong, nonatomic)
SKTextureAtlas *characterSleepingAtlas, *enemyBlueAtlas, *enemyGreenAtlas, *enemyRedAtlas,
*enemyOrangeAtlas, *enemyPurpleAtlas, *enemyCounterAtlas;


- (id)initWithSize:(CGSize)size;
- (void)didMoveToView:(SKView *)view;
- (void)buildWorld;
- (void)createNodeTree;
- (void)createCharacter;
- (SKSpriteNode *)createEnemyWithColor:(NSInteger)color;
- (void)createBackground;
- (void)createBackgroundStarsImages;
- (void)createWindEmitter;
- (SKSpriteNode *)createSpriteSoundRandomHigh;
- (SKSpriteNode *)createSpriteSoundBeginLowWithColor:(NSInteger)color;
- (void)createButtonPause;
- (void)createLabelPaused;
- (void)update:(NSTimeInterval)currentTime;
- (void)didSimulatePhysics;
- (void)didBeginContact:(SKPhysicsContact *)contact;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)teleportToRow: (NSInteger)row;
- (void)spawnEnemiesRowZero;
- (void)spawnEnemiesRowOne;
- (void)spawnEnemiesRowTwo;
- (void)spawnEnemiesRowThree;
- (void)spawnEnemiesRowFour;
- (void)createMenu;
- (void)rotateCharacterWhenLoosing;
- (void)showFinalScoreLabelsAndButtons;
- (void)hideFinalScoreLabelsAndButtons;
- (void)resetEverything;
- (NSInteger)getRandomRow;
- (CGFloat)getRandomDurationToWait;
- (NSInteger)getRandomForEndSound;
- (NSInteger)getRandomForBeginSound;
- (CGPoint)getSpriteSoundHighRandomPosition:(CGSize)spriteSize;
- (void)createActionsForUserData;
- (void)createSFXForUserData;
- (void)createTonesForUserData;
- (void)updateScores;


@end
