//  SpriteAppDelegate.h
//  Wingy Nights
//
//  Created by Roberto Pineda on 9/15/13.
//  Updated last on 02/23/2018
//  Copyright (c) 2014 Roberto Pineda. All rights reserved.

#import "ScoresScene.h"
#import "MainScene.h"

@interface ScoresScene() <GKGameCenterControllerDelegate> {
    CGFloat separationBetweenLines;
    CGFloat toBetweenRows;
    CGFloat minX, maxX, midX, minY, maxY, midY;
    BOOL isButtonTonesActivated, isButtonSFXActivated;
}
@end

@implementation ScoresScene

@synthesize textureCharacter, textureCharacterLight, textureButtonGameCenter,
textureEnemy, textureEnemyLight, textureBackgroundStarsOne, textureBackgroundStarsTwo,
textureBackgroundStarsThree, textureWindParticle, textureButtonArrowUp, textureButtonActivated, textureButtonDeactivated;

@synthesize characterSleepingAtlas, enemyGreenAtlas, enemyRedAtlas,
enemyOrangeAtlas, enemyPurpleAtlas;

#pragma mark Initializing Scene
-(id)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if(self)
    {
        [self removeAllActions];
        [self removeAllChildren];
        [self preloadTextures];
        [self buildWorld];
        [self showiAdBanner];
    }
    return self;
}

-(void) didMoveToView:(SKView *)view
{
    
}

- (void)showiAdBanner {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAd" object:nil];
}
- (void)hideiAdBanner {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAd" object:nil];
}

- (void) buildWorld
{
    minX = CGRectGetMinX(self.frame);
    maxX = CGRectGetMaxX(self.frame);
    midX = CGRectGetMidX(self.frame);
    minY = CGRectGetMinY(self.frame);
    maxY = CGRectGetMaxY(self.frame);
    midY = CGRectGetMidY(self.frame);
    
    separationBetweenLines = (CGRectGetMaxY(self.frame) - ((CGRectGetMaxY(self.frame) / 6) / 2)) / 5;
    toBetweenRows = separationBetweenLines/2;
    
    [self createNodeTree];
    [self createActionsForUserData];
    [self createBackground];
    [self createBackgroundStarsImages];
    [self createCharacter];
    [self createButtonHome];
    [self createButtonsAudioSettings];
    [self createAllLabels];
    [self createButtonGameCenter];
    [self createWindEmitter];
    [self createLittleBirds];
}
#pragma mark -

#pragma  mark Node Tree
- (void) createNodeTree
{
    //SKNode for Character
	SKNode *nodeCharacter= [SKNode node];
	nodeCharacter.userData = [NSMutableDictionary dictionary];
	nodeCharacter.name = @"SKNodeCharacter";
    nodeCharacter.zPosition = 3.0;
    [self addChild:nodeCharacter];
    
    //SKNode for Background Stars images
	SKNode *nodeBackgroundStars = [SKNode node];
	nodeBackgroundStars.userData = [NSMutableDictionary dictionary];
	nodeBackgroundStars.name = @"SKNodeBackgroundStars";
    nodeBackgroundStars.zPosition = 1.0;
	[self addChild:nodeBackgroundStars];
    
    //SKNode for Labels
	SKNode *nodeLabels = [SKNode node];
	nodeLabels.userData = [NSMutableDictionary dictionary];
	nodeLabels.name = @"SKNodeLabels";
    nodeLabels.zPosition = 2.0;
	[self addChild:nodeLabels];
    
    //SKNode for Buttons
	SKNode *nodeButtons = [SKNode node];
	nodeButtons.userData = [NSMutableDictionary dictionary];
	nodeButtons.name = @"SKNodeButtons";
    nodeButtons.zPosition = 2.0;
	[self addChild:nodeButtons];
}
#pragma mark -

#pragma  mark Create Nodes
-(void) createBackground
{
	SKSpriteNode *background = [[SKSpriteNode alloc] initWithColor:[SKColor colorWithRed:24.0/255.0 green:55.0/255.0 blue:78.0/255.0 alpha:1.0] size:self.frame.size];
	background.name = @"SpriteBackground";
	background.zPosition = 0.0;
	background.anchorPoint = CGPointMake(0, 0);
	[self addChild:background];
}

