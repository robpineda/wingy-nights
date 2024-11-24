//  SpriteAppDelegate.h
//  Wingy Nights
//
//  Created by Roberto Pineda on 9/15/13.
//  Updated last on 02/23/2018
//  Copyright (c) 2014 Roberto Pineda. All rights reserved.

#import "SpriteViewController.h"
#import "ScoresScene.h"
#import "MainScene.h"

static const uint32_t categoryCharacter = 0x1 << 0;
static const uint32_t categoryEnemy =	  0x1 << 1;

//#define DEGREES_TO_RADIANS(degrees) ((M_PI * degrees)/ 180)

#pragma mark Properties and Implementations
@interface MainScene() <SKPhysicsContactDelegate>
	
@property (nonatomic, assign) CGFloat separationBetweenLines;
@property (nonatomic, assign) CGFloat toBetweenRows;
@property (nonatomic, assign) CGFloat enemyDuration;
@property (nonatomic, assign) CGFloat initialEnemyDuration;
@property (nonatomic, assign) NSInteger counterEnemies, counterBeforeEffect;
@property (nonatomic, assign) NSInteger effectNumber;
@property (nonatomic, assign) CGFloat minX, maxX, midX, minY, maxY, midY;

@property (nonatomic, assign) BOOL rowZeroOccupied, rowOneOccupied, rowTwoOccupied, rowThreeOccupied, rowFourOccupied, rowFiveOccupied;
@property (nonatomic, assign) BOOL didCollideWithEnemyZero, didCollideWithEnemyOne, didCollideWithEnemyTwo, didCollideWithEnemyThree, didCollideWithEnemyFour;
@property (nonatomic, assign) BOOL starsCanBeAdded, isGameOver, isInMenu;
@property (nonatomic, assign) BOOL isButtonHomeOrReplayAlreadyPressed, isButtonPlayAlreadyPressed;
@property (nonatomic, assign) BOOL didAlreadyCollide;
@property (nonatomic, assign) BOOL canEnemyRowTwoBeAdded;
@property (nonatomic, assign) BOOL isInEffect;
@property (nonatomic, assign) BOOL isNewHighScore, isNewEvaded;
@property (nonatomic, assign) BOOL canEffectBeAdded;

@end

@implementation MainScene

@synthesize textureCharacter, textureCharacterLight, textureCharacterAwake, textureEnemy, textureEnemyCounter, textureEnemyLight,
textureEnemyCounterLight, textureSoundBeginLow, textureSoundEndHigh, textureWindParticle, textureTitle;

@synthesize
textureButtonPlay, textureButtonScores, textureButtonHome,
textureButtonReplay, textureButtonPause, textureBackgroundStarsOne, textureBackgroundStarsTwo,
textureBackgroundStarsThree, textureBackgroundSpeedLines;

@synthesize characterSleepingAtlas, enemyBlueAtlas, enemyGreenAtlas, enemyRedAtlas,
enemyOrangeAtlas, enemyPurpleAtlas, enemyCounterAtlas;

#pragma mark -

#pragma mark Initializing Scene
-(id)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if(self)
    {
		[self removeAllActions];
		[self removeAllChildren];
		self.name = @"MainScene";
		[self preloadTextures];
		[self buildWorld];
	}
    return self;
}

- (void)didMoveToView:(SKView *)view
{
	
}

-(void) buildWorld
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	//Scene Properties
	self.anchorPoint = CGPointMake(self.minX, self.minY);
	self.physicsWorld.contactDelegate = self; //Assign the contact delegate to the scene
	self.backgroundColor = [SKColor blackColor];
	self.userData = [NSMutableDictionary dictionary];
	
	self.minX = CGRectGetMinX(self.frame);
    self.maxX = CGRectGetMaxX(self.frame);
    self.midX = CGRectGetMidX(self.frame);
    self.minY = CGRectGetMinY(self.frame);
    self.maxY = CGRectGetMaxY(self.frame);
    self.midY = CGRectGetMidY(self.frame);
	
    self.initialEnemyDuration = 7.0;
    self.enemyDuration = self.initialEnemyDuration;
	
	//create Nodes to group other nodes
	[self createNodeTree];
	
    self.separationBetweenLines = (self.maxY - ((self.maxY / 6) / 2)) / 5; //Separation between each lines that make a row
    self.toBetweenRows = self.separationBetweenLines/2; //Used to position the characters in the middle of a row
	
	//Create objects to store in User Data (Actions first, then other nodes)
	[self createActionsForUserData]; //Action
	
	//If defaults has SFX On
	if([defaults boolForKey:@"DefaultsIsSFXOn"] == YES) {
		[self createSFXForUserData];
	}
	
	[self createTonesForUserData];
	[self createColorsForUserData];
	
	[self createBackground];
	[self createBackgroundStarsImages];
	[self createCharacter];
	[self createLabelEnemiesEvaded];
	
	[self createMenu];
	[self createWindEmitter];
	
	[self spawnEnemiesRowZero];
	[self spawnEnemiesRowOne];
	[self spawnEnemiesRowThree];
	[self spawnEnemiesRowFour];
	
    self.counterEnemies = 0; //Amount of enemies passed, used to increment difficulty (enemyDuration)
	
    self.rowZeroOccupied = NO;
    self.rowOneOccupied = NO;
    self.rowTwoOccupied = NO;
    self.rowThreeOccupied = NO;
    self.rowFourOccupied = NO;
    self.rowFiveOccupied = NO;
    self.counterBeforeEffect = 0; //Counter of enemies that set when a wave of stars appear
    self.starsCanBeAdded = YES;
	
    self.didCollideWithEnemyZero = NO;
    self.didCollideWithEnemyOne = NO;
    self.didCollideWithEnemyTwo = NO;
    self.didCollideWithEnemyThree = NO;
    self.didCollideWithEnemyFour = NO;
	
    self.isNewHighScore = NO;
    self.isNewEvaded = NO;
	
    self.isButtonHomeOrReplayAlreadyPressed = NO;
    self.isButtonPlayAlreadyPressed = NO;
    self.isGameOver = YES;
    self.isInMenu = YES;
    self.didAlreadyCollide = NO;
    self.canEnemyRowTwoBeAdded = YES;
    self.isInEffect = NO;
    self.effectNumber = 0;
}
#pragma mark -

#pragma mark Create Node Tree
- (void)createNodeTree
{
	//SKNode for Character
	SKNode *nodeCharacter= [SKNode node];
	nodeCharacter.userData = [NSMutableDictionary dictionary];
	nodeCharacter.name = @"SKNodeCharacter";
	[self addChild:nodeCharacter];
	
	//SKNode for Sprites of sounds
	SKNode *nodeSpriteSounds= [SKNode node];
	nodeSpriteSounds.userData = [NSMutableDictionary dictionary];
	nodeSpriteSounds.name = @"SKNodeSpriteSounds";
	[self addChild:nodeSpriteSounds];
	
	//SKNode for enemies
	SKNode *nodeEnemies= [SKNode node];
	nodeEnemies.userData = [NSMutableDictionary dictionary];
	nodeEnemies.name = @"SKNodeEnemies";
	[self addChild:nodeEnemies];
	
	//SKNode for the final labels and buttons
	SKNode *nodeFinalLabelsAndButtons = [SKNode node];
	nodeFinalLabelsAndButtons.userData = [NSMutableDictionary dictionary];
	nodeFinalLabelsAndButtons.name = @"SKNodeFinalLabelsAndButtons";
	[self addChild:nodeFinalLabelsAndButtons];
	
	//SKNode for the Menu labels and buttons
	SKNode *nodeMenu = [SKNode node];
	nodeMenu.userData = [NSMutableDictionary dictionary];
	nodeMenu.name = @"SKNodeMenu";
	[self addChild:nodeMenu];
	
	//SKNode for Background Stars images
	SKNode *nodeBackgroundStars = [SKNode node];
	nodeBackgroundStars.userData = [NSMutableDictionary dictionary];
	nodeBackgroundStars.name = @"SKNodeBackgroundStars";
	[self addChild:nodeBackgroundStars];
	
	//SKNode for otherbackgrounds
	SKNode *nodeOtherBackgrounds = [SKNode node];
	nodeOtherBackgrounds.userData = [NSMutableDictionary dictionary];
	nodeOtherBackgrounds.name = @"SKNodeOtherBackgrounds";
	[self addChild:nodeOtherBackgrounds];
	
    //SKNode for Colors
    SKNode *nodeColors = [SKNode node];
	nodeColors.userData = [NSMutableDictionary dictionary];
	nodeColors.name = @"SKNodeColors";
    nodeColors.zPosition = 2.0;
	[self addChild:nodeColors];
}

#pragma mark -


#pragma mark Create Nodes
-(void)createCharacter
{
	SKNode *nodeCharacter = [self childNodeWithName:@"SKNodeCharacter"];
	
    SKSpriteNode *character = [[SKSpriteNode alloc]initWithTexture:textureCharacter];
	SKSpriteNode *characterLight = [[SKSpriteNode alloc]initWithTexture:textureCharacterLight];
	character.position = CGPointMake(self.maxX/12, self.separationBetweenLines*2 + self.toBetweenRows);
    character.zPosition = 3.0;
    character.name = @"Character";
	
	[character addChild:characterLight];
	[characterLight runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction scaleTo:0.96 duration:0.6],
																				 [SKAction scaleTo:1.0 duration:0.5]]]]];
	
	[character runAction:[SKAction repeatActionForever:[nodeCharacter.userData valueForKey:@"ActionAnimateCharacterSleeping"]] withKey:@"SKActionAnimateCharacterSleeping"];
	[character runAction:[SKAction repeatActionForever:[self.userData objectForKey:@"ActionUpAndDown"]]withKey:@"SKActionUpAndDown"];
	
    character.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:character.size];
    character.physicsBody.dynamic = NO;
    character.physicsBody.categoryBitMask = categoryCharacter;
	character.physicsBody.contactTestBitMask = categoryEnemy;
    character.physicsBody.restitution = 0.0;
    character.physicsBody.affectedByGravity = NO;
    character.physicsBody.allowsRotation = NO;
    character.anchorPoint = CGPointMake(0.5, 0.5);
	
	[nodeCharacter addChild:character];
}

- (SKSpriteNode *)createEnemyWithColor:(NSInteger)color
{
	SKNode *nodeEnemies = [self childNodeWithName:@"SKNodeEnemies"];
	SKSpriteNode *enemy = [[SKSpriteNode alloc] initWithTexture:textureEnemy];
	SKSpriteNode *enemyLight = [[SKSpriteNode alloc] initWithTexture:textureEnemyLight];
	enemy.zPosition = 3.0;
	
	enemy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:enemy.size];
	enemy.physicsBody.dynamic = YES;
	enemy.physicsBody.affectedByGravity = NO;
	enemy.physicsBody.allowsRotation = NO;
	enemy.physicsBody.categoryBitMask = categoryEnemy;
	enemy.physicsBody.contactTestBitMask = categoryCharacter;
	
	[enemy addChild:enemyLight];
	[enemyLight runAction:[nodeEnemies.userData valueForKey:@"ActionScaleEnemyLight"]];
	
	//Switch for colors (0 = blue, 1 = green, 2 = red, 3 = orange, 4 = purple)
	switch (color) {
		case 0:
			[enemy runAction:[SKAction repeatActionForever:[nodeEnemies.userData objectForKey:@"ActionAnimateBlueEnemy"]]];
			break;
		case 1:
			[enemy runAction:[SKAction repeatActionForever:[nodeEnemies.userData objectForKey:@"ActionAnimateGreenEnemy"]]];
			break;
		case 2:
			[enemy runAction:[SKAction repeatActionForever:[nodeEnemies.userData objectForKey:@"ActionAnimateRedEnemy"]]];
			break;
		case 3:
			[enemy runAction:[SKAction repeatActionForever:[nodeEnemies.userData objectForKey:@"ActionAnimateOrangeEnemy"]]];
			break;
		case 4:
			[enemy runAction:[SKAction repeatActionForever:[nodeEnemies.userData objectForKey:@"ActionAnimatePurpleEnemy"]]];
			break;
		default:
			break;
	}
	
	if(self.isInEffect == YES) {
		switch (self.effectNumber) {
			case 1:
				[enemy runAction:[SKAction repeatActionForever:[nodeEnemies.userData valueForKey:@"ActionEffectEnemyScale"]]];
				break;
			case 2:
				[enemy runAction:[SKAction repeatActionForever:[nodeEnemies.userData valueForKey:@"ActionEffectEnemySpeedOne"]]];
				break;
			case 3:
				[enemy runAction:[SKAction repeatActionForever:[nodeEnemies.userData valueForKey:@"ActionEffectEnemySpeedTwo"]]];
				break;
			case 4:
				[enemy runAction:[nodeEnemies.userData valueForKey:@"ActionEffectEnemyScaleBig"]];
				break;
			case 5:
				[enemy runAction:[SKAction repeatActionForever:[nodeEnemies.userData valueForKey:@"ActionEffectEnemyFade"]]];
				break;
			default:
				break;
		}
	}
	
	return enemy;
}

- (void) createLabelEnemiesEvaded
{
	//Display Test Labels
	SKLabelNode *labelEnemiesEvaded = [[SKLabelNode alloc] initWithFontNamed:@"launica"];
	labelEnemiesEvaded.color = [SKColor whiteColor];
	labelEnemiesEvaded.zPosition = 4.0;
	labelEnemiesEvaded.text = @"0";
	labelEnemiesEvaded.fontSize = 40;
	labelEnemiesEvaded.name = @"LabelEnemiesEvaded";
	labelEnemiesEvaded.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
	
    labelEnemiesEvaded.position = CGPointMake(self.maxX - (self.maxX/14), self.maxY - (self.maxY/6)/2);
	
    labelEnemiesEvaded.hidden = YES;
	labelEnemiesEvaded.alpha = 0.0;
	[self addChild:labelEnemiesEvaded];
}

