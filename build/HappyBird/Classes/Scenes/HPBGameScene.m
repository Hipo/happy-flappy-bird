//
//  HPBGameScene.m
//  HappyBird
//
//  Created by Taylan Pince on 2/9/2014.
//  Copyright (c) 2014 Hipo. All rights reserved.
//

#import "HPBGameScene.h"


static const float HPBSceneMoveVelocity = 100.0;
static const uint32_t HPBPipeCategory = 0x1 << 1;
static const uint32_t HPBBirdCategory = 0x1 << 2;
static const uint32_t HPBFloorCategory = 0x1 << 3;
static const uint32_t HPBWorldCollisionMask = 0x1 << 1;


static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b) {
    return CGPointMake(a.x * b, a.y * b);
}


@interface HPBGameScene () <SKPhysicsContactDelegate>

@property (nonatomic, strong) SKSpriteNode *birdNode;
@property (nonatomic, strong) SKAction *birdFlapAction;
@property (nonatomic, strong) SKLabelNode *scoreLabel;

@property (nonatomic, assign) BOOL gameOver;
@property (nonatomic, assign) BOOL gameRunning;
@property (nonatomic, assign) BOOL touchingFloor;
@property (nonatomic, assign) NSTimeInterval updateTimeDelta;
@property (nonatomic, assign) NSTimeInterval lastUpdateTime;
@property (nonatomic, assign) NSTimeInterval totalTime;
@property (nonatomic, assign) CGFloat totalMovedDistance;
@property (nonatomic, assign) CGFloat distanceSinceLastPipe;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, assign) HPBGameSceneMode currentMode;

- (void)generatePipes;

@end


@implementation HPBGameScene

- (id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    
    if (self) {
        [self setScaleMode:SKSceneScaleModeAspectFill];
        
        for (NSInteger i = 0; i < 2; i++) {
            SKSpriteNode *backgroundNode = [SKSpriteNode spriteNodeWithImageNamed:@"bg-tile"];
            
            [backgroundNode setPosition:CGPointMake(i * size.width, 0.0)];
            [backgroundNode setAnchorPoint:CGPointZero];
            [backgroundNode setName:@"bg-tile"];
            
            [self addChild:backgroundNode];
        }
        
        [self.physicsWorld setGravity:CGVectorMake(0.0, 0.0)];
        [self.physicsWorld setContactDelegate:self];
        
        SKNode *edgeNode = [SKNode node];
        
        [edgeNode setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:
                                  CGRectMake(0.0, 11.0, size.width, size.height - 12.0)]];
        
        [edgeNode.physicsBody setUsesPreciseCollisionDetection:YES];
        [edgeNode.physicsBody setCategoryBitMask:HPBFloorCategory];
        [edgeNode.physicsBody setCollisionBitMask:HPBBirdCategory];
        [edgeNode.physicsBody setContactTestBitMask:HPBBirdCategory];
        
        [self addChild:edgeNode];
        
        _birdNode = [SKSpriteNode spriteNodeWithImageNamed:@"bird-1"];
        
        [_birdNode setZPosition:1.0];
        [_birdNode setPosition:CGPointMake(size.width / 2, size.height / 2)];
        [_birdNode setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:_birdNode.size.height / 2.0]];
        [_birdNode.physicsBody setMass:1.0];
        [_birdNode.physicsBody setCategoryBitMask:HPBBirdCategory];
        [_birdNode.physicsBody setCollisionBitMask:HPBFloorCategory | HPBPipeCategory];
        [_birdNode.physicsBody setContactTestBitMask:HPBFloorCategory | HPBPipeCategory];
        [_birdNode.physicsBody setUsesPreciseCollisionDetection:YES];
        [_birdNode.physicsBody setAllowsRotation:NO];
        
        [self addChild:_birdNode];
        
        NSMutableArray *birdStates = [NSMutableArray array];
        
        for (NSInteger i = 1; i <= 3; i++) {
            SKTexture *birdTexture = [SKTexture textureWithImageNamed:
                                      [NSString stringWithFormat:@"bird-%ld", (long)i]];
            
            [birdStates addObject:birdTexture];
        }
        
        _birdFlapAction = [SKAction repeatActionForever:
                           [SKAction animateWithTextures:birdStates
                                            timePerFrame:0.12]];
        
        [_birdNode runAction:_birdFlapAction];
        
        _scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"PressStart2P"];
        
        [_scoreLabel setZPosition:1.0];
        [_scoreLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
        [_scoreLabel setPosition:CGPointMake(10.0, size.height - 42.0)];
        [_scoreLabel setText:@"0"];
        
        [self addChild:_scoreLabel];
        
        _gameOver = NO;
        _gameRunning = NO;
        _totalMovedDistance = 0.0;
        _touchingFloor = NO;
        _totalTime = 0.0;
        _score = 0;
    }
    
    return self;
}

#pragma mark - Game control

- (void)startGameWithMode:(HPBGameSceneMode)mode {
    _gameRunning = YES;
    _gameOver = NO;
    _touchingFloor = NO;
    _totalMovedDistance = 0.0;
    _distanceSinceLastPipe = 0.0;
    _currentMode = mode;
    _totalTime = 0.0;
    _score = 0;
    
    [_birdNode runAction:_birdFlapAction];
    [_birdNode setPosition:CGPointMake(self.size.width / 2, self.size.height / 2)];

    [_scoreLabel setText:@"0"];
    
    [self.physicsWorld setGravity:CGVectorMake(0.0, -6.0)];
    
    [self enumerateChildNodesWithName:@"pipe"
                           usingBlock:^(SKNode *node, BOOL *stop) {
                               [node removeFromParent];
                           }];
    
    [self generatePipes];
    
    [_delegate gameSceneDidStartGame:self];
}