-(void)createCharacter
{
    SKNode *nodeCharacter = [self childNodeWithName:@"SKNodeCharacter"];
    NSArray *characterSleepingTextureNames = [characterSleepingAtlas textureNames];
    
    SKSpriteNode *character = [[SKSpriteNode alloc]initWithTexture:textureCharacter];
	character.position = CGPointMake(minX + character.size.width, separationBetweenLines*2 + toBetweenRows);
    character.name = @"Character";
	character.anchorPoint = CGPointMake(0.5, 0.5);
    
    SKSpriteNode *characterLight = [[SKSpriteNode alloc]initWithTexture:textureCharacterLight];
    [character addChild:characterLight];
	[characterLight runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction scaleTo:0.96 duration:0.6],
																				 [SKAction scaleTo:1.0 duration:0.5]]]]];
	
    //Texture atlas and action for Character Sleeping
    NSMutableArray *characterSleepingTextures = [NSMutableArray arrayWithCapacity:characterSleepingTextureNames.count];
    for (NSString *textureName in characterSleepingTextureNames) {
       SKTexture *texture = [characterSleepingAtlas textureNamed:textureName];
       [characterSleepingTextures addObject:texture];
    }
    SKAction *animateCharacterSleeping = [SKAction animateWithTextures:characterSleepingTextures timePerFrame:0.07 resize:NO restore:YES];
	
    //Action for going up and down
	SKAction *upAndDownAnimation = [SKAction sequence:@[
														[SKAction moveBy:CGVectorMake(0.0, toBetweenRows/4) duration:0.8],
														[SKAction moveBy:CGVectorMake(0.0, -toBetweenRows/4) duration:0.8]]];
	SKAction *reverseUpAndDownAnimation = [upAndDownAnimation reversedAction];
	SKAction *sequence = [SKAction sequence:@[upAndDownAnimation, reverseUpAndDownAnimation]];
	
    [character runAction:[SKAction repeatActionForever:animateCharacterSleeping] withKey:@"SKActionAnimateCharacterSleeping"];
	[character runAction:[SKAction repeatActionForever:sequence]];
	
	[nodeCharacter addChild:character];
}


-(void) createButtonHome
{
    SKNode *nodeButtons = [self childNodeWithName:@"SKNodeButtons"];
    
    //Button Home
    SKSpriteNode *buttonHome = [[SKSpriteNode alloc] initWithTexture:textureButtonArrowUp];
    buttonHome.position = CGPointMake(maxX - buttonHome.size.width, minY + buttonHome.size.height);
    buttonHome.name = @"ButtonHome";
    [nodeButtons addChild:buttonHome];
}