-(void) createBackground
{
	SKSpriteNode *background = [[SKSpriteNode alloc] initWithColor:[SKColor colorWithRed:24.0/255.0 green:55.0/255.0 blue:78.0/255.0 alpha:1.0] size:CGSizeMake(CGRectGetMaxX(self.frame), CGRectGetMaxY(self.frame))];
	background.name = @"SpriteBackground";
	background.userData = [NSMutableDictionary dictionary];
	background.zPosition = 0.0;
	background.anchorPoint = CGPointMake(0, 0);
	
	[self addChild:background];
}

- (void)createBackgroundStarsImages
{
	SKNode *nodeBackgroundStars = [self childNodeWithName:@"SKNodeBackgroundStars"];
	
	SKSpriteNode *backgroundStarsOne = [[SKSpriteNode alloc]initWithTexture:textureBackgroundStarsOne];
	backgroundStarsOne.name = @"BackgroundStarsOne";
	backgroundStarsOne.zPosition = 1.0;
	backgroundStarsOne.anchorPoint = CGPointMake(1.0, 0.5);
	backgroundStarsOne.position = CGPointMake(self.maxX, self.midY);
	
	SKSpriteNode *backgroundStarsTwo = [[SKSpriteNode alloc]initWithTexture:textureBackgroundStarsTwo];
	backgroundStarsTwo.name = @"BackgroundStarsTwo";
	backgroundStarsTwo.zPosition = 1.0;
	backgroundStarsTwo.anchorPoint = CGPointMake(1.0, 0.5);
	backgroundStarsTwo.position = CGPointMake(self.maxX*2, self.midY);
	
	SKSpriteNode *backgroundStarsThree = [[SKSpriteNode alloc]initWithTexture:textureBackgroundStarsThree];
	backgroundStarsThree.name = @"BackgroundStarsThree";
	backgroundStarsThree.zPosition = 1.0;
	backgroundStarsThree.anchorPoint = CGPointMake(1.0, 0.5);
	backgroundStarsThree.position = CGPointMake(self.maxX*3, self.midY);
	
	[nodeBackgroundStars addChild:backgroundStarsOne];
	[nodeBackgroundStars addChild:backgroundStarsTwo];
	[nodeBackgroundStars addChild:backgroundStarsThree];
	
	//Action colorizing background stars One //Blue, Red, Yellow 55, 14, 92
	SKAction *colorizeBackgroundStarsOne = [SKAction sequence:@[
                                                                [SKAction colorizeWithColor:[SKColor colorWithRed:255.0/255.0 green:214.0/255.0 blue:92.0/255.0 alpha:1.0] colorBlendFactor:1.0 duration:0.5],
                                                                [SKAction waitForDuration:4.0],
                                                                [SKAction colorizeWithColor:[SKColor colorWithRed:255.0/255.0 green:92.0/255.0 blue:133.0/255.0 alpha:1.0] colorBlendFactor:1.0 duration:0.5],
                                                                [SKAction waitForDuration:4.0],
                                                                [SKAction colorizeWithColor:[SKColor colorWithRed:92.0/255.0 green:133.0/255.0 blue:255.0/255.0 alpha:1.0] colorBlendFactor:1.0 duration:0.5],
                                                                [SKAction waitForDuration:4.0]
                                                                ]];
	//Action colorizing background stars Two //Orange, Purple, Green
	SKAction *colorizeBackgroundStarsTwo = [SKAction sequence:@[
																[SKAction colorizeWithColor:[SKColor colorWithRed:255.0/255.0 green:133.0/255.0 blue:92.0/255.0 alpha:1.0] colorBlendFactor:1.0 duration:0.5],
																[SKAction waitForDuration:4.0],
																[SKAction colorizeWithColor:[SKColor colorWithRed:122.0/255.0 green:189.0/255.0 blue:255.0/255.0 alpha:1.0] colorBlendFactor:1.0 duration:0.5],
																[SKAction waitForDuration:4.0],
																[SKAction colorizeWithColor:[SKColor colorWithRed:92.0/255.0 green:255.0/255.0 blue:133.0/255.0 alpha:1.0] colorBlendFactor:1.0 duration:0.5],
																[SKAction waitForDuration:4.0]
																]];
	
	//Action colorizing background stars Two
	SKAction *colorizeBackgroundStarsThree = [SKAction sequence:@[
                                                                  [SKAction colorizeWithColor:[SKColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] colorBlendFactor:1.0 duration:0.5],
                                                                  [SKAction waitForDuration:4.0],
                                                                  [SKAction colorizeWithColor:[SKColor colorWithRed:122.0/255.0 green:255.0/255.0 blue:189.0/255.0 alpha:1.0] colorBlendFactor:1.0 duration:0.5],
                                                                  [SKAction waitForDuration:4.0],
                                                                  [SKAction colorizeWithColor:[SKColor colorWithRed:255.0/255.0 green:122.0/255.0 blue:122.0/255.0 alpha:1.0] colorBlendFactor:1.0 duration:0.5],
                                                                  [SKAction waitForDuration:4.0]
                                                                  ]];
	
	//Action alpha stars
	SKAction *alphaStars = [SKAction sequence:@[[SKAction fadeAlphaTo:0.7 duration:0.5],
												[SKAction fadeInWithDuration:0.5]]];
	
	
	
	
	
	[backgroundStarsOne runAction:[SKAction repeatActionForever:colorizeBackgroundStarsOne]];
	[backgroundStarsTwo runAction:[SKAction repeatActionForever:colorizeBackgroundStarsTwo]];
	[backgroundStarsThree runAction:[SKAction repeatActionForever:colorizeBackgroundStarsThree]];
    
	[backgroundStarsOne runAction:[SKAction repeatActionForever:alphaStars]];
	[backgroundStarsTwo runAction:[SKAction repeatActionForever:alphaStars]];
	[backgroundStarsThree runAction:[SKAction repeatActionForever:alphaStars]];
}

- (void) createBackgroundSpeedLines
{
	SKNode *nodeOtherBackgrounds = [self childNodeWithName:@"SKNodeOtherBackgrounds"];
	
	SKSpriteNode *backgroundSpeedLines = [[SKSpriteNode alloc] initWithTexture:textureBackgroundSpeedLines];
	backgroundSpeedLines.name = @"BackgroundSpeedLines";
	backgroundSpeedLines.position = CGPointMake(self.midX, self.midY);
	backgroundSpeedLines.alpha = 0.0;
	backgroundSpeedLines.zPosition = 2.0; //Above the background stars
	[backgroundSpeedLines runAction:[nodeOtherBackgrounds.userData valueForKey:@"ActionFadeInSpeedLines"]];
	[backgroundSpeedLines runAction:[SKAction repeatActionForever:[nodeOtherBackgrounds.userData valueForKey:@"ActionRotateSpeedLines"]]];
    
	[nodeOtherBackgrounds addChild:backgroundSpeedLines];
}

- (void)createWindEmitter {
    NSURL *emitterPath = [[NSBundle mainBundle] URLForResource:@"WindEmitter" withExtension:@"sks"];
    if (!emitterPath) {
        NSLog(@"Could not find WindEmitter.sks");
        return;
    }

    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:emitterPath options:NSDataReadingMappedIfSafe error:&error];
    if (!data) {
        NSLog(@"Error reading WindEmitter.sks: %@", error.localizedDescription);
        return;
    }

    SKEmitterNode *windEmitter = [NSKeyedUnarchiver unarchivedObjectOfClass:[SKEmitterNode class] fromData:data error:&error];
    if (!windEmitter) {
        NSLog(@"Error unarchiving SKEmitterNode: %@", error.localizedDescription);
        return;
    }

    // Set properties
    windEmitter.name = @"WindEmitter";
    windEmitter.zPosition = 3.0;
    windEmitter.particlePosition = CGPointMake(self.maxX, self.midY);
    windEmitter.particlePositionRange = CGVectorMake(0, self.maxY);
    windEmitter.particleSpeed = (self.size.width / self.enemyDuration);

    [self addChild:windEmitter];
}

-(SKSpriteNode *) createSpriteSoundRandomHigh
{
	SKSpriteNode *spriteSoundRandomHigh = [[SKSpriteNode alloc] initWithTexture:textureSoundEndHigh];
	spriteSoundRandomHigh.name = @"SpriteSoundEndHigh";
	spriteSoundRandomHigh.zPosition = 2.0;
	spriteSoundRandomHigh.position = [self getSpriteSoundHighRandomPosition:spriteSoundRandomHigh.size];
	return spriteSoundRandomHigh;
}

-(SKSpriteNode *)createSpriteSoundBeginLowWithColor:(NSInteger)color
{
	SKNode *nodeColors = [self childNodeWithName:@"SKNodeColors"];
	
	SKSpriteNode *spriteSoundBeginLow = [[SKSpriteNode alloc]initWithTexture:textureSoundBeginLow];
	spriteSoundBeginLow.name = @"SpriteSoundBeginLow";
	spriteSoundBeginLow.zPosition = 2.0;
	spriteSoundBeginLow.colorBlendFactor = 1.0;
	
	switch (color) {
		case 0: //Blue
			spriteSoundBeginLow.color = [nodeColors.userData valueForKey:@"BlueColor"];
			break;
		case 1: //Green
			spriteSoundBeginLow.color = [nodeColors.userData valueForKey:@"GreenColor"];
			break;
		case 2: //Red
			spriteSoundBeginLow.color = [nodeColors.userData valueForKey:@"RedColor"];
			break;
		case 3: //Orange
			spriteSoundBeginLow.color = [nodeColors.userData valueForKey:@"OrangeColor"];
			break;
		case 4: //Purple
			spriteSoundBeginLow.color = [nodeColors.userData valueForKey:@"PurpleColor"];
			break;
		default:
			break;
	}
	
	return spriteSoundBeginLow;
}

-(void) createButtonPause
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	SKSpriteNode *buttonPause = [[SKSpriteNode alloc] initWithTexture:textureButtonPause];
	buttonPause.name = @"ButtonPause";
	buttonPause.alpha = 0.5;
	buttonPause.anchorPoint = CGPointMake(0.5, 0.5);
	buttonPause.position = CGPointMake(self.minX + buttonPause.size.width/2, self.maxY - buttonPause.size.height/2);
	[self addChild:buttonPause];
	
	[defaults setBool:YES forKey:@"DefaultsIsGamePlaying"];
}

- (void) createEnemyCounter
{
	SKSpriteNode *enemyCounter = [[SKSpriteNode alloc] initWithTexture:textureEnemyCounter];
	SKSpriteNode *enemyCounterLight = [[SKSpriteNode alloc]initWithTexture:textureEnemyCounterLight];
	
	enemyCounter.name = @"EnemyCounter";
	enemyCounter.alpha = 0.0;
	enemyCounter.zPosition = 3.0;
	enemyCounter.position = CGPointMake(self.maxX - enemyCounter.size.width, self.separationBetweenLines * 5 + (self.toBetweenRows/4));
	[enemyCounter runAction:[SKAction repeatActionForever:[self.userData valueForKey:@"ActionAnimateEnemyCounter"]]];
	[enemyCounter runAction:[SKAction fadeInWithDuration:0.3]];
	
	[enemyCounter addChild:enemyCounterLight];
	[enemyCounterLight runAction:[self.userData valueForKey:@"ActionScaleEnemyLight"]];
	
	[self addChild:enemyCounter];
}

- (void)createLabelPaused
{
	SKLabelNode *labelPaused = [[SKLabelNode alloc] initWithFontNamed:@"launica"];
	labelPaused.color = [SKColor whiteColor];
	labelPaused.fontSize = 60;
	labelPaused.zPosition = 4.0;
	labelPaused.name = @"LabelPaused";
	labelPaused.text = @"PAUSED";
	//labelPaused.hidden = YES; //FOR TESTS (DELETE)
	labelPaused.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
	labelPaused.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
	labelPaused.position = CGPointMake(self.midX, self.midY);
	
	[self addChild:labelPaused];
}

#pragma mark Remove Nodes

- (void) removeBackgroundSpeedLines
{
	SKNode *nodeOtherBackgrounds = [self childNodeWithName:@"SKNodeOtherBackgrounds"];
	
	SKNode *backgroundSpeedLines = [nodeOtherBackgrounds childNodeWithName:@"BackgroundSpeedLines"];
	[backgroundSpeedLines runAction:[nodeOtherBackgrounds.userData valueForKey:@"ActionFadeOutSpeedLines"] completion:^{
		[backgroundSpeedLines removeFromParent];
	}];
}

#pragma mark -