- (void)endGame {
    _gameRunning = NO;
    _gameOver = YES;

    [_birdNode removeAllActions];
    [_birdNode setTexture:[SKTexture textureWithImageNamed:@"bird-dead"]];
    
    [_delegate gameSceneDidEndGame:self];
}

#pragma mark - Pipes

- (void)generatePipes {
    for (NSInteger i = 0; i < 3; i++) {
        SKNode *pipeNode = [SKNode node];
        
        [pipeNode setName:@"pipe"];
        [pipeNode setPosition:CGPointMake(self.size.width + 100.0 + (200.0 * i), 0.0)];
        
        [self addChild:pipeNode];
        
        SKSpriteNode *pipeTop = [SKSpriteNode spriteNodeWithImageNamed:@"pipe-top"];
        SKSpriteNode *pipeBottom = [SKSpriteNode spriteNodeWithImageNamed:@"pipe-bottom"];
        
        [pipeTop setName:@"pipe-top"];
        [pipeBottom setName:@"pipe-bottom"];
        
        [pipeTop setPosition:CGPointMake(0.0, arc4random_uniform(250) + 480.0)];
        [pipeBottom setPosition:CGPointMake(0.0, pipeTop.position.y - (580.0 + arc4random_uniform(40)))];
        
        [pipeTop setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:pipeTop.size]];
        [pipeBottom setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:pipeBottom.size]];
        
        [pipeTop.physicsBody setDynamic:NO];
        [pipeBottom.physicsBody setDynamic:NO];
        
        [pipeTop.physicsBody setCategoryBitMask:HPBPipeCategory];
        [pipeBottom.physicsBody setCategoryBitMask:HPBPipeCategory];
        
        [pipeNode addChild:pipeTop];
        [pipeNode addChild:pipeBottom];
    }
}

#pragma mark - Update ticker

- (void)update:(NSTimeInterval)currentTime {
    if (_lastUpdateTime > 0.0) {
        _updateTimeDelta = currentTime - _lastUpdateTime;
    } else {
        _updateTimeDelta = 0.0;
    }
    
    _lastUpdateTime = currentTime;
    _totalTime += _updateTimeDelta;
    
//    CGFloat rotation = fminf(fmaxf(_birdNode.physicsBody.velocity.dy * 0.1, 10.0), -10.0);
//    
//    [_birdNode setZRotation:rotation * M_PI / 180.0];
    
    if (_touchingFloor || _gameOver) {
        return;
    }
    
    CGPoint backgroundVelocity = CGPointMake(-HPBSceneMoveVelocity, 0.0);
    CGPoint moveAmount = CGPointMultiplyScalar(backgroundVelocity, _updateTimeDelta);
    
    [self enumerateChildNodesWithName:@"bg-tile"
                           usingBlock:^(SKNode *node, BOOL *stop) {
                               [node setPosition:CGPointAdd(node.position, moveAmount)];
                               
                               if (node.position.x <= -self.size.width) {
                                   [node setPosition:CGPointMake(node.position.x + (self.size.width * 2),
                                                                 node.position.y)];
                               }
                           }];
    
    _totalMovedDistance += -moveAmount.x;
    
    if (_totalMovedDistance < HPBSceneMoveVelocity || !_gameRunning) {
        return;
    }
    
    _distanceSinceLastPipe += -moveAmount.x;

    if (_distanceSinceLastPipe >= 140.0) {
        _distanceSinceLastPipe = 0.0;
        
        _score += 1;
        
        [_scoreLabel setText:[NSNumberFormatter localizedStringFromNumber:@(_score)
                                                              numberStyle:NSNumberFormatterDecimalStyle]];
    }
    
    if (_currentMode == HPBGameSceneModeHappy) {
        return;
    }
    
    [self enumerateChildNodesWithName:@"pipe"
                           usingBlock:^(SKNode *node, BOOL *stop) {
                               [node setPosition:CGPointAdd(node.position, CGPointMultiplyScalar(moveAmount, 1.5))];
                               
                               if (node.position.x < -40.0) {
                                   [node setPosition:CGPointMake(self.size.width + 200.0, node.position.y)];
                                   
                                   SKSpriteNode *pipeTop = (SKSpriteNode *)[node childNodeWithName:@"pipe-top"];
                                   SKSpriteNode *pipeBottom = (SKSpriteNode *)[node childNodeWithName:@"pipe-bottom"];
                                   
                                   [pipeTop setPosition:CGPointMake(0.0, arc4random_uniform(250) + 480.0)];
                                   [pipeBottom setPosition:CGPointMake(0.0, pipeTop.position.y -
                                                                       (580.0 + arc4random_uniform(40)))];
                               }
                           }];
}

#pragma mark - Physics delegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
    if (!_gameRunning || _gameOver) {
        return;
    }
    
    if (((contact.bodyA.categoryBitMask & HPBBirdCategory)
         && (contact.bodyB.categoryBitMask & HPBPipeCategory))
        || ((contact.bodyA.categoryBitMask & HPBPipeCategory)
            && (contact.bodyB.categoryBitMask & HPBBirdCategory))) {

            [self endGame];
            
            return;
    }
    
    _touchingFloor = YES;

    [_birdNode removeAllActions];
    [_birdNode setTexture:[SKTexture textureWithImageNamed:@"bird-3"]];
}

- (void)didEndContact:(SKPhysicsContact *)contact {
    if (!_gameRunning || _gameOver) {
        return;
    }
    
    _touchingFloor = NO;

    [_birdNode runAction:_birdFlapAction];
}

#pragma mark - Touch handling

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_gameRunning || _gameOver) {
        return;
    }
    
    [_birdNode.physicsBody applyImpulse:CGVectorMake(0.0, 320.0)];
}

@end