- (void)createBackgroundStarsImages
{
	SKNode *nodeBackgroundStars = [self childNodeWithName:@"SKNodeBackgroundStars"];
	
    SKSpriteNode *backgroundStarsOne = [[SKSpriteNode alloc]initWithTexture:textureBackgroundStarsOne];
    SKSpriteNode *backgroundStarsTwo = [[SKSpriteNode alloc]initWithTexture:textureBackgroundStarsTwo];
    SKSpriteNode *backgroundStarsThree = [[SKSpriteNode alloc]initWithTexture:textureBackgroundStarsThree];
    
	backgroundStarsOne.name = @"BackgroundStarsOne";
	backgroundStarsOne.anchorPoint = CGPointMake(1.0, 0.5);
	backgroundStarsOne.position = CGPointMake(maxX, midY);
	
	backgroundStarsTwo.name = @"BackgroundStarsTwo";
	backgroundStarsTwo.anchorPoint = CGPointMake(1.0, 0.5);
	backgroundStarsTwo.position = CGPointMake(maxX*2, midY);
	
	backgroundStarsThree.name = @"BackgroundStarsThree";
	backgroundStarsThree.anchorPoint = CGPointMake(1.0, 0.5);
	backgroundStarsThree.position = CGPointMake(maxX*3, midY);
	
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

- (void)createAllLabels
{
    SKNode *nodeLabels = [self childNodeWithName:@"SKNodeLabels"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger mostEvaded = [defaults integerForKey:@"DefaultsMostEvaded2"];
    NSInteger totalEvaded = [defaults integerForKey:@"DefaultsTotalEvaded"];
    SKNode *nodeButtons = [self childNodeWithName:@"SKNodeButtons"];
    
    SKSpriteNode *buttonTones = (SKSpriteNode *)[nodeButtons childNodeWithName:@"ButtonTones"];
    SKSpriteNode *buttonSFX = (SKSpriteNode *)[nodeButtons childNodeWithName:@"ButtonSFX"];
    
    //--------------
    //Label Most Evaded
    SKLabelNode *labelMostEvaded = [self createStandartLabel];
	labelMostEvaded.text = @"HIGH SCORE";
	labelMostEvaded.position = CGPointMake(midX - maxX/3.7, separationBetweenLines * 4);
    
    //Label Number Most Evaded
    SKLabelNode *labelNumberMostEvaded = [self createNumberLabel];
	labelNumberMostEvaded.text = [NSString stringWithFormat:@"%ld", (long)mostEvaded];
	labelNumberMostEvaded.position = CGPointMake(midX + maxX/3.7, separationBetweenLines * 4);
    //--------------
    
    //--------------
    //Label Total evaded
    SKLabelNode *labelTotalEvaded = [self createStandartLabel];
	labelTotalEvaded.text = @"TOTAL EVADED";
	labelTotalEvaded.position = CGPointMake(midX - maxX/3.7, separationBetweenLines * 3 + toBetweenRows);
    
    //Label Number Total Evaded
    SKLabelNode *labelNumberTotalEvaded = [self createNumberLabel];
	labelNumberTotalEvaded.text = [NSString stringWithFormat:@"%ld", (long)totalEvaded];
	labelNumberTotalEvaded.position = CGPointMake(midX + maxX/3.7, separationBetweenLines * 3 + toBetweenRows);
    //--------------
    
    //Label Tones
    SKLabelNode *labelTones = [[SKLabelNode alloc] initWithFontNamed:@"launica"];
	labelTones.color = [SKColor whiteColor];
    labelTones.text = @"TONES";
	labelTones.fontSize = 35;
	labelTones.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    labelTones.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
	labelTones.position = CGPointMake(buttonTones.position.x, toBetweenRows);
    
    //Label SFX
    SKLabelNode *labelSFX = [[SKLabelNode alloc] initWithFontNamed:@"launica"];
	labelSFX.color = [SKColor whiteColor];
    labelSFX.text = @"SFX";
	labelSFX.fontSize = 35;
	labelSFX.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    labelSFX.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
	labelSFX.position = CGPointMake(buttonSFX.position.x, toBetweenRows);
    
    [nodeLabels addChild:labelTones];
    [nodeLabels addChild:labelSFX];
    
    [nodeLabels addChild:labelMostEvaded];
    [nodeLabels addChild:labelTotalEvaded];
    
    [nodeLabels addChild:labelNumberMostEvaded];
    [nodeLabels addChild:labelNumberTotalEvaded];
}

- (void)createButtonGameCenter
{
    SKNode *nodeButtons = [self childNodeWithName:@"SKNodeButtons"];
    
    SKSpriteNode *buttonGameCenter = [[SKSpriteNode alloc] initWithTexture:textureButtonGameCenter];
    buttonGameCenter.position = CGPointMake(midX, separationBetweenLines * 2);
    buttonGameCenter.name = @"ButtonGameCenter";
    [nodeButtons addChild:buttonGameCenter];
}

- (SKLabelNode *) createStandartLabel
{
    SKLabelNode *label = [[SKLabelNode alloc] initWithFontNamed:@"launica"];
    label.color = [SKColor whiteColor];
    label.zPosition = 4.0;
    label.fontSize = 40;
    label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    
    return label;
}

-(SKLabelNode *)createNumberLabel
{
    SKLabelNode *label = [[SKLabelNode alloc] initWithFontNamed:@"launica"];
    label.color = [SKColor whiteColor];
    label.zPosition = 4.0;
    label.fontSize = 45;
    label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    
    return label;
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

    windEmitter.name = @"WindEmitter";
    windEmitter.zPosition = 3.0;
    windEmitter.particlePosition = CGPointMake(maxX, midY);
    windEmitter.particlePositionRange = CGVectorMake(0, maxY);
    windEmitter.particleSpeed = (self.size.width / 4.0);
    [self addChild:windEmitter];
}

-(void)createLittleBirds
{
    NSArray *enemyRedTextureNames = [enemyRedAtlas textureNames];
    NSArray *enemyGreenTextureNames = [enemyGreenAtlas textureNames];
    NSArray *enemyOrangeTextureNames = [enemyOrangeAtlas textureNames];
    NSArray *enemyPurpleTextureNames = [enemyPurpleAtlas textureNames];
    
    SKNode *nodeButtons = [self childNodeWithName:@"SKNodeButtons"];
    SKSpriteNode *buttonGameCenter = (SKSpriteNode *)[nodeButtons childNodeWithName:@"ButtonGameCenter"];
    SKSpriteNode *enemyLightLeftGameCenter = [[SKSpriteNode alloc] initWithTexture:textureEnemyLight];
    SKSpriteNode *enemyLightRightGameCenter = [[SKSpriteNode alloc] initWithTexture:textureEnemyLight];
    SKSpriteNode *enemyLightLeftAudio = [[SKSpriteNode alloc] initWithTexture:textureEnemyLight];
    SKSpriteNode *enemyLightRightAudio = [[SKSpriteNode alloc] initWithTexture:textureEnemyLight];
    SKSpriteNode *buttonTones = (SKSpriteNode *)[nodeButtons childNodeWithName:@"ButtonTones"];
    SKSpriteNode *buttonSFX = (SKSpriteNode *)[nodeButtons childNodeWithName:@"ButtonSFX"];
    
    SKAction *scaleEnemyLight = [SKAction repeatActionForever:[SKAction sequence:@[[SKAction scaleTo:0.96 duration:0.6],
                                                                                   [SKAction scaleTo:1.0 duration:0.5]]]];
    SKAction *upAndDownAnimation = [SKAction sequence:@[
														[SKAction moveBy:CGVectorMake(0.0, toBetweenRows/4) duration:0.8],
														[SKAction moveBy:CGVectorMake(0.0, -toBetweenRows/4) duration:0.8]]];
	SKAction *actionUpAndDown = [SKAction sequence:@[upAndDownAnimation, [upAndDownAnimation reversedAction]]];
    
    
    NSMutableArray *enemyRedTextures = [NSMutableArray arrayWithCapacity:enemyRedTextureNames.count];
    for (NSString *textureName in enemyRedTextureNames) {
       SKTexture *texture = [enemyRedAtlas textureNamed:textureName];
       [enemyRedTextures addObject:texture];
    }
	SKAction *animateRedEnemy = [SKAction animateWithTextures:enemyRedTextures timePerFrame:0.07 resize:NO restore:YES];
    
    NSMutableArray *enemyGreenTextures = [NSMutableArray arrayWithCapacity:enemyGreenTextureNames.count];
    for (NSString *textureName in enemyGreenTextureNames) {
       SKTexture *texture = [enemyGreenAtlas textureNamed:textureName];
       [enemyGreenTextures addObject:texture];
    }
	SKAction *animateGreenEnemy = [SKAction animateWithTextures:enemyGreenTextures timePerFrame:0.07 resize:NO restore:YES];
    
    NSMutableArray *enemyOrangeTextures = [NSMutableArray arrayWithCapacity:enemyOrangeTextureNames.count];
    for (NSString *textureName in enemyOrangeTextureNames) {
       SKTexture *texture = [enemyOrangeAtlas textureNamed:textureName];
       [enemyOrangeTextures addObject:texture];
    }
    SKAction *animateOrangeEnemy = [SKAction animateWithTextures:enemyOrangeTextures timePerFrame:0.07 resize:NO restore:YES];
    
    NSMutableArray *enemyPurpleTextures = [NSMutableArray arrayWithCapacity:enemyPurpleTextureNames.count];
    for (NSString *textureName in enemyPurpleTextureNames) {
       SKTexture *texture = [enemyPurpleAtlas textureNamed:textureName];
       [enemyPurpleTextures addObject:texture];
    }
    SKAction *animatePurpleEnemy = [SKAction animateWithTextures:enemyPurpleTextures timePerFrame:0.07 resize:NO restore:YES];
    
    //Enemy Left Game Center
    SKSpriteNode *enemyLeftGameCenter = [[SKSpriteNode alloc] initWithTexture:textureEnemy];
	enemyLeftGameCenter.zPosition = 3.0;
    enemyLeftGameCenter.xScale = -1.0;
    enemyLeftGameCenter.position = CGPointMake(buttonGameCenter.position.x - buttonGameCenter.size.width * 1.5, separationBetweenLines*2);
    
    //Enemy Right Game Center
    SKSpriteNode *enemyRightGameCenter = [[SKSpriteNode alloc] initWithTexture:textureEnemy];
	enemyRightGameCenter.zPosition = 3.0;
    enemyRightGameCenter.position = CGPointMake(buttonGameCenter.position.x + buttonGameCenter.size.width * 1.5, separationBetweenLines*2);
    
    [enemyLightLeftGameCenter runAction:[SKAction repeatActionForever:scaleEnemyLight]];
    [enemyLightLeftGameCenter runAction:[SKAction repeatActionForever:scaleEnemyLight]];
    
    //Enemy Left Audio
    SKSpriteNode *enemyLeftAudio = [[SKSpriteNode alloc] initWithTexture:textureEnemy];
	enemyLeftAudio.zPosition = 3.0;
    enemyLeftAudio.xScale = -1.0;
    enemyLeftAudio.position = CGPointMake(buttonTones.position.x - buttonTones.size.width * 1.5, separationBetweenLines);
    
    //Enemy Right Audio
    SKSpriteNode *enemyRightAudio = [[SKSpriteNode alloc] initWithTexture:textureEnemy];
	enemyRightAudio.zPosition = 3.0;
    enemyRightAudio.position = CGPointMake(buttonSFX.position.x + buttonSFX.size.width * 1.5, separationBetweenLines);
    
    [enemyLightLeftAudio runAction:[SKAction repeatActionForever:scaleEnemyLight]];
    [enemyLightRightAudio runAction:[SKAction repeatActionForever:scaleEnemyLight]];
    
    //Add Enemy Left Audio
    [enemyLeftAudio runAction:[SKAction repeatActionForever:actionUpAndDown]];
    [enemyLeftAudio runAction:[SKAction repeatActionForever:animateOrangeEnemy]];
    [enemyLeftAudio addChild:enemyLightLeftAudio];
    [self addChild:enemyLeftAudio];
    
    //Add enemy Right Audio
    [enemyRightAudio runAction:[SKAction repeatActionForever:actionUpAndDown]];
    [enemyRightAudio runAction:[SKAction repeatActionForever:animatePurpleEnemy]];
    [enemyRightAudio addChild:enemyLightRightAudio];
    [self addChild:enemyRightAudio];
    
    //Add Enemy Left Game Center
    [enemyLeftGameCenter runAction:[SKAction repeatActionForever:actionUpAndDown]];
    [enemyLeftGameCenter runAction:[SKAction repeatActionForever:animateRedEnemy]];
    [enemyLeftGameCenter addChild:enemyLightLeftGameCenter];
    [self addChild:enemyLeftGameCenter];
    
    //Add enemy Right Game Center
    [enemyRightGameCenter runAction:[SKAction repeatActionForever:actionUpAndDown]];
    [enemyRightGameCenter runAction:[SKAction repeatActionForever:animateGreenEnemy]];
    [enemyRightGameCenter addChild:enemyLightRightGameCenter];
    [self addChild:enemyRightGameCenter];
}

- (void)createButtonsAudioSettings
{
    SKNode *nodeButtons = [self childNodeWithName:@"SKNodeButtons"];
    
    SKSpriteNode *buttonTones;
    SKSpriteNode *buttonSFX;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //test defaults at scene init
    
    //BUTTON TONES
    //Check the database if the settings are currently on of off and set the sprite of the button
    if([defaults boolForKey:@"DefaultsIsTonesOn"] == YES) {
        buttonTones = [[SKSpriteNode alloc] initWithTexture:textureButtonActivated];
    }
    
    if ([defaults boolForKey:@"DefaultsIsTonesOn"] == NO) {
        buttonTones = [[SKSpriteNode alloc] initWithTexture:textureButtonDeactivated];
    }
    
    buttonTones.position = CGPointMake(midX - buttonTones.size.width * 0.6, separationBetweenLines);
	buttonTones.name = @"ButtonTones";
	[nodeButtons addChild:buttonTones];
    
    
    //BUTTON SFX
    if([defaults boolForKey:@"DefaultsIsSFXOn"] == YES) {
        buttonSFX = [[SKSpriteNode alloc] initWithTexture:textureButtonActivated];
    }
    if ([defaults boolForKey:@"DefaultsIsSFXOn"] == NO) {
        buttonSFX = [[SKSpriteNode alloc] initWithTexture:textureButtonDeactivated];
    }
    
    buttonSFX.position = CGPointMake(midX + buttonSFX.size.width * 0.6, separationBetweenLines);
	buttonSFX.name = @"ButtonSFX";
	[nodeButtons addChild:buttonSFX];
}

#pragma mark -

#pragma  mark Game Loop
-(void)update:(NSTimeInterval)currentTime
{
    SKNode *nodeBackgroundStars = [self childNodeWithName:@"SKNodeBackgroundStars"];
    SKNode *backgroundStarsOne = [nodeBackgroundStars childNodeWithName:@"BackgroundStarsOne"];
	SKNode *backgroundStarsTwo = [nodeBackgroundStars childNodeWithName:@"BackgroundStarsTwo"];
	SKNode *backgroundStarsThree = [nodeBackgroundStars childNodeWithName:@"BackgroundStarsThree"];
    
    //Move the stars backgrounds
	if(backgroundStarsOne.position.x <= minX) {
		backgroundStarsOne.position = CGPointMake(backgroundStarsThree.position.x + maxX, midY);
	}
	
	if(backgroundStarsTwo.position.x <= minX) {
		backgroundStarsTwo.position = CGPointMake(backgroundStarsOne.position.x + maxX, midY);
	}
	
	if(backgroundStarsThree.position.x <= minX) {
		backgroundStarsThree.position = CGPointMake(backgroundStarsTwo.position.x + maxX, midY);
	}
	
	backgroundStarsOne.position = CGPointMake(backgroundStarsOne.position.x - (0.8/4.0), backgroundStarsOne.position.y);
	backgroundStarsTwo.position = CGPointMake(backgroundStarsTwo.position.x - (0.8/4.0), backgroundStarsTwo.position.y);
	backgroundStarsThree.position = CGPointMake(backgroundStarsThree.position.x - (0.8/4.0), backgroundStarsThree.position.y);
}
#pragma mark -

#pragma mark Touch Controls
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
	if(location.y < separationBetweenLines) {
        //Touching first row
        [self teleportToRow:0];
    }
    
    if((location.y > separationBetweenLines) && (location.y < separationBetweenLines*2)) {
        //Touching second row
        [self teleportToRow:1];
    }
    
    if((location.y > separationBetweenLines*2) && (location.y < separationBetweenLines*3)) {
        //Touching third row
        [self teleportToRow:2];
    }
    
    if((location.y > separationBetweenLines*3) && (location.y < separationBetweenLines*4)) {
        //Touching fourth row
        [self teleportToRow:3];
    }
    
    if((location.y > separationBetweenLines*4) && (location.y < separationBetweenLines*5)) {
        //Touching fifth row
        [self teleportToRow:4];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    SKNode *nodeButtons = [self childNodeWithName:@"SKNodeButtons"];
    
    UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInNode:self];
    SKNode *buttonHome = [nodeButtons childNodeWithName:@"ButtonHome"];
    SKNode *buttonGameCenter = [nodeButtons childNodeWithName:@"ButtonGameCenter"];
    SKNode *buttonTones = [nodeButtons childNodeWithName:@"ButtonTones"];
    SKNode *buttonSFX = [nodeButtons childNodeWithName:@"ButtonSFX"];
    
    SKAction *setTextureToActivated = [SKAction setTexture:textureButtonActivated];
    SKAction *setTextureToDeactivated = [SKAction setTexture:textureButtonDeactivated];
    
    //Activate or deactivate the Audio Settings Buttons
    if([buttonTones containsPoint:location]) {
        if(isButtonTonesActivated == YES) {
            [buttonTones runAction:setTextureToDeactivated];
            isButtonTonesActivated = NO;
            [defaults setBool:NO forKey:@"DefaultsIsTonesOn"];
        } else {
            [buttonTones runAction:setTextureToActivated];
            isButtonTonesActivated = YES;
            [defaults setBool:YES forKey:@"DefaultsIsTonesOn"];
        }
        NSLog(@"Value Tones: %d", [defaults boolForKey:@"DefaultsIsTonesOn"]);
    }
    
    if([buttonSFX containsPoint:location]) {
        if(isButtonSFXActivated == YES) {
            [buttonSFX runAction:setTextureToDeactivated];
            isButtonSFXActivated = NO;
            [defaults setBool:NO forKey:@"DefaultsIsSFXOn"];
        } else {
            [buttonSFX runAction:setTextureToActivated];
            isButtonSFXActivated = YES;
            [defaults setBool:YES forKey:@"DefaultsIsSFXOn"];
        }
        NSLog(@"Value SFX: %d", [defaults boolForKey:@"DefaultsIsSFXOn"]);
    }
    
    [defaults synchronize];
    
    if([buttonHome containsPoint:location]) {
        [self hideiAdBanner];
        [self presentBeaneyScene];
    }
    
    if([buttonGameCenter containsPoint:location]) {
        
        //Sync to game center
        if([GKLocalPlayer localPlayer].isAuthenticated) {
            [self reportScore:[defaults integerForKey:@"DefaultsMostEvaded2"] forLeaderboardID:@"leaderboardHighScore"];
            [self reportScore:[defaults integerForKey:@"DefaultsTotalEvaded"] forLeaderboardID:@"leaderboardTotalEvaded"];
        }
        
        [self showGameCenter];
    }
}


-(void) teleportToRow: (NSInteger)row
{
    SKNode *nodeCharacter = [self childNodeWithName:@"SKNodeCharacter"];
    SKNode *character = [nodeCharacter childNodeWithName:@"Character"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    SKAction *actionSoundTeleport;
    
    switch (row) {
        case 0:
            [character runAction:[nodeCharacter.userData valueForKey:@"ActionTeleportToRowZero"]];
			actionSoundTeleport = [nodeCharacter.userData valueForKey:@"ActionSoundTeleportZero"];
            break;
        case 1:
            [character runAction:[nodeCharacter.userData valueForKey:@"ActionTeleportToRowOne"]];
            actionSoundTeleport = [nodeCharacter.userData valueForKey:@"ActionSoundTeleportOne"];
            break;
        case 2:
            [character runAction:[nodeCharacter.userData valueForKey:@"ActionTeleportToRowTwo"]];
            actionSoundTeleport = [nodeCharacter.userData valueForKey:@"ActionSoundTeleportTwo"];
            break;
        case 3:
            [character runAction:[nodeCharacter.userData valueForKey:@"ActionTeleportToRowThree"]];
            actionSoundTeleport = [nodeCharacter.userData valueForKey:@"ActionSoundTeleportThree"];
            break;
        case 4:
            [character runAction:[nodeCharacter.userData valueForKey:@"ActionTeleportToRowFour"]];
            actionSoundTeleport = [nodeCharacter.userData valueForKey:@"ActionSoundTeleportFour"];
            break;
        default:
            break;
    }
    
    if([defaults boolForKey:@"DefaultsIsSFXOn"] == YES) {
        [character runAction:actionSoundTeleport];
    }
}
#pragma mark -

#pragma mark Game Center
- (void) showGameCenter
{
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
    if (gameCenterController != nil)
    {
		UIViewController *viewController = self.view.window.rootViewController;
		gameCenterController.gameCenterDelegate = self;
		[viewController presentViewController: gameCenterController animated: YES completion:nil];
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
	UIViewController *vc = self.view.window.rootViewController;
	[vc dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -

#pragma mark Sync Scores to GameCenter
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:identifier];
        scoreReporter.value = score;
        scoreReporter.context = 0;
        
        [GKScore reportScores:@[scoreReporter] withCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error reporting score: %@", error.localizedDescription);
            } else {
                NSLog(@"Score reported successfully for leaderboard: %@", identifier);
            }
        }];
    }
#pragma clang diagnostic pop
}
#pragma mark -