#pragma mark Game Loop
-(void)update:(NSTimeInterval)currentTime
{
	SKNode *nodeCharacter = [self childNodeWithName:@"SKNodeCharacter"];
	SKNode *nodeEnemies = [self childNodeWithName:@"SKNodeEnemies"];
	SKNode *nodeBackgroundStars = [self childNodeWithName:@"SKNodeBackgroundStars"];
	SKNode *background = [self childNodeWithName:@"SpriteBackground"];
	
	SKNode *backgroundStarsOne = [nodeBackgroundStars childNodeWithName:@"BackgroundStarsOne"];
	SKNode *backgroundStarsTwo = [nodeBackgroundStars childNodeWithName:@"BackgroundStarsTwo"];
	SKNode *backgroundStarsThree = [nodeBackgroundStars childNodeWithName:@"BackgroundStarsThree"];
	
	SKEmitterNode *windEmitter = (SKEmitterNode *)[self childNodeWithName:@"WindEmitter"];
	SKLabelNode *labelEnemiesEvaded = (SKLabelNode *)[self childNodeWithName:@"LabelEnemiesEvaded"];
	
	SKNode *character = [nodeCharacter childNodeWithName:@"Character"];
	SKNode *enemyZero = [nodeEnemies childNodeWithName:@"EnemyZero"];
	SKNode *enemyOne = [nodeEnemies childNodeWithName:@"EnemyOne"];
	SKNode *enemyThree = [nodeEnemies childNodeWithName:@"EnemyThree"];
	SKNode *enemyFour = [nodeEnemies childNodeWithName:@"EnemyFour"];
	
	//Move the stars backgrounds
	if(backgroundStarsOne.position.x <= self.minX) {
		backgroundStarsOne.position = CGPointMake(backgroundStarsThree.position.x + self.maxX, self.midY);
	}
	
	if(backgroundStarsTwo.position.x <= self.minX) {
		backgroundStarsTwo.position = CGPointMake(backgroundStarsOne.position.x + self.maxX, self.midY);
	}
	
	if(backgroundStarsThree.position.x <= self.minX) {
		backgroundStarsThree.position = CGPointMake(backgroundStarsTwo.position.x + self.maxX, self.midY);
	}
	
	backgroundStarsOne.position = CGPointMake(backgroundStarsOne.position.x - (0.8/self.enemyDuration), backgroundStarsOne.position.y);
	backgroundStarsTwo.position = CGPointMake(backgroundStarsTwo.position.x - (0.8/self.enemyDuration), backgroundStarsTwo.position.y);
	backgroundStarsThree.position = CGPointMake(backgroundStarsThree.position.x - (0.8/self.enemyDuration), backgroundStarsThree.position.y);
	
	//To avoid all of the enemies forming a straight line
	if(self.isInMenu == NO) {
		if(self.canEnemyRowTwoBeAdded == YES) {
			if((enemyZero.position.x == self.midX && enemyZero.position.x > self.midX - self.maxX/6) || (enemyOne.position.x <= self.midX && enemyOne.position.x > self.midX - self.maxX/6) || (enemyThree.position.x <= self.midX && enemyThree.position.x > self.midX - self.maxX/6) || (enemyFour.position.x <= self.midX && enemyFour.position.x > self.midX - self.maxX/6) ) {
                self.canEnemyRowTwoBeAdded = NO;
				[self spawnEnemiesRowTwo];
			}
		}
	}
	
	//After a certain enemies have passed, activate the effect
	if(self.counterBeforeEffect >= 20) {
		[self getRandomEffect];
        self.isInEffect = YES;
        self.counterBeforeEffect = 0;
        
		//self.didAlreadyCollide to avoid this activating after loosing (if any stars appear)
		if(self.didAlreadyCollide == NO) {
			[self createBackgroundSpeedLines];
            self.isInEffect = YES;
			
			//Animate the charactet to be awake
			[character removeActionForKey:@"SKActionAnimateCharacterSleeping"];
			[character runAction:[SKAction setTexture:textureCharacterAwake] withKey:@"SKActionAnimateCharacterAwake"];
			[background runAction:[self.userData valueForKey:@"ActionColorizeToBlack"] withKey:@"SKActionColorizeBackground"]; //Colorize to Black when power up begins
			
			SKAction *waitForDurationBeforeRestoringSpeed = [SKAction waitForDuration:8.0];
			[self runAction:waitForDurationBeforeRestoringSpeed completion:^{
                
				//Execute only when the game is still going and the power up ends
				if(self.isGameOver == NO) {
					[self removeBackgroundSpeedLines];
					[background runAction:[self.userData valueForKey:@"ActionColorizeToNight"] withKey:@"SKActionColorizeBackground"]; //Colorize to night when powerup is over
					[character runAction:[SKAction repeatActionForever:[nodeCharacter.userData valueForKey:@"ActionAnimateCharacterSleeping"]] withKey:@"SKActionAnimateCharacterSleeping"];
				}
				
                self.isInEffect = NO;
                self.counterBeforeEffect = 0;
			}];
			
		}
	}
    
	//Increment velocity of enemy depending on how many have passed
	if(self.isGameOver == NO) {
		if(self.counterEnemies >= 5) { self.enemyDuration = 6.0; }
		if(self.counterEnemies >= 10) { self.enemyDuration = 5.0; }
		if(self.counterEnemies >= 15) { self.enemyDuration = 4.0; }
        if(self.counterEnemies >= 30) { self.enemyDuration = 3.0; }
        if(self.counterEnemies >= 50) { self.enemyDuration = 2.0; }
        if(self.counterEnemies >= 60) { self.enemyDuration = 1.8; }
        if(self.counterEnemies >= 70) { self.enemyDuration = 1.6; }
        if(self.counterEnemies >= 80) { self.enemyDuration = 1.4; }
        if(self.counterEnemies >= 90) { self.enemyDuration = 1.2; }
        if(self.counterEnemies >= 100) { self.enemyDuration = 1.0; }
        
        NSLog(@"Enemy Duration: %f", self.enemyDuration);
	}
    
	if(self.isGameOver == NO) {
		labelEnemiesEvaded.text = [NSString stringWithFormat:@"%ld", (long)self.counterEnemies];
	}
	
	
	windEmitter.particleSpeed = (self.size.width/self.enemyDuration);
}
#pragma mark -

-(void)didSimulatePhysics
{
}

#pragma mark Contacts
-(void)didBeginContact:(SKPhysicsContact *)contact
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	SKNode *buttonPause = [self childNodeWithName:@"ButtonPause"];
	SKNode *nodeCharacter = [self childNodeWithName:@"SKNodeCharacter"];
	SKNode *character = [nodeCharacter childNodeWithName:@"Character"];
	SKNode *labelEnemiesEvaded = [self childNodeWithName:@"LabelEnemiesEvaded"];
	SKNode *enemyCounter = [self childNodeWithName:@"EnemyCounter"];
	
	if((contact.bodyA.categoryBitMask == categoryCharacter) && contact.bodyB.categoryBitMask == categoryEnemy) {
		//Game is Over
		SKNode *enemy = contact.bodyB.node;
		[enemy removeFromParent];
		
		if([enemy.name isEqualToString:@"EnemyZero"]) { self.didCollideWithEnemyZero = YES; }
		if([enemy.name isEqualToString:@"EnemyOne"]) { self.didCollideWithEnemyOne = YES; }
		if([enemy.name isEqualToString:@"EnemyTwo"]) { self.didCollideWithEnemyTwo = YES; }
		if([enemy.name isEqualToString:@"EnemyThree"]) { self.didCollideWithEnemyThree = YES; }
		if([enemy.name isEqualToString:@"EnemyFour"]) { self.didCollideWithEnemyFour = YES; }
		
		self.enemyDuration = self.enemyDuration;
		self.counterBeforeEffect = 0;
		self.effectNumber = 0;
		self.isGameOver = YES;
		self.starsCanBeAdded = NO;
		self.isInEffect = NO;
        
		//>>>>>>>>>TO FIX ANYTHING EXECUTING ITSELF TWICE WHEN HITTING TWO ENEMIES<<<<<<<
		if(self.didAlreadyCollide == NO && self.isInMenu == NO) {
			
            //Remove the Tap Label if is showing
			if([self childNodeWithName:@"LabelTapToEvade"] != nil) {
				SKNode *labelTap = [self childNodeWithName:@"LabelTapToEvade"];
				[labelTap removeFromParent];
			}
			
			//Hide the label score when loosing
			labelEnemiesEvaded.hidden = YES;
			
			[character runAction:[nodeCharacter.userData valueForKey:@"ActionSoundCollision"]];
			
			[buttonPause removeFromParent];
			[enemyCounter removeFromParent];
			[defaults setBool:NO forKey:@"DefaultsIsGamePlaying"];
			
			[self resetLooksWhenColliding];
			[self rotateCharacterWhenLoosing];
			[self updateScores];
			
			SKAction *waitBeforeShowingLabels = [SKAction waitForDuration:0.5];
			[self runAction:waitBeforeShowingLabels completion:^{
				[self showFinalScoreLabelsAndButtons];
			}];
			self.didAlreadyCollide = YES;
		}
		
	}
}
#pragma mark -

#pragma mark Touch Controls
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
	if(self.isGameOver == NO) {
		if(self.paused == NO) {
			if(location.y < self.separationBetweenLines) {
				//Touching first row
				[self teleportToRow:0];
			}
			
			if((location.y > self.separationBetweenLines) && (location.y < self.separationBetweenLines*2)) {
				//Touching second row
				[self teleportToRow:1];
			}
			
			if((location.y > self.separationBetweenLines*2) && (location.y < self.separationBetweenLines*3)) {
				//Touching third row
				[self teleportToRow:2];
			}
			
			if((location.y > self.separationBetweenLines*3) && (location.y < self.separationBetweenLines*4)) {
				//Touching fourth row
				[self teleportToRow:3];
			}
			
			if((location.y > self.separationBetweenLines*4) && (location.y < self.separationBetweenLines*5)) {
				//Touching fifth row
				[self teleportToRow:4];
			}
			
			if((location.y > self.separationBetweenLines*5) && (location.x > self.maxX/4)) {
				[self teleportToRow:4];
			}
		}
	}
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	SKNode *nodeMenu = [self childNodeWithName:@"SKNodeMenu"];
	SKNode *nodeFinalLabelsAndButtons = [self childNodeWithName:@"SKNodeFinalLabelsAndButtons"];
	SKNode *nodeCharacter = [self childNodeWithName:@"SKNodeCharacter"];
	
    UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInNode:self];
	SKNode *background = [self childNodeWithName:@"SpriteBackground"];
	SKNode *buttonPlay = [nodeMenu childNodeWithName:@"ButtonPlay"];
    SKNode *buttonScores = [nodeMenu childNodeWithName:@"ButtonScores"];
    SKNode *spriteTitle = [nodeMenu childNodeWithName:@"SpriteTitle"];
	SKNode *buttonPause = [self childNodeWithName:@"ButtonPause"];
	SKLabelNode *labelEnemiesEvaded = (SKLabelNode *)[self childNodeWithName:@"LabelEnemiesEvaded"];
    
	SKNode *buttonReplay = [nodeFinalLabelsAndButtons childNodeWithName:@"ButtonReplay"];
	SKNode *buttonHome = [nodeFinalLabelsAndButtons childNodeWithName:@"ButtonHome"];
	SKLabelNode *labelFinalScore = (SKLabelNode *)[nodeFinalLabelsAndButtons childNodeWithName:@"LabelFinalScore"];
	SKLabelNode *labelFinalScoreNumber = (SKLabelNode *)[nodeFinalLabelsAndButtons childNodeWithName:@"labelFinalScoreNumber"];
	SKLabelNode *labelFinalScoreLetters = (SKLabelNode *)[nodeFinalLabelsAndButtons childNodeWithName:@"labelFinalScoreLetters"];
	SKLabelNode *labelPreviousHighScoreNumber = (SKLabelNode *)[nodeFinalLabelsAndButtons childNodeWithName:@"labelPreviousHighScoreNumber"];
	SKLabelNode *labelPreviousHighScoreLetters = (SKLabelNode *)[nodeFinalLabelsAndButtons childNodeWithName:@"labelPreviousHighScoreLetters"];
	
	
	SKAction *fadeIn = [SKAction fadeInWithDuration:0.3];
	
	//When the Button Play is pressed, start the game
	if(self.isButtonPlayAlreadyPressed == NO) { //If you press the button, you can not press it again, or any other, while it is disappearing
		if([buttonPlay containsPoint:location]) {
			self.isButtonPlayAlreadyPressed = YES;
			
			self.isGameOver = NO;
			self.isInMenu = NO;
			self.enemyDuration = self.initialEnemyDuration;
			labelEnemiesEvaded.hidden = NO;
			
			[self createEnemyCounter];
			[self createButtonPause];
			
			//Remove any other button and labels
			[labelEnemiesEvaded runAction:fadeIn];
			
			//Play the button sound
			[self runAction:[nodeCharacter.userData valueForKey:@"ActionSoundTeleportTwo"]];
			
            //Scale out the Play Button and make it dissapear
			[buttonPlay runAction:[self.userData valueForKey:@"ActionScaleOutLabelsAndButtons"] completion:^{
				[buttonPlay removeFromParent];
                self.isButtonPlayAlreadyPressed = NO;
			}];
            
            //Scale out the Title and make it dissapear
            [spriteTitle runAction:[self.userData valueForKey:@"ActionScaleOutLabelsAndButtons"] completion:^{
                [spriteTitle removeFromParent];
            }];
            
            //Scale out the Scores Button and make it dissapear
            [buttonScores runAction:[self.userData valueForKey:@"ActionScaleOutLabelsAndButtons"] completion:^{
                [buttonScores removeFromParent];
            }];
            
			//Darken the sky (background) when starting to play
			[background runAction:[self.userData valueForKey:@"ActionColorizeToNight"] withKey:@"SKActionColorizeBackground"];
			
			if(self.didCollideWithEnemyZero == YES) { [self spawnEnemiesRowZero]; self.didCollideWithEnemyZero = NO; }
			if(self.didCollideWithEnemyOne == YES) { [self spawnEnemiesRowOne]; self.didCollideWithEnemyOne = NO; }
			if(self.didCollideWithEnemyTwo == YES) { self.canEnemyRowTwoBeAdded = YES; self.didCollideWithEnemyTwo = NO; }
			if(self.didCollideWithEnemyThree == YES) { [self spawnEnemiesRowThree]; self.didCollideWithEnemyThree = NO; }
			if(self.didCollideWithEnemyFour == YES) { [self spawnEnemiesRowFour]; self.didCollideWithEnemyFour = NO; }
		}
	}
	
	
	//When the Button Home is pressed, start the game
	if(self.isButtonHomeOrReplayAlreadyPressed == NO) { //If you press the button, you can not press it again, or any other, while it is disappearing
		if([buttonHome containsPoint:location]) {
			self.isButtonHomeOrReplayAlreadyPressed = YES;
			
			self.isInMenu = YES;
			self.enemyDuration = self.initialEnemyDuration;
			[self resetEverything]; //Reset all the data
			
			//Play button sound
			[self runAction:[nodeCharacter.userData valueForKey:@"ActionSoundTeleportOne"]];
			
			//Create the menu every time
			[self createMenu];
			labelEnemiesEvaded.hidden = YES;
			labelEnemiesEvaded.alpha = 0.0;
			
			//Remove the rotation from the character and animate back to sleep
			[self resetLooksWhenRepeatingGame];
			
			[background runAction:[self.userData valueForKey:@"ActionColorizeToSunset"] withKey:@"SKActionColorizeBackground"];
			
			//Remove all the Final Score Labels INSTANTLY
			[labelFinalScore removeFromParent];
			[labelFinalScoreLetters removeFromParent];
			[labelFinalScoreNumber removeFromParent];
			[labelPreviousHighScoreNumber removeFromParent];
			[labelPreviousHighScoreLetters removeFromParent];
			[buttonReplay removeFromParent];
			[buttonHome removeFromParent];
			
			self.isButtonHomeOrReplayAlreadyPressed = NO;
		}
	}
	
	//When the button Replay is pressed, reset everything
	if(self.isButtonHomeOrReplayAlreadyPressed == NO) { //If you press the button, you can not press it again, or any other, while it is disappearing
		if([buttonReplay containsPoint:location]) {
			self.isButtonHomeOrReplayAlreadyPressed = YES;
			
			[self createButtonPause];
			[self createEnemyCounter];
			labelEnemiesEvaded.hidden = NO;
			
			//Remove the rotation from the character
			[self resetLooksWhenRepeatingGame];
			
			//Play button sound
			[self runAction:[nodeCharacter.userData valueForKey:@"ActionSoundTeleportOne"]];
			
			//Hide all the Final Score Labels
			[self hideFinalScoreLabelsAndButtons];
			
			[buttonHome runAction:[self.userData valueForKey:@"ActionScaleOutLabelsAndButtons"] completion:^{
				[buttonHome removeFromParent];
			}];
			
			[buttonReplay runAction:[self.userData valueForKey:@"ActionScaleOutLabelsAndButtons"] completion:^{
				
				[buttonReplay removeFromParent];
				self.isButtonHomeOrReplayAlreadyPressed = NO;
				
				[background runAction:[self.userData valueForKey:@"ActionColorizeToNight"] withKey:@"SKActionColorizeBackground"];
				
				//Reset everything
				self.isGameOver = NO;
				self.enemyDuration = self.initialEnemyDuration;
				[self resetEverything];
				
				///Reset the flags of the enemies the character collided with before loosing
				if(self.didCollideWithEnemyZero == YES) { [self spawnEnemiesRowZero]; self.didCollideWithEnemyZero = NO; }
				if(self.didCollideWithEnemyOne == YES) { [self spawnEnemiesRowOne]; self.didCollideWithEnemyOne = NO; }
				if(self.didCollideWithEnemyTwo == YES) { self.canEnemyRowTwoBeAdded = YES; self.didCollideWithEnemyTwo = NO; }
				if(self.didCollideWithEnemyThree == YES) { [self spawnEnemiesRowThree]; self.didCollideWithEnemyThree = NO; }
				if(self.didCollideWithEnemyFour == YES) { [self spawnEnemiesRowFour]; self.didCollideWithEnemyFour = NO; }
			}];
		}
	}
	
	//Pause the game
	if([buttonPause containsPoint:location]) {
		
		if(self.paused == NO) {
			[self createLabelPaused];
			self.paused = YES;
		} else {
			SKNode *labelPaused = [self childNodeWithName:@"LabelPaused"];
			[labelPaused removeFromParent];
			self.paused = NO;
		}
	}
    
    //Show game center when the buttonScores is pressed
    if([buttonScores containsPoint:location]) {
        [self presentScoresScene];
    }
}

-(void) teleportToRow: (NSInteger)row
{
	SKNode *nodeCharacter = [self childNodeWithName:@"SKNodeCharacter"];
	SKNode *character = [nodeCharacter childNodeWithName:@"Character"];
	
    switch (row) {
        case 0:
			[character runAction:[nodeCharacter.userData valueForKey:@"ActionTeleportToRowZero"]];
			[character runAction:[nodeCharacter.userData valueForKey:@"ActionSoundTeleportZero"]];
            break;
        case 1:
            [character runAction:[nodeCharacter.userData valueForKey:@"ActionTeleportToRowOne"]];
			[character runAction:[nodeCharacter.userData valueForKey:@"ActionSoundTeleportOne"]];
            break;
        case 2:
            [character runAction:[nodeCharacter.userData valueForKey:@"ActionTeleportToRowTwo"]];
			[character runAction:[nodeCharacter.userData valueForKey:@"ActionSoundTeleportTwo"]];
            break;
        case 3:
            [character runAction:[nodeCharacter.userData valueForKey:@"ActionTeleportToRowThree"]];
			[character runAction:[nodeCharacter.userData valueForKey:@"ActionSoundTeleportThree"]];
            break;
        case 4:
            [character runAction:[nodeCharacter.userData valueForKey:@"ActionTeleportToRowFour"]];
			[character runAction:[nodeCharacter.userData valueForKey:@"ActionSoundTeleportFour"]];
            break;
        default:
            break;
    }
}
#pragma mark -

#pragma mark Spawn Enemies
- (void) spawnEnemiesRowZero
{
	SKNode *nodeSpriteSounds = [self childNodeWithName:@"SKNodeSpriteSounds"];
	SKNode *nodeEnemies = [self childNodeWithName:@"SKNodeEnemies"];
	
	NSInteger enemyColor = [self getRandomEnemyColor];
	
	SKAction *createAndMoveEnemy = [SKAction runBlock:^{
		SKSpriteNode *enemy = [self createEnemyWithColor:enemyColor];
		enemy.name = @"EnemyZero";
		CGFloat enemyWidth = enemy.size.width;
		CGFloat durationToWait = [self getRandomDurationToWait];
		enemy.position = CGPointMake(self.maxX+enemyWidth, self.minY + self.toBetweenRows);
		[nodeEnemies addChild:enemy];
		
		NSInteger numberSoundOrWait = [self getRandomForBeginSound];
		SKAction *actionSoundOrWait;
		
		//Action block for particle begin low
		SKAction *actionParticleBeginLow = [SKAction runBlock:^{
			SKSpriteNode *spriteSoundBeginLowRight = [self createSpriteSoundBeginLowWithColor:enemyColor];
			spriteSoundBeginLowRight.position = CGPointMake(self.maxX, self.separationBetweenLines * 0 + self.toBetweenRows);
			[nodeSpriteSounds addChild:spriteSoundBeginLowRight];
			[spriteSoundBeginLowRight runAction:[nodeSpriteSounds.userData valueForKey:@"ActionSpriteSound"] completion:^{
				[spriteSoundBeginLowRight removeFromParent];
			}];
			
			//Spawn the sprite for the end sound on the end position (self.minX)
			SKSpriteNode *spriteSoundBeginLowLeft = [self createSpriteSoundBeginLowWithColor:enemyColor];
			spriteSoundBeginLowLeft.position = CGPointMake(self.minX, self.separationBetweenLines * 0 + self.toBetweenRows);
			[nodeSpriteSounds addChild:spriteSoundBeginLowLeft];
			[spriteSoundBeginLowLeft runAction:[nodeSpriteSounds.userData valueForKey:@"ActionSpriteSound"] completion:^{
				[spriteSoundBeginLowLeft removeFromParent];
			}];
		}];
		
		
		//The begin low sound and sprite only appears 2/3 of the time
		if(numberSoundOrWait == 3) {
			actionSoundOrWait = [SKAction group:@[
												  [nodeSpriteSounds.userData valueForKey:@"ActionSoundBeginLowZero"],
												  actionParticleBeginLow]];
		} else {
			if(self.isGameOver == NO) {
				actionSoundOrWait = [SKAction waitForDuration:0.0];
			} else {
				actionSoundOrWait = [SKAction group:@[
													  [nodeSpriteSounds.userData valueForKey:@"ActionSoundBeginLowZero"],
													  actionParticleBeginLow]];
			}
		}
		
		
		SKAction *moveEnemy = [SKAction sequence:@[
												   [SKAction waitForDuration:durationToWait],
												   actionSoundOrWait,
												   actionParticleBeginLow,//play the begin sound or wait 0 seconds
												   [SKAction moveTo:CGPointMake(self.minX - (enemy.size.width / 2), enemy.position.y) duration:self.enemyDuration]
												   ]];
		[enemy runAction:moveEnemy completion:^{
			
			if(self.isGameOver == NO) {
				self.counterEnemies = self.counterEnemies + 1;
				
				if(self.isInEffect == NO) {
					self.counterBeforeEffect += 1;
				}
				
				if([self getRandomForEndSound] == 1) {
					//Play the end sound
					[self runAction:[nodeSpriteSounds.userData valueForKey:@"ActionSoundEndHighZero"]];
					
					//Spawn the sprite for the end sound on random position
					SKSpriteNode *spriteSoundRandomHigh = [self createSpriteSoundRandomHigh];
					[nodeSpriteSounds addChild:spriteSoundRandomHigh];
					[spriteSoundRandomHigh runAction:[nodeSpriteSounds.userData valueForKey:@"ActionSpriteSound"] completion:^{
						[spriteSoundRandomHigh removeFromParent];
						
					}];
				}
			}
			
			[enemy removeFromParent];
			[self spawnEnemiesRowZero];
		}];
	}];
	
	[self runAction:createAndMoveEnemy];
}

- (void) spawnEnemiesRowOne
{
	SKNode *nodeSpriteSounds = [self childNodeWithName:@"SKNodeSpriteSounds"];
	SKNode *nodeEnemies = [self childNodeWithName:@"SKNodeEnemies"];
	
	NSInteger enemyColor = [self getRandomEnemyColor];
	
	SKAction *createAndMoveEnemy = [SKAction runBlock:^{
		SKSpriteNode *enemy = [self createEnemyWithColor:enemyColor];
		enemy.name = @"EnemyOne";
		CGFloat enemyWidth = enemy.size.width;
		CGFloat durationToWait = [self getRandomDurationToWait];
		
		enemy.position = CGPointMake(self.maxX+enemyWidth, self.separationBetweenLines + self.toBetweenRows);
		[nodeEnemies addChild:enemy];
		
		NSInteger numberSoundOrWait = [self getRandomForBeginSound];
		SKAction *actionSoundOrWait;
		
		//Action block for particle begin low
		SKAction *actionParticleBeginLow = [SKAction runBlock:^{
			SKSpriteNode *spriteSoundBeginLowRight = [self createSpriteSoundBeginLowWithColor:enemyColor];
			spriteSoundBeginLowRight.position = CGPointMake(self.maxX, self.separationBetweenLines * 1 + self.toBetweenRows);
			[nodeSpriteSounds addChild:spriteSoundBeginLowRight];
			[spriteSoundBeginLowRight runAction:[nodeSpriteSounds.userData valueForKey:@"ActionSpriteSound"] completion:^{
				[spriteSoundBeginLowRight removeFromParent];
			}];
			
			//Spawn the sprite for the end sound on the end position (self.minX)
			SKSpriteNode *spriteSoundBeginLowLeft = [self createSpriteSoundBeginLowWithColor:enemyColor];
			spriteSoundBeginLowLeft.position = CGPointMake(self.minX, self.separationBetweenLines * 1 + self.toBetweenRows);
			[nodeSpriteSounds addChild:spriteSoundBeginLowLeft];
			[spriteSoundBeginLowLeft runAction:[nodeSpriteSounds.userData valueForKey:@"ActionSpriteSound"] completion:^{
				[spriteSoundBeginLowLeft removeFromParent];
			}];
		}];
		
		//The begin low sound and sprite only appears 2/3 of the time
		if(numberSoundOrWait == 3) {
			actionSoundOrWait = [SKAction group:@[
												  [nodeSpriteSounds.userData valueForKey:@"ActionSoundBeginLowOne"],
												  actionParticleBeginLow]];
		} else {
			if(self.isGameOver == NO) {
				actionSoundOrWait = [SKAction waitForDuration:0.0];
			} else {
				actionSoundOrWait = [SKAction group:@[
													  [nodeSpriteSounds.userData valueForKey:@"ActionSoundBeginLowOne"],
													  actionParticleBeginLow]];
			}
		}
		
		SKAction *moveEnemy = [SKAction sequence:@[
												   [SKAction waitForDuration:durationToWait],
												   actionSoundOrWait,
												   actionParticleBeginLow,
												   [SKAction moveTo:CGPointMake(self.minX - (enemy.size.width / 2), enemy.position.y) duration:self.enemyDuration]
												   ]];
		[enemy runAction:moveEnemy completion:^{
			
			if(self.isGameOver == NO) {
				
				self.counterEnemies = self.counterEnemies + 1;
				
				if(self.isInEffect == NO) {
					self.counterBeforeEffect += 1;
				}
				
				if([self getRandomForEndSound] == 1) {
					//Play the end sound
					[self runAction:[nodeSpriteSounds.userData valueForKey:@"ActionSoundEndHighOne"]];
					
					//Spawn the sprite for the end sound on a random position
					SKSpriteNode *spriteSoundRandomHigh = [self createSpriteSoundRandomHigh];
					[nodeSpriteSounds addChild:spriteSoundRandomHigh];
					[spriteSoundRandomHigh runAction:[nodeSpriteSounds.userData valueForKey:@"ActionSpriteSound"] completion:^{
						[spriteSoundRandomHigh removeFromParent];
						
					}];
				}
			}
			
			[enemy removeFromParent];
			[self spawnEnemiesRowOne];
		}];
	}];
	
	[self runAction:createAndMoveEnemy];
}