#pragma mark Present Scene
- (void) presentBeaneyScene
{
    // Present the scene.
    CGSize viewSize = CGSizeMake(CGRectGetMaxX(self.frame), CGRectGetMaxY(self.frame));
    MainScene *mainScene = [[MainScene alloc]initWithSize:viewSize];
    mainScene.scaleMode = SKSceneScaleModeAspectFit;
    
    //[self removeAllActions];
    self.paused = YES;
    [self.scene.view presentScene:mainScene transition:[SKTransition pushWithDirection:SKTransitionDirectionDown duration:0.3]];
}
#pragma mark -

#pragma mark User Data
- (void)createActionsForUserData
{
    SKNode *nodeCharacter = [self childNodeWithName:@"SKNodeCharacter"];
    
    // (SKNodeCharacter) Action Teleport to row
	SKAction *actionTeleportToRowZero = [SKAction sequence:@[[SKAction scaleTo:0.1 duration:0.06],
															 [SKAction moveTo:CGPointMake(maxX/12, minY+toBetweenRows) duration:0],
															 [SKAction scaleTo:1.0 duration:0.06]]];
	SKAction *actionTeleportToRowOne = [SKAction sequence:@[[SKAction scaleTo:0.1 duration:0.06],
															[SKAction moveTo:CGPointMake(maxX/12, separationBetweenLines+toBetweenRows) duration:0],
															[SKAction scaleTo:1.0 duration:0.06]]];
	SKAction *actionTeleportToRowTwo = [SKAction sequence:@[[SKAction scaleTo:0.1 duration:0.06],
															[SKAction moveTo:CGPointMake(maxX/12, separationBetweenLines*2+toBetweenRows) duration:0],
															[SKAction scaleTo:1.0 duration:0.06]]];
	SKAction *actionTeleportToRowThree = [SKAction sequence:@[[SKAction scaleTo:0.1 duration:0.06],
															  [SKAction moveTo:CGPointMake(maxX/12, separationBetweenLines*3+toBetweenRows) duration:0],
															  [SKAction scaleTo:1.0 duration:0.06]]];
	SKAction *actionTeleportToRowFour = [SKAction sequence:@[[SKAction scaleTo:0.1 duration:0.06],
															 [SKAction moveTo:CGPointMake(maxX/12, separationBetweenLines*4+toBetweenRows) duration:0],
															 [SKAction scaleTo:1.0 duration:0.06]]];
	[nodeCharacter.userData setValue:actionTeleportToRowZero forKey:@"ActionTeleportToRowZero"];
	[nodeCharacter.userData setValue:actionTeleportToRowOne forKey:@"ActionTeleportToRowOne"];
	[nodeCharacter.userData setValue:actionTeleportToRowTwo forKey:@"ActionTeleportToRowTwo"];
	[nodeCharacter.userData setValue:actionTeleportToRowThree forKey:@"ActionTeleportToRowThree"];
	[nodeCharacter.userData setValue:actionTeleportToRowFour forKey:@"ActionTeleportToRowFour"];
    
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
}