- (void) spawnEnemiesRowTwo
{
	SKNode *nodeSpriteSounds = [self childNodeWithName:@"SKNodeSpriteSounds"];
	SKNode *nodeEnemies = [self childNodeWithName:@"SKNodeEnemies"];
	
	NSInteger enemyColor = [self getRandomEnemyColor];
	
	SKAction *createAndMoveEnemy = [SKAction runBlock:^{
		SKSpriteNode *enemy = [self createEnemyWithColor:enemyColor];
		enemy.name = @"EnemyTwo";
		CGFloat enemyWidth = enemy.size.width;
		
		enemy.position = CGPointMake(self.maxX+enemyWidth, self.separationBetweenLines*2 + self.toBetweenRows);
		[nodeEnemies addChild:enemy];
		
		NSInteger numberSoundOrWait = [self getRandomForBeginSound];
		SKAction *actionSoundOrWait;
		
		//Action block for particle begin low
		SKAction *actionParticleBeginLow = [SKAction runBlock:^{
			SKSpriteNode *spriteSoundBeginLowRight = [self createSpriteSoundBeginLowWithColor:enemyColor];
			spriteSoundBeginLowRight.position = CGPointMake(self.maxX, self.separationBetweenLines * 2 + self.toBetweenRows);
			[nodeSpriteSounds addChild:spriteSoundBeginLowRight];
			[spriteSoundBeginLowRight runAction:[nodeSpriteSounds.userData valueForKey:@"ActionSpriteSound"] completion:^{
				[spriteSoundBeginLowRight removeFromParent];
			}];
			
			//Spawn the sprite for the end sound on the end position (self.minX)
			SKSpriteNode *spriteSoundBeginLowLeft = [self createSpriteSoundBeginLowWithColor:enemyColor];
			spriteSoundBeginLowLeft.position = CGPointMake(self.minX, self.separationBetweenLines * 2 + self.toBetweenRows);
			[nodeSpriteSounds addChild:spriteSoundBeginLowLeft];
			[spriteSoundBeginLowLeft runAction:[nodeSpriteSounds.userData valueForKey:@"ActionSpriteSound"] completion:^{
				[spriteSoundBeginLowLeft removeFromParent];
			}];
		}];
		
		//The begin low sound and sprite only appears 2/3 of the time
		if(numberSoundOrWait == 3) {
			actionSoundOrWait = [SKAction group:@[
												  [nodeSpriteSounds.userData valueForKey:@"ActionSoundBeginLowTwo"],
												  actionParticleBeginLow]];
		} else {
			if(self.isGameOver == NO) {
				actionSoundOrWait = [SKAction waitForDuration:0.0];
			} else {
				actionSoundOrWait = [SKAction group:@[
													  [nodeSpriteSounds.userData valueForKey:@"ActionSoundBeginLowTwo"],
													  actionParticleBeginLow]];
			}
		}
		
		SKAction *moveEnemy = [SKAction sequence:@[
												   [SKAction waitForDuration:0],
												   actionSoundOrWait,
												   actionParticleBeginLow,
												   [SKAction moveTo:CGPointMake(self.minX - (enemy.size.width / 2), enemy.position.y) duration:self.enemyDuration]
												   ]];
		[enemy runAction:moveEnemy completion:^{
			
			if(self.isGameOver == NO) {
				
				self.counterEnemies = self.counterEnemies + 1;
				
				if(self.isInEffect == NO) {
					self.counterBeforeEffect += 1;
				}
				
				if([self getRandomForEndSound] == 1) {
					//Play the end sound
					[self runAction:[nodeSpriteSounds.userData valueForKey:@"ActionSoundEndHighTwo"]];
					
					//Spawn the sprite for the end sound on a random position
					SKSpriteNode *spriteSoundRandomHigh = [self createSpriteSoundRandomHigh];
					[nodeSpriteSounds addChild:spriteSoundRandomHigh];
					[spriteSoundRandomHigh runAction:[nodeSpriteSounds.userData valueForKey:@"ActionSpriteSound"] completion:^{
						[spriteSoundRandomHigh removeFromParent];
						
					}];
				}
			}
			
			self.canEnemyRowTwoBeAdded = YES; //To avoid all enemies forming a straight line
			[enemy removeFromParent];
		}];
	}];
	
	[self runAction:createAndMoveEnemy];
}

- (void) spawnEnemiesRowThree
{
	SKNode *nodeSpriteSounds = [self childNodeWithName:@"SKNodeSpriteSounds"];
	SKNode *nodeEnemies = [self childNodeWithName:@"SKNodeEnemies"];
    
	NSInteger enemyColor = [self getRandomEnemyColor];
	
	SKAction *createAndMoveEnemy = [SKAction runBlock:^{
		SKSpriteNode *enemy = [self createEnemyWithColor:enemyColor];
		enemy.name = @"EnemyThree";
		CGFloat enemyWidth = enemy.size.width;
		CGFloat durationToWait = [self getRandomDurationToWait];
		
		enemy.position = CGPointMake(self.maxX+enemyWidth, self.separationBetweenLines*3 + self.toBetweenRows);
		[nodeEnemies addChild:enemy];
		
		NSInteger numberSoundOrWait = [self getRandomForBeginSound];
		SKAction *actionSoundOrWait;
		
		//Action block for particle begin low
		SKAction *actionParticleBeginLow = [SKAction runBlock:^{
			SKSpriteNode *spriteSoundBeginLowRight = [self createSpriteSoundBeginLowWithColor:enemyColor];
			spriteSoundBeginLowRight.position = CGPointMake(self.maxX, self.separationBetweenLines * 3 + self.toBetweenRows);
			[nodeSpriteSounds addChild:spriteSoundBeginLowRight];
			[spriteSoundBeginLowRight runAction:[nodeSpriteSounds.userData valueForKey:@"ActionSpriteSound"] completion:^{
				[spriteSoundBeginLowRight removeFromParent];
			}];
			
			//Spawn the sprite for the end sound on the end position (self.minX)
			SKSpriteNode *spriteSoundBeginLowLeft = [self createSpriteSoundBeginLowWithColor:enemyColor];
			spriteSoundBeginLowLeft.position = CGPointMake(self.minX, self.separationBetweenLines * 3 + self.toBetweenRows);
			[nodeSpriteSounds addChild:spriteSoundBeginLowLeft];
			[spriteSoundBeginLowLeft runAction:[nodeSpriteSounds.userData valueForKey:@"ActionSpriteSound"] completion:^{
				[spriteSoundBeginLowLeft removeFromParent];
			}];
		}];
		
		//The begin low sound and sprite only appears 2/3 of the time
		if(numberSoundOrWait == 3) {
			actionSoundOrWait = [SKAction group:@[
												  [nodeSpriteSounds.userData valueForKey:@"ActionSoundBeginLowThree"],
												  actionParticleBeginLow]];
		} else {
			if(self.isGameOver == NO) {
				actionSoundOrWait = [SKAction waitForDuration:0.0];
			} else {
				actionSoundOrWait = [SKAction group:@[
													  [nodeSpriteSounds.userData valueForKey:@"ActionSoundBeginLowThree"],
													  actionParticleBeginLow]];
			}
		}
		
		SKAction *moveEnemy = [SKAction sequence:@[
												   [SKAction waitForDuration:durationToWait],
												   actionSoundOrWait,
												   actionParticleBeginLow,
												   [SKAction moveTo:CGPointMake(self.minX - (enemy.size.width / 2), enemy.position.y) duration:self.enemyDuration]
												   ]];
		[enemy runAction:moveEnemy completion:^{
			
			if(self.isGameOver == NO) {
				
				self.counterEnemies = self.counterEnemies + 1;
				
				if(self.isInEffect == NO) {
					self.counterBeforeEffect += 1;
					
				}
				
				if([self getRandomForEndSound] == 1) {
					//Play the end sound
					[self runAction:[nodeSpriteSounds.userData valueForKey:@"ActionSoundEndHighThree"]];
					
					//Spawn the sprite for the end sound on a random position
					SKSpriteNode *spriteSoundRandomHigh = [self createSpriteSoundRandomHigh];
					[nodeSpriteSounds addChild:spriteSoundRandomHigh];
					[spriteSoundRandomHigh runAction:[nodeSpriteSounds.userData valueForKey:@"ActionSpriteSound"] completion:^{
						[spriteSoundRandomHigh removeFromParent];
					}];
				}
			}
			
			[enemy removeFromParent];
			[self spawnEnemiesRowThree];
		}];
	}];
	
	[self runAction:createAndMoveEnemy];
}

- (void) spawnEnemiesRowFour
{
	SKNode *nodeSpriteSounds = [self childNodeWithName:@"SKNodeSpriteSounds"];
	SKNode *nodeEnemies = [self childNodeWithName:@"SKNodeEnemies"];
	
	NSInteger enemyColor = [self getRandomEnemyColor];
	
	SKAction *createAndMoveEnemy = [SKAction runBlock:^{
		SKSpriteNode *enemy = [self createEnemyWithColor:enemyColor];
		enemy.name = @"EnemyFour";
		CGFloat enemyWidth = enemy.size.width;
		CGFloat durationToWait = [self getRandomDurationToWait];
		
		enemy.position = CGPointMake(self.maxX+enemyWidth, self.separationBetweenLines*4 + self.toBetweenRows);
		[nodeEnemies addChild:enemy];
		
		NSInteger numberSoundOrWait = [self getRandomForBeginSound];
		SKAction *actionSoundOrWait;
		
		//Action block for particle begin low
		SKAction *actionParticleBeginLow = [SKAction runBlock:^{
			SKSpriteNode *spriteSoundBeginLowRight = [self createSpriteSoundBeginLowWithColor:enemyColor];
			spriteSoundBeginLowRight.position = CGPointMake(self.maxX, self.separationBetweenLines * 4 + self.toBetweenRows);
			[nodeSpriteSounds addChild:spriteSoundBeginLowRight];
			[spriteSoundBeginLowRight runAction:[nodeSpriteSounds.userData valueForKey:@"ActionSpriteSound"] completion:^{
				[spriteSoundBeginLowRight removeFromParent];
			}];
			
			//Spawn the sprite for the end sound on the end position (self.minX)
			SKSpriteNode *spriteSoundBeginLowLeft = [self createSpriteSoundBeginLowWithColor:enemyColor];
			spriteSoundBeginLowLeft.position = CGPointMake(self.minX, self.separationBetweenLines * 4 + self.toBetweenRows);
			[nodeSpriteSounds addChild:spriteSoundBeginLowLeft];
			[spriteSoundBeginLowLeft runAction:[nodeSpriteSounds.userData valueForKey:@"ActionSpriteSound"] completion:^{
				[spriteSoundBeginLowLeft removeFromParent];
			}];
		}];
		
		//The begin low sound and sprite only appears 2/3 of the time
		if(numberSoundOrWait == 3) {
			actionSoundOrWait = [SKAction group:@[
												  [nodeSpriteSounds.userData valueForKey:@"ActionSoundBeginLowFour"],
												  actionParticleBeginLow]];
		} else {
			if(self.isGameOver == NO) {
				actionSoundOrWait = [SKAction waitForDuration:0.0];
			} else {
				actionSoundOrWait = [SKAction group:@[
													  [nodeSpriteSounds.userData valueForKey:@"ActionSoundBeginLowFour"],
													  actionParticleBeginLow]];
			}
		}
		
		SKAction *moveEnemy = [SKAction sequence:@[
												   [SKAction waitForDuration:durationToWait],
												   actionSoundOrWait,
												   actionParticleBeginLow,
												   [SKAction moveTo:CGPointMake(self.minX - (enemy.size.width / 2), enemy.position.y) duration:self.enemyDuration]
												   ]];
		[enemy runAction:moveEnemy completion:^{
			
			if(self.isGameOver == NO) {
				
				self.counterEnemies = self.counterEnemies + 1;
				
				if(self.isInEffect == NO) {
					self.counterBeforeEffect += 1;
				}
				
				if([self getRandomForEndSound] == 1) {
					//Play the end sound
					[self runAction:[nodeSpriteSounds.userData valueForKey:@"ActionSoundEndHighFour"]];
					
					//Spawn the sprite for the end sound on a random position
					SKSpriteNode *spriteSoundRandomHigh = [self createSpriteSoundRandomHigh];
					[nodeSpriteSounds addChild:spriteSoundRandomHigh];
					[spriteSoundRandomHigh runAction:[nodeSpriteSounds.userData valueForKey:@"ActionSpriteSound"] completion:^{
						[spriteSoundRandomHigh removeFromParent];
						
					}];
				}
			}
			
			[enemy removeFromParent];
			[self spawnEnemiesRowFour];
		}];
	}];
	
	[self runAction:createAndMoveEnemy];
}
#pragma mark -

#pragma mark Menu
- (void)createMenu
{
    //A node for all Menu elements (buttonPlay, buttonScores and spriteTitle).
	SKNode *nodeMenu = [self childNodeWithName:@"SKNodeMenu"];
	
    //The Play Button
	SKSpriteNode *buttonPlay = [[SKSpriteNode alloc] initWithTexture:textureButtonPlay];
	buttonPlay.position = CGPointMake(self.midX, self.separationBetweenLines * 2);
	buttonPlay.name = @"ButtonPlay";
	buttonPlay.zPosition = 4.0;
	[nodeMenu addChild:buttonPlay];
	
	//The Button for the Scores and Settings
    SKSpriteNode *buttonScores = [[SKSpriteNode alloc] initWithTexture:textureButtonScores];
    buttonScores.position = CGPointMake(self.maxX - buttonScores.size.width, self.minY + buttonScores.size.height);
    buttonScores.name = @"ButtonScores";
    buttonScores.zPosition = 4.0;
    [nodeMenu addChild:buttonScores];
    
    //The Title logo
    SKSpriteNode *spriteTitle = [[SKSpriteNode alloc] initWithTexture:textureTitle];
    spriteTitle.name = @"SpriteTitle";
    spriteTitle.zPosition = 4.0;
    spriteTitle.position = CGPointMake(self.midX, self.separationBetweenLines * 3 + self.toBetweenRows);
    [nodeMenu addChild:spriteTitle];
	
	
}
#pragma mark -

#pragma mark After Loosing
- (void) rotateCharacterWhenLoosing
{
	SKNode *nodeCharacter = [self childNodeWithName:@"SKNodeCharacter"];
	
	SKNode *character = [nodeCharacter childNodeWithName:@"Character"];
	[character runAction:[SKAction repeatActionForever:[nodeCharacter.userData valueForKey:@"ActionRotateCharacter"]] withKey:@"rotateCharacter"];
}

-(void)showFinalScoreLabelsAndButtons
{
	SKNode *nodeFinalLabelsAndButtons = [self childNodeWithName:@"SKNodeFinalLabelsAndButtons"];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger lastMostEvaded = [defaults integerForKey:@"DefaultsMostEvaded2"];
	
	//Final Score labels
	SKLabelNode *labelFinalScoreLetters = [[SKLabelNode alloc]initWithFontNamed:@"launica"];
	labelFinalScoreLetters.color = [SKColor whiteColor];
	labelFinalScoreLetters.fontSize = 40;
	labelFinalScoreLetters.zPosition = 4.0;
	labelFinalScoreLetters.name = @"labelFinalScoreLetters";
	labelFinalScoreLetters.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
	labelFinalScoreLetters.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
	labelFinalScoreLetters.hidden = YES;
	labelFinalScoreLetters.position = CGPointMake(self.midX, self.separationBetweenLines*3 + self.toBetweenRows);
	
	SKLabelNode *labelFinalScoreNumber = [[SKLabelNode alloc]initWithFontNamed:@"launica"];
	labelFinalScoreNumber = [[SKLabelNode alloc]initWithFontNamed:@"launica"];
	labelFinalScoreNumber.color = [SKColor whiteColor];
	labelFinalScoreNumber.fontSize = 80;
	labelFinalScoreNumber.zPosition = 4.0;
	labelFinalScoreNumber.name = @"labelFinalScoreNumber";
	labelFinalScoreNumber.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
	labelFinalScoreNumber.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
	labelFinalScoreNumber.hidden = YES;
	labelFinalScoreNumber.position = CGPointMake(self.midX, self.separationBetweenLines * 3);
	
	//Previous High Score labels
	SKLabelNode *labelPreviousHighScoreLetters = [[SKLabelNode alloc]initWithFontNamed:@"launica"];
	labelPreviousHighScoreLetters.color = [SKColor whiteColor];
	labelPreviousHighScoreLetters.fontSize = 40;
	labelPreviousHighScoreLetters.zPosition = 4.0;
	labelPreviousHighScoreLetters.name = @"labelPreviousHighScoreLetters";
	labelPreviousHighScoreLetters.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
	labelPreviousHighScoreLetters.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
	labelPreviousHighScoreLetters.hidden = YES;
	labelPreviousHighScoreLetters.position = CGPointMake(self.midX, self.separationBetweenLines*2 + self.toBetweenRows);
	
	SKLabelNode *labelPreviousHighScoreNumber = [[SKLabelNode alloc]initWithFontNamed:@"launica"];
	labelPreviousHighScoreNumber = [[SKLabelNode alloc]initWithFontNamed:@"launica"];
	labelPreviousHighScoreNumber.color = [SKColor whiteColor];
	labelPreviousHighScoreNumber.fontSize = 80;
	labelPreviousHighScoreNumber.zPosition = 4.0;
	labelPreviousHighScoreNumber.name = @"labelPreviousHighScoreNumber";
	labelPreviousHighScoreNumber.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
	labelPreviousHighScoreNumber.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
	labelPreviousHighScoreNumber.hidden = YES;
	labelPreviousHighScoreNumber.position = CGPointMake(self.midX, self.separationBetweenLines * 2);
	
	//Play animations on labels if NEW RECORD
	SKAction *actionNewRecord = [SKAction sequence:@[[SKAction scaleBy:1.3 duration:0.3],
													 [SKAction scaleTo:1.0 duration:0.3]
                                                     ]];
	
	//Button Replay
	SKSpriteNode *buttonReplay = [[SKSpriteNode alloc] initWithTexture:textureButtonReplay];
	buttonReplay.position = CGPointMake(self.midX + buttonReplay.size.width * 0.8, self.separationBetweenLines);
	buttonReplay.name = @"ButtonReplay";
	buttonReplay.zPosition = 4.0;
	buttonReplay.hidden = YES;
	
	//Button Home
	SKSpriteNode *buttonHome = [[SKSpriteNode alloc] initWithTexture:textureButtonHome];
	buttonHome.position = CGPointMake(self.midX - buttonHome.size.width * 0.8, self.separationBetweenLines);
	buttonHome.name = @"ButtonHome";
	buttonHome.zPosition = 4.0;
	buttonHome.hidden = YES;
	
	buttonHome.hidden = NO;
	buttonReplay.hidden = NO;
	[nodeFinalLabelsAndButtons addChild:buttonHome];
	[nodeFinalLabelsAndButtons addChild:buttonReplay];
	[buttonHome runAction:[nodeFinalLabelsAndButtons.userData valueForKey:@"ActionShowLabelsAndButtons"]];
	[buttonReplay runAction:[nodeFinalLabelsAndButtons.userData valueForKey:@"ActionShowLabelsAndButtons"]];
	
	[nodeFinalLabelsAndButtons addChild:labelFinalScoreLetters];
	[nodeFinalLabelsAndButtons addChild:labelFinalScoreNumber];
	[nodeFinalLabelsAndButtons addChild:labelPreviousHighScoreLetters];
	[nodeFinalLabelsAndButtons addChild:labelPreviousHighScoreNumber];
	
	
	labelFinalScoreLetters.text = @"SCORE:";
	labelPreviousHighScoreLetters.text = @"HIGH SCORE:";
	labelFinalScoreNumber.text = [NSString stringWithFormat:@"%ld", (long)self.counterEnemies];
	labelPreviousHighScoreNumber.text = [NSString stringWithFormat:@"%ld", (long)lastMostEvaded];
	
	labelFinalScoreLetters.hidden = NO;
	labelFinalScoreNumber.hidden = NO;
	[labelFinalScoreLetters runAction:[nodeFinalLabelsAndButtons.userData valueForKey:@"ActionShowLabelsAndButtons"]];
	[labelFinalScoreNumber runAction:[nodeFinalLabelsAndButtons.userData valueForKey:@"ActionShowLabelsAndButtons"] completion:^{
		if(self.isNewEvaded) {
			[labelFinalScoreLetters runAction:[SKAction repeatActionForever:actionNewRecord]];
			[labelFinalScoreNumber runAction:[SKAction repeatActionForever:actionNewRecord]];
		}
		
		labelPreviousHighScoreLetters.hidden = NO;
		labelPreviousHighScoreNumber.hidden = NO;
		[labelPreviousHighScoreLetters runAction:[nodeFinalLabelsAndButtons.userData valueForKey:@"ActionShowLabelsAndButtons"]];
		[labelPreviousHighScoreNumber runAction:[nodeFinalLabelsAndButtons.userData valueForKey:@"ActionShowLabelsAndButtons"]];
	}];
}

- (void) hideFinalScoreLabelsAndButtons
{
	SKNode *nodeFinalLabelsAndButtons = [self childNodeWithName:@"SKNodeFinalLabelsAndButtons"];
	
	SKLabelNode *labelFinalScoreNumber = (SKLabelNode *)[nodeFinalLabelsAndButtons childNodeWithName:@"labelFinalScoreNumber"];
	SKLabelNode *labelFinalScoreLetters = (SKLabelNode *)[nodeFinalLabelsAndButtons childNodeWithName:@"labelFinalScoreLetters"];
	SKLabelNode *labelPreviousHighScoreNumber = (SKLabelNode *)[nodeFinalLabelsAndButtons childNodeWithName:@"labelPreviousHighScoreNumber"];
	SKLabelNode *labelPreviousHighScoreLetters = (SKLabelNode *)[nodeFinalLabelsAndButtons childNodeWithName:@"labelPreviousHighScoreLetters"];
	
	[labelFinalScoreLetters runAction:[self.userData valueForKey:@"ActionScaleOutLabelsAndButtons"] completion:^{
		labelFinalScoreLetters.hidden = YES;
		[labelFinalScoreLetters removeFromParent];
	}];
	[labelFinalScoreNumber runAction:[self.userData valueForKey:@"ActionScaleOutLabelsAndButtons"] completion:^{
		labelFinalScoreNumber.hidden = YES;
		[labelFinalScoreNumber removeFromParent];
	}];
	[labelPreviousHighScoreLetters runAction:[self.userData valueForKey:@"ActionScaleOutLabelsAndButtons"] completion:^{
		labelPreviousHighScoreLetters.hidden = YES;
		[labelPreviousHighScoreLetters removeFromParent];
	}];
	[labelPreviousHighScoreNumber runAction:[self.userData valueForKey:@"ActionScaleOutLabelsAndButtons"] completion:^{
		labelPreviousHighScoreNumber.hidden = YES;
		[labelPreviousHighScoreNumber removeFromParent];
	}];
	
}

- (void) resetEverything
{
	self.counterEnemies = 0; //Total enemies evaded
	self.starsCanBeAdded = YES; //If stars are on screen, no stars can be added
	self.counterBeforeEffect = 0; //Counter of enemies before a wave of stars appear
	self.didAlreadyCollide = NO; //To fix the loosing buttons and labels creating themselves twice when hitting two enemies
	self.isInEffect = NO;
	self.isNewHighScore = NO;
	self.isNewEvaded = NO;
	self.effectNumber = 0;
}

#pragma mark Random Generators
- (NSInteger) getRandomRow
{
	NSInteger random = 0 + arc4random() % (4 - 0 + 1); //from + arc4random() % (to - from + 1)
	
	//If random is 0, appears on the first row
	if (random == 0) { random = self.minY; }
	
	return random;
}

- (CGFloat) getRandomDurationToWait
{
	NSInteger random = 0 + arc4random() % (1 - 0 + 1); //from + arc4random() % (to - from + 1)
	return (CGFloat)random;
}

- (void) getRandomEffect
{
	//Effects: Scale = 1, Move up and down = 2, 3
	self.effectNumber = 1 + arc4random() % (5 - 1 + 1); //from + arc4random() % (to - from + 1)
	//self.effectNumber = 3; //for testing
}

- (NSInteger) getRandomForEndSound
{
	NSInteger random = 0 + arc4random() % (2 - 0 + 1); //from + arc4random() % (to - from + 1)
	return random;
}

- (NSInteger) getRandomForBeginSound
{
	NSInteger random = 0 + arc4random() % (3 - 0 + 1); //from + arc4random() % (to - from + 1)
	return random;
}

- (CGPoint) getSpriteSoundHighRandomPosition:(CGSize)spriteSize
{
	NSInteger randomIntX = (NSInteger)(self.minX + spriteSize.width) + arc4random() % ((NSInteger)(self.maxX - spriteSize.width) - (NSInteger)(self.minX + spriteSize.width) + 1); //from + arc4random() % (to - from + 1)
	NSInteger randomIntY = (NSInteger)(self.minY + spriteSize.height) + arc4random() % ((NSInteger)(self.maxY - spriteSize.height) - (NSInteger)(self.minY + spriteSize.height) + 1); //from + arc4random() % (to - from + 1)
	
	CGFloat randomX = (CGFloat)randomIntX;
	CGFloat randomY = (CGFloat)randomIntY;
    
	CGPoint randomPoint = CGPointMake(randomX, randomY);
	
	return randomPoint;
}

-(NSInteger) getRandomEnemyColor
{
	//0 = blue, 1 = green, 2 = red, 3 = orange, 4 = purple
	NSInteger random = 0 + arc4random() % (4 - 0 + 1); //from + arc4random() % (to - from + 1)
	return random;
}

#pragma mark -

#pragma mark Create for UserData