- (void) preloadTextures
{
	//Background stars images depending on the display
    textureCharacter = [SKTexture textureWithImageNamed:@"Character.png"];
    textureCharacterLight = [SKTexture textureWithImageNamed:@"CharacterLight.png"];
    textureEnemy = [SKTexture textureWithImageNamed:@"Enemy.png"];
    textureEnemyLight = [SKTexture textureWithImageNamed:@"EnemyLight.png"];
    
    textureWindParticle = [SKTexture textureWithImageNamed:@"WindTexture.png"];
    textureButtonArrowUp = [SKTexture textureWithImageNamed:@"ButtonArrowUp"];
    textureButtonGameCenter = [SKTexture textureWithImageNamed:@"ButtonGameCenter"];
    
    textureButtonActivated = [SKTexture textureWithImageNamed:@"ButtonActivated"];
    textureButtonDeactivated = [SKTexture textureWithImageNamed:@"ButtonDeactivated"];
    
    textureBackgroundStarsOne = [SKTexture textureWithImageNamed:@"BackgroundStarsOne.png"];
    textureBackgroundStarsTwo = [SKTexture textureWithImageNamed:@"BackgroundStarsTwo.png"];
    textureBackgroundStarsThree = [SKTexture textureWithImageNamed:@"BackgroundStarsThree.png"];
    
    characterSleepingAtlas = [SKTextureAtlas atlasNamed:@"CharacterSleeping"];
    enemyRedAtlas = [SKTextureAtlas atlasNamed:@"EnemyRed"];
    enemyGreenAtlas = [SKTextureAtlas atlasNamed:@"EnemyGreen"];
    enemyOrangeAtlas = [SKTextureAtlas atlasNamed:@"EnemyOrange"];
    enemyPurpleAtlas = [SKTextureAtlas atlasNamed:@"EnemyPurple"];
}

#pragma mark -

@end