- (void) createActionsForUserData
{
	SKNode *nodeCharacter = [self childNodeWithName:@"SKNodeCharacter"];
	SKNode *nodeEnemies = [self childNodeWithName:@"SKNodeEnemies"];
	SKNode *nodeSpriteSounds = [self childNodeWithName:@"SKNodeSpriteSounds"];
	SKNode *nodeFinalLabelsAndButtons = [self childNodeWithName:@"SKNodeFinalLabelsAndButtons"];
	SKNode *nodeOtherBackgrounds = [self childNodeWithName:@"SKNodeOtherBackgrounds"];
    
    NSArray *enemyRedTextureNames = [enemyRedAtlas textureNames];
    NSArray *enemyGreenTextureNames = [enemyGreenAtlas textureNames];
    NSArray *enemyBlueTextureNames = [enemyBlueAtlas textureNames];
    NSArray *enemyOrangeTextureNames = [enemyOrangeAtlas textureNames];
    NSArray *enemyPurpleTextureNames = [enemyPurpleAtlas textureNames];
    NSArray *enemyCounterTextureNames = [enemyCounterAtlas textureNames];
    NSArray *characterSleepingTextureNames = [characterSleepingAtlas textureNames];
	
	// (Self)Action for going up and down (Shared by Enemies and Character)
	SKAction *upAndDownAnimation = [SKAction sequence:@[
														[SKAction moveBy:CGVectorMake(0.0, self.toBetweenRows/4) duration:0.8],
														[SKAction moveBy:CGVectorMake(0.0, -self.toBetweenRows/4) duration:0.8]]];
    //	SKAction *reverseUpAndDownAnimation = [upAndDownAnimation reversedAction];
    //	SKAction *sequence = [SKAction sequence:@[upAndDownAnimation, reverseUpAndDownAnimation]];
	upAndDownAnimation.timingMode = SKActionTimingEaseInEaseOut;
	[self.userData setValue:upAndDownAnimation  forKey:@"ActionUpAndDown"];
	
	//(Self) Action fade out labels and buttons (Shared by SKNodeFinalLabelsAndButtons and SKNMenuButtons)
	SKAction *fadeOutLabelsAndButtons = [SKAction scaleTo:0.0 duration:0.1];
	[self.userData setValue:fadeOutLabelsAndButtons forKey:@"ActionScaleOutLabelsAndButtons"];
	
	//(self)Show the row separator when pressing play
	SKAction *showRowSeparators = [SKAction sequence:@[
													   [SKAction fadeInWithDuration:0.8],
													   [SKAction fadeOutWithDuration:0.8],
													   ]];
	[self.userData setValue:showRowSeparators forKey:@"ActionShowRowSeparators"];
	
	// (SKNodeCharacter) Action Teleport to row
	SKAction *actionTeleportToRowZero = [SKAction sequence:@[[SKAction scaleTo:0.1 duration:0.06],
															 [SKAction moveTo:CGPointMake(self.maxX/12, self.minY+self.toBetweenRows) duration:0],
															 [SKAction scaleTo:1.0 duration:0.06]]];
	SKAction *actionTeleportToRowOne = [SKAction sequence:@[[SKAction scaleTo:0.1 duration:0.06],
															[SKAction moveTo:CGPointMake(self.maxX/12, self.separationBetweenLines+self.toBetweenRows) duration:0],
															[SKAction scaleTo:1.0 duration:0.06]]];
	SKAction *actionTeleportToRowTwo = [SKAction sequence:@[[SKAction scaleTo:0.1 duration:0.06],
															[SKAction moveTo:CGPointMake(self.maxX/12, self.separationBetweenLines*2+self.toBetweenRows) duration:0],
															[SKAction scaleTo:1.0 duration:0.06]]];
	SKAction *actionTeleportToRowThree = [SKAction sequence:@[[SKAction scaleTo:0.1 duration:0.06],
															  [SKAction moveTo:CGPointMake(self.maxX/12, self.separationBetweenLines*3+self.toBetweenRows) duration:0],
															  [SKAction scaleTo:1.0 duration:0.06]]];
	SKAction *actionTeleportToRowFour = [SKAction sequence:@[[SKAction scaleTo:0.1 duration:0.06],
															 [SKAction moveTo:CGPointMake(self.maxX/12, self.separationBetweenLines*4+self.toBetweenRows) duration:0],
															 [SKAction scaleTo:1.0 duration:0.06]]];
	[nodeCharacter.userData setValue:actionTeleportToRowZero forKey:@"ActionTeleportToRowZero"];
	[nodeCharacter.userData setValue:actionTeleportToRowOne forKey:@"ActionTeleportToRowOne"];
	[nodeCharacter.userData setValue:actionTeleportToRowTwo forKey:@"ActionTeleportToRowTwo"];
	[nodeCharacter.userData setValue:actionTeleportToRowThree forKey:@"ActionTeleportToRowThree"];
	[nodeCharacter.userData setValue:actionTeleportToRowFour forKey:@"ActionTeleportToRowFour"];
	
	// (SKNodeCharacter) Action remove character rotation
	SKAction *rotateCharacter = [SKAction rotateByAngle:5.0 duration:5.0];
	SKAction *removeCharacterRotation = [SKAction rotateToAngle:0 duration:0.3];
	[nodeCharacter.userData setValue:removeCharacterRotation forKey:@"ActionRemoveCharacterRotation"];
	[nodeCharacter.userData setValue:rotateCharacter forKey:@"ActionRotateCharacter"];
	
    // Texture atlas and action for Character Sleeping
    NSMutableArray *characterSleepingTextures = [NSMutableArray arrayWithCapacity:characterSleepingTextureNames.count];
    for (NSString *textureName in characterSleepingTextureNames) {
       SKTexture *texture = [characterSleepingAtlas textureNamed:textureName];
       [characterSleepingTextures addObject:texture];
    }
    SKAction *animateCharacterSleeping = [SKAction animateWithTextures:characterSleepingTextures timePerFrame:0.07 resize:NO restore:YES];
    [nodeCharacter.userData setValue:animateCharacterSleeping forKey:@"ActionAnimateCharacterSleeping"];
    
	// Texture atlas and action for BLUE ENEMY
    NSMutableArray *enemyBlueTextures = [NSMutableArray arrayWithCapacity:enemyBlueTextureNames.count];
    for (NSString *textureName in enemyBlueTextureNames) {
       SKTexture *texture = [enemyBlueAtlas textureNamed:textureName];
       [enemyBlueTextures addObject:texture];
    }
    SKAction *animateBlueEnemy = [SKAction animateWithTextures:enemyBlueTextures timePerFrame:0.07 resize:NO restore:YES];
	[nodeEnemies.userData setValue:animateBlueEnemy forKey:@"ActionAnimateBlueEnemy"];
	
    // Texture atlas and action for GREEN ENEMY
    NSMutableArray *enemyGreenTextures = [NSMutableArray arrayWithCapacity:enemyGreenTextureNames.count];
    for (NSString *textureName in enemyGreenTextureNames) {
       SKTexture *texture = [enemyGreenAtlas textureNamed:textureName];
       [enemyGreenTextures addObject:texture];
    }
    SKAction *animateGreenEnemy = [SKAction animateWithTextures:enemyGreenTextures timePerFrame:0.07 resize:NO restore:YES];
	[nodeEnemies.userData setValue:animateGreenEnemy forKey:@"ActionAnimateGreenEnemy"];
	
    // Texture atlas and action for RED enemy
    NSMutableArray *enemyRedTextures = [NSMutableArray arrayWithCapacity:enemyRedTextureNames.count];
    for (NSString *textureName in enemyRedTextureNames) {
       SKTexture *texture = [enemyRedAtlas textureNamed:textureName];
       [enemyRedTextures addObject:texture];
    }
	SKAction *animateRedEnemy = [SKAction animateWithTextures:enemyRedTextures timePerFrame:0.07 resize:NO restore:YES];
	[nodeEnemies.userData setValue:animateRedEnemy forKey:@"ActionAnimateRedEnemy"];
	
	// Texture atlas and action for ORANGE ENEMY
    NSMutableArray *enemyOrangeTextures = [NSMutableArray arrayWithCapacity:enemyOrangeTextureNames.count];
    for (NSString *textureName in enemyOrangeTextureNames) {
       SKTexture *texture = [enemyOrangeAtlas textureNamed:textureName];
       [enemyOrangeTextures addObject:texture];
    }
    SKAction *animateOrangeEnemy = [SKAction animateWithTextures:enemyOrangeTextures timePerFrame:0.07 resize:NO restore:YES];
	[nodeEnemies.userData setValue:animateOrangeEnemy forKey:@"ActionAnimateOrangeEnemy"];
	
	// Texture atlas and action for PURPLE ENEMY
    NSMutableArray *enemyPurpleTextures = [NSMutableArray arrayWithCapacity:enemyPurpleTextureNames.count];
    for (NSString *textureName in enemyPurpleTextureNames) {
       SKTexture *texture = [enemyPurpleAtlas textureNamed:textureName];
       [enemyPurpleTextures addObject:texture];
    }
	SKAction *animatePurpleEnemy = [SKAction animateWithTextures:enemyPurpleTextures timePerFrame:0.07 resize:NO restore:YES];
	[nodeEnemies.userData setValue:animatePurpleEnemy forKey:@"ActionAnimatePurpleEnemy"];
	
	// Texture atlas and action for EnemyCounter
    NSMutableArray *enemyCounterTextures = [NSMutableArray arrayWithCapacity:enemyCounterTextureNames.count];
    for (NSString *textureName in enemyCounterTextureNames) {
       SKTexture *texture = [enemyCounterAtlas textureNamed:textureName];
       [enemyCounterTextures addObject:texture];
    }
    SKAction *animateEnemyCounter = [SKAction animateWithTextures:enemyCounterTextures timePerFrame:0.07 resize:NO restore:YES];
	[self.userData setValue:animateEnemyCounter forKey:@"ActionAnimateEnemyCounter"];
	
	//(SKNodeEnemies)Scale the light of the enemies
	SKAction *scaleEnemyLight = [SKAction repeatActionForever:[SKAction sequence:@[[SKAction scaleTo:0.96 duration:0.6],
                                                                                   [SKAction scaleTo:1.0 duration:0.5]]]];
	[nodeEnemies.userData setValue:scaleEnemyLight forKey:@"ActionScaleEnemyLight"];
	[self.userData setValue:scaleEnemyLight forKey:@"ActionScaleEnemyLight"];
	
	//(SKNodeEnemies)Effect 1: Scale. Makes enemies bigger and smaller like a bouncing animation
	SKAction *effectEnemyScale = [SKAction sequence:@[[SKAction scaleTo:0.3 duration:0.1],
													  [SKAction scaleTo:1.3 duration:0.1]]];
	[nodeEnemies.userData setValue:effectEnemyScale forKey:@"ActionEffectEnemyScale"];
	
	//(SKNodeEnemies)Effect 2: Speed One. Makes enemies go back and forth
	SKAction *speedOne = [SKAction sequence:@[[SKAction speedTo:0.0 duration:0.0],
											  [SKAction speedTo:1.0 duration:0.3],
											  [SKAction waitForDuration:0.1]]];
	[nodeEnemies.userData setValue:speedOne forKey:@"ActionEffectEnemySpeedOne"];
	
	//(SKNodeEnemies)Effect 3: Speed Two
	SKAction *speedTwo = [SKAction sequence:@[[SKAction speedTo:0.2 duration:0.5],
											  [SKAction speedTo:1.0 duration:0.1]]];
	[nodeEnemies.userData setValue:speedTwo forKey:@"ActionEffectEnemySpeedTwo"];
	
	//(SKNodeEnemies)Effect 4: Scale Big. Makes enemies bigger.
	SKAction *scaleSmall = [SKAction scaleTo:1.5 duration:0.0];
	[nodeEnemies.userData setValue:scaleSmall forKey:@"ActionEffectEnemyScaleBig"];
	
	//(SKNodeEnemies)Effect 5: Fade //Makes enemies transparent
	SKAction *effectEnemyFade = [SKAction sequence:@[[SKAction fadeOutWithDuration:0.0],
													 [SKAction waitForDuration:0.05],
													 [SKAction fadeInWithDuration:0.2],
													 [SKAction waitForDuration:0.2]]];
	[nodeEnemies.userData setValue:effectEnemyFade forKey:@"ActionEffectEnemyFade"];
	
	// (SKNodeFinalLabelsAndButtons) Action show labels and buttons
	SKAction *scaleByTwo = [SKAction scaleBy:1.2 duration:0.1];
	SKAction *showLabelsAndButtonsAction = [SKAction sequence:@[
																[SKAction scaleTo:1.0 duration:0.0],
																[SKAction scaleBy:1.2 duration:0.1],
																[scaleByTwo reversedAction],
																[SKAction waitForDuration:0.1]
																]];
	[nodeFinalLabelsAndButtons.userData setValue:showLabelsAndButtonsAction forKey:@"ActionShowLabelsAndButtons"];
	
	//Change background color to night
	SKAction *colorizeToSunset = [SKAction colorizeWithColor:[SKColor colorWithRed:24.0/255.0 green:55.0/255.0 blue:78.0/255.0 alpha:1.0] colorBlendFactor:1.0 duration:0.5];
	SKAction *colorizeToNight = [SKAction colorizeWithColor:[SKColor colorWithRed:18.0/255.0 green:41.0/255.0 blue:59.0/255.0 alpha:1.0] colorBlendFactor:1.0 duration:0.5];
	SKAction *colorizeToBlack = [SKAction sequence:@[
													 [SKAction colorizeWithColor:[SKColor colorWithRed:30.0/255.0 green:68.0/255.0 blue:98.0/255.0 alpha:1.0] colorBlendFactor:1.0 duration:0.5],
													 [SKAction waitForDuration:0.0],
													 [SKAction colorizeWithColor:[SKColor colorWithRed:12.0/255.0 green:27.0/255.0 blue:39.0/255.0 alpha:1.0] colorBlendFactor:1.0 duration:0.5]]];
	[self.userData setValue:colorizeToNight forKey:@"ActionColorizeToNight"];
	[self.userData setValue:colorizeToSunset forKey:@"ActionColorizeToSunset"];
	[self.userData setValue:colorizeToBlack forKey:@"ActionColorizeToBlack"];
	
	//(SKNodeSpriteSounds) Action Particle Sound End High
	SKAction *actionSpriteSoundFirst = [SKAction scaleBy:0.2 duration:0.1];
	SKAction *actionSpriteSoundSecond = [SKAction group:@[
														  [SKAction scaleTo:1.3 duration:3.0],
														  [SKAction fadeOutWithDuration:3.0]
														  ]];
	SKAction *actionSpriteSound = [SKAction sequence:@[actionSpriteSoundFirst, actionSpriteSoundSecond]];
	[nodeSpriteSounds.userData setValue:actionSpriteSound forKey:@"ActionSpriteSound"];
    
	//(SKNodeOtherBackgrounds) fade in  and out the speed lines
	SKAction *fadeInSpeedLines = [SKAction fadeInWithDuration:0.5];
	SKAction *fadeOutSpeedLines = [SKAction fadeOutWithDuration:0.5];
	[nodeOtherBackgrounds.userData setValue:fadeInSpeedLines forKey:@"ActionFadeInSpeedLines"];
	[nodeOtherBackgrounds.userData setValue:fadeOutSpeedLines forKey:@"ActionFadeOutSpeedLines"];
	
	//(SKNodeOtherBackgrounds) rotate the speed lines
	SKAction *rotateSpeedLines = [SKAction rotateByAngle:1.0 duration:4.0];
	[nodeOtherBackgrounds.userData setValue:rotateSpeedLines forKey:@"ActionRotateSpeedLines"];
}

- (void)createSFXForUserData
{
	SKNode *nodeCharacter = [self childNodeWithName:@"SKNodeCharacter"];
	
	//(SKNodeCharacter) Teleport sounds
	SKAction *actionSoundTeleportZero = [SKAction playSoundFileNamed:@"SoundTeleportZero.m4a" waitForCompletion:NO];
	SKAction *actionSoundTeleportOne = [SKAction playSoundFileNamed:@"SoundTeleportOne.m4a" waitForCompletion:NO];
	SKAction *actionSoundTeleportTwo = [SKAction playSoundFileNamed:@"SoundTeleportTwo.m4a" waitForCompletion:NO];
	SKAction *actionSoundTeleportThree = [SKAction playSoundFileNamed:@"SoundTeleportThree.m4a" waitForCompletion:NO];
	SKAction *actionSoundTeleportFour = [SKAction playSoundFileNamed:@"SoundTeleportFour.m4a" waitForCompletion:NO];
	[nodeCharacter.userData setValue:actionSoundTeleportZero forKey:@"ActionSoundTeleportZero"];
	[nodeCharacter.userData setValue:actionSoundTeleportOne forKey:@"ActionSoundTeleportOne"];
	[nodeCharacter.userData setValue:actionSoundTeleportTwo forKey:@"ActionSoundTeleportTwo"];
	[nodeCharacter.userData setValue:actionSoundTeleportThree forKey:@"ActionSoundTeleportThree"];
	[nodeCharacter.userData setValue:actionSoundTeleportFour forKey:@"ActionSoundTeleportFour"];
	
	//(SKNodeCharacter)
	SKAction *actionSoundCollision = [SKAction playSoundFileNamed:@"SoundCollision.m4a" waitForCompletion:NO];
	[nodeCharacter.userData setValue:actionSoundCollision forKey:@"ActionSoundCollision"];
}

- (void) createTonesForUserData
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	SKNode *nodeSpriteSounds = [self childNodeWithName:@"SKNodeSpriteSounds"];
	
	//Tones Begin
	SKAction *actionSoundBeginLowZero;
	SKAction *actionSoundBeginLowOne;
	SKAction *actionSoundBeginLowTwo;
	SKAction *actionSoundBeginLowThree;
	SKAction *actionSoundBeginLowFour;
	
	//Tones End
	SKAction *actionSoundEndHighZero;
	SKAction *actionSoundEndHighOne;
	SKAction *actionSoundEndHighTwo;
	SKAction *actionSoundEndHighThree;
	SKAction *actionSoundEndHighFour;
	
	//If defaults has Harp Sounds On, play the sounds
	if([defaults boolForKey:@"DefaultsIsTonesOn"] == YES) {
		//Tones (Begin Low)
		actionSoundBeginLowZero = [SKAction playSoundFileNamed:@"SoundBeginLowZero.m4a" waitForCompletion:NO];
		actionSoundBeginLowOne = [SKAction playSoundFileNamed:@"SoundBeginLowOne.m4a" waitForCompletion:NO];
		actionSoundBeginLowTwo = [SKAction playSoundFileNamed:@"SoundBeginLowTwo.m4a" waitForCompletion:NO];
		actionSoundBeginLowThree = [SKAction playSoundFileNamed:@"SoundBeginLowThree.m4a" waitForCompletion:NO];
		actionSoundBeginLowFour = [SKAction playSoundFileNamed:@"SoundBeginLowFour.m4a" waitForCompletion:NO];
		
		//Tones (End High)
		actionSoundEndHighZero = [SKAction playSoundFileNamed:@"SoundEndHighZero.m4a" waitForCompletion:NO];
		actionSoundEndHighOne = [SKAction playSoundFileNamed:@"SoundEndHighOne.m4a" waitForCompletion:NO];
		actionSoundEndHighTwo = [SKAction playSoundFileNamed:@"SoundEndHighTwo.m4a" waitForCompletion:NO];
		actionSoundEndHighThree = [SKAction playSoundFileNamed:@"SoundEndHighThree.m4a" waitForCompletion:NO];
		actionSoundEndHighFour = [SKAction playSoundFileNamed:@"SoundEndHighFour.m4a" waitForCompletion:NO];
	}
	
	//If defaults has Harp Sounds Off, dont play the sounds by giving the action a duration to wait of zero (doing nothing)
	if([defaults boolForKey:@"DefaultsIsTonesOn"] == NO) {
		//Tones Begin
		actionSoundBeginLowZero = [SKAction waitForDuration:0.0];
		actionSoundBeginLowOne = [SKAction waitForDuration:0.0];
		actionSoundBeginLowTwo = [SKAction waitForDuration:0.0];
		actionSoundBeginLowThree = [SKAction waitForDuration:0.0];
		actionSoundBeginLowFour = [SKAction waitForDuration:0.0];
		
		//Tones End
		actionSoundEndHighZero = [SKAction waitForDuration:0.0];
		actionSoundEndHighOne = [SKAction waitForDuration:0.0];
		actionSoundEndHighTwo = [SKAction waitForDuration:0.0];
		actionSoundEndHighThree = [SKAction waitForDuration:0.0];
		actionSoundEndHighFour = [SKAction waitForDuration:0.0];
	}
	
	
	[nodeSpriteSounds.userData setValue:actionSoundBeginLowZero forKey:@"ActionSoundBeginLowZero"];
	[nodeSpriteSounds.userData setValue:actionSoundBeginLowOne forKey:@"ActionSoundBeginLowOne"];
	[nodeSpriteSounds.userData setValue:actionSoundBeginLowTwo forKey:@"ActionSoundBeginLowTwo"];
	[nodeSpriteSounds.userData setValue:actionSoundBeginLowThree forKey:@"ActionSoundBeginLowThree"];
	[nodeSpriteSounds.userData setValue:actionSoundBeginLowFour forKey:@"ActionSoundBeginLowFour"];
	
	[nodeSpriteSounds.userData setValue:actionSoundEndHighZero forKey:@"ActionSoundEndHighZero"];
	[nodeSpriteSounds.userData setValue:actionSoundEndHighOne forKey:@"ActionSoundEndHighOne"];
	[nodeSpriteSounds.userData setValue:actionSoundEndHighTwo forKey:@"ActionSoundEndHighTwo"];
	[nodeSpriteSounds.userData setValue:actionSoundEndHighThree forKey:@"ActionSoundEndHighThree"];
	[nodeSpriteSounds.userData setValue:actionSoundEndHighFour forKey:@"ActionSoundEndHighFour"];
}

- (void)createColorsForUserData
{
	SKNode *nodeColors = [self childNodeWithName:@"SKNodeColors"];
	
	SKColor *blueColor = [SKColor colorWithRed:76.0/255.0 green:208.0/255.0 blue:255.0/255.0 alpha:1.0];
	SKColor *greenColor = [SKColor colorWithRed:69.0/255.0 green:255.0/255.0 blue:236.0/255.0 alpha:1.0];
	SKColor *redColor = [SKColor colorWithRed:255.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0];
	SKColor *orangeColor = [SKColor colorWithRed:212.0/255.0 green:126.0/255.0 blue:76.0/255.0 alpha:1.0];
	SKColor *purpleColor = [SKColor colorWithRed:181.0/255.0 green:152.0/255.0 blue:255.0/255.0 alpha:1.0];
	
	[nodeColors.userData setValue:blueColor forKey:@"BlueColor"];
	[nodeColors.userData setValue:greenColor forKey:@"GreenColor"];
	[nodeColors.userData setValue:redColor forKey:@"RedColor"];
	[nodeColors.userData setValue:orangeColor forKey:@"OrangeColor"];
	[nodeColors.userData setValue:purpleColor forKey:@"PurpleColor"];
}
#pragma mark -

#pragma mark Presenting Scenes
- (void) presentMainScene
{
	CGSize viewSize = CGSizeMake(CGRectGetMaxX(self.frame), CGRectGetMaxY(self.frame));
	MainScene *mainScene = [[MainScene alloc]initWithSize:viewSize];
	mainScene.scaleMode = SKSceneScaleModeAspectFit;
	
	//[self removeAllActions];
	self.paused = YES;
	[self.scene.view presentScene:mainScene transition:[SKTransition pushWithDirection:SKTransitionDirectionUp duration:0.3]];
	
}

- (void) presentScoresScene
{
    CGSize viewSize = CGSizeMake(CGRectGetMaxX(self.frame), CGRectGetMaxY(self.frame));
    ScoresScene *scoresScene = [[ScoresScene alloc]initWithSize:viewSize];
    scoresScene.scaleMode = SKSceneScaleModeAspectFit;
    
    //[self removeAllActions];
    self.paused = YES;
    [self.scene.view presentScene:scoresScene transition:[SKTransition pushWithDirection:SKTransitionDirectionUp duration:0.3]];
    
}
#pragma  mark -


#pragma mark Updating UserDefaults Scores
- (void)updateScores
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSInteger lastMostEvaded = [defaults integerForKey:@"DefaultsMostEvaded2"];
	NSInteger lastTotalEvaded = [defaults integerForKey:@"DefaultsTotalEvaded"];
    
	//Show "New Evaded" Label if the final evaded is higher than the last evaded
	if(self.counterEnemies > lastMostEvaded) {
		[defaults setInteger:self.counterEnemies forKey:@"DefaultsMostEvaded2"];
		[[NSUbiquitousKeyValueStore defaultStore]setLongLong:self.counterEnemies forKey:@"iCloudMostEvaded2"]; //iCloud
		self.isNewEvaded = YES;
	}
	
	//********************TOTALS*****************
	[defaults setInteger:self.counterEnemies + lastTotalEvaded forKey:@"DefaultsTotalEvaded"];
	[[NSUbiquitousKeyValueStore defaultStore]setLongLong:self.counterEnemies + lastTotalEvaded forKey:@"iCloudTotalEvaded"]; //iCLoud
	
	//If the player is authenticated to game center, report the new score
	if([GKLocalPlayer localPlayer].isAuthenticated) {
		[self reportScore:self.counterEnemies forLeaderboardID:@"leaderboardHighScore"];
		[self reportScore:self.counterEnemies + lastTotalEvaded forLeaderboardID:@"leaderboardTotalEvaded"];
	}
}
#pragma mark -

#pragma mark Reporting Scores to Game Center
- (void)reportScore:(int64_t)score forLeaderboardID:(NSString *)identifier {
    if (@available(iOS 14.0, *)) {
        [GKLeaderboard submitScore:score context:0 player:GKLocalPlayer.local leaderboardIDs:@[identifier] completionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error reporting score: %@", error.localizedDescription);
            } else {
                NSLog(@"Score reported successfully for leaderboard: %@", identifier);
            }
        }];
    } else {
        // Fallback for iOS versions prior to 14.0 using GKScore
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:identifier];
        scoreReporter.value = score;
        scoreReporter.context = 0;
        
        [GKScore reportScores:@[scoreReporter] withCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"Error reporting score: %@", error.localizedDescription);
                // Handle the error
            } else {
                NSLog(@"Score reported successfully for leaderboard: %@", identifier);
                // Perform success actions here
            }
        }];
#pragma clang diagnostic pop
    }
}
#pragma mark -

#pragma mark Preloading Textures
- (void) preloadTextures
{
	//Background stars images depending on the display
    textureCharacter = [SKTexture textureWithImageNamed:@"Character.png"];
    textureCharacterLight = [SKTexture textureWithImageNamed:@"CharacterLight.png"];
    textureCharacterAwake = [SKTexture textureWithImageNamed:@"CharacterAwake.png"];
    textureEnemy = [SKTexture textureWithImageNamed:@"Enemy.png"];
    textureEnemyCounter = [SKTexture textureWithImageNamed:@"EnemyCounter.png"];
    textureEnemyLight = [SKTexture textureWithImageNamed:@"EnemyLight.png"];
    textureEnemyCounterLight = [SKTexture textureWithImageNamed:@"EnemyCounterLight.png"];
    
    textureSoundBeginLow = [SKTexture textureWithImageNamed:@"ParticleSoundBeginLow.png"];
    textureSoundEndHigh = [SKTexture textureWithImageNamed:@"ParticleSoundEndHigh.png"];
    textureWindParticle = [SKTexture textureWithImageNamed:@"WindTexture.png"];
    textureTitle = [SKTexture textureWithImageNamed:@"Title.png"];
    
    textureButtonPlay = [SKTexture textureWithImageNamed:@"ButtonPlay.png"];
    textureButtonScores = [SKTexture textureWithImageNamed:@"ButtonArrowDown.png"];
    textureButtonHome = [SKTexture textureWithImageNamed:@"ButtonHome.png"];
    textureButtonReplay = [SKTexture textureWithImageNamed:@"ButtonReplay.png"];
    textureButtonPause = [SKTexture textureWithImageNamed:@"ButtonPause.png"];
    
    textureBackgroundSpeedLines = [SKTexture textureWithImageNamed:@"BackgroundSpeedLines.png"];
    
    textureBackgroundStarsOne = [SKTexture textureWithImageNamed:@"BackgroundStarsOne.png"];
    textureBackgroundStarsTwo = [SKTexture textureWithImageNamed:@"BackgroundStarsTwo.png"];
    textureBackgroundStarsThree = [SKTexture textureWithImageNamed:@"BackgroundStarsThree.png"];
    
    //Texture Atlas
    characterSleepingAtlas = [SKTextureAtlas atlasNamed:@"CharacterSleeping"];
    enemyBlueAtlas = [SKTextureAtlas atlasNamed:@"EnemyBlue"];
    enemyGreenAtlas = [SKTextureAtlas atlasNamed:@"EnemyGreen"];
    enemyRedAtlas = [SKTextureAtlas atlasNamed:@"EnemyRed"];
    enemyOrangeAtlas = [SKTextureAtlas atlasNamed:@"EnemyOrange"];
    enemyPurpleAtlas = [SKTextureAtlas atlasNamed:@"EnemyPurple"];
    enemyCounterAtlas = [SKTextureAtlas atlasNamed:@"EnemyCounter"];
}
#pragma mark -

#pragma mark Reset Looks and Actions
- (void) resetLooksWhenColliding
{
	SKNode *nodeCharacter = [self childNodeWithName:@"SKNodeCharacter"];
	SKNode *character = [nodeCharacter childNodeWithName:@"Character"];
	SKNode *background = [self childNodeWithName:@"SpriteBackground"];
	
	[character removeActionForKey:@"SKActionUpAndDown"];
	[character removeActionForKey:@"SKActionAnimateCharacterSleeping"];
	[character removeActionForKey:@"SKActionAnimateCharacterAwake"];
	[character runAction:[SKAction setTexture:textureCharacter]];
	[background runAction:[self.userData valueForKey:@"ActionColorizeToNight"] withKey:@"SKActionColorizeBackground"];
	[self removeBackgroundSpeedLines];
}

- (void) resetLooksWhenRepeatingGame
{
	SKNode *nodeCharacter = [self childNodeWithName:@"SKNodeCharacter"];
	SKNode *character = [nodeCharacter childNodeWithName:@"Character"];
	
	[character runAction:[SKAction repeatActionForever:[self.userData objectForKey:@"ActionUpAndDown"]]withKey:@"SKActionUpAndDown"];
	[character runAction:[nodeCharacter.userData valueForKey:@"ActionRemoveCharacterRotation"] withKey:@"rotateCharacter"];
	[character runAction:[SKAction repeatActionForever:[nodeCharacter.userData valueForKey:@"ActionAnimateCharacterSleeping"]] withKey:@"SKActionAnimateCharacterSleeping"];
}
#pragma  mark -

@end
