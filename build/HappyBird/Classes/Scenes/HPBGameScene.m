//
//  HPBGameScene.m
//  HappyBird
//
//  Created by Taylan Pince on 2/9/2014.
//  Copyright (c) 2014 Hipo. All rights reserved.
//

#import "HPBGameScene.h"


static const float HPBSceneMoveVelocity = 100.0;


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

@property (nonatomic, assign) BOOL touchingFloor;
@property (nonatomic, assign) NSTimeInterval updateTimeDelta;
@property (nonatomic, assign) NSTimeInterval lastUpdateTime;
@property (nonatomic, assign) NSTimeInterval totalTime;
@property (nonatomic, assign) CGFloat totalMovedDistance;
@property (nonatomic, assign) NSInteger score;

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
        
        _birdNode = [SKSpriteNode spriteNodeWithImageNamed:@"bird-1"];
        
        [_birdNode setPosition:CGPointMake(size.width / 2, size.height / 2)];
        
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
        
        [self.physicsWorld setGravity:CGVectorMake(0.0, -7.5)];
        [self.physicsWorld setContactDelegate:self];
        
        [_birdNode setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:_birdNode.size]];
        [_birdNode.physicsBody setCollisionBitMask:1];
        [_birdNode.physicsBody setMass:1.0];
        [_birdNode.physicsBody setContactTestBitMask:1];
        [_birdNode.physicsBody setAllowsRotation:NO];
        
        SKNode *edgeNode = [SKNode node];
        
        [edgeNode setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:
                                  CGRectMake(0.0, 11.0, size.width, size.height - 12.0)]];
        
        [edgeNode.physicsBody setUsesPreciseCollisionDetection:YES];
        
        [self addChild:edgeNode];
        
        _scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"PressStart2P"];
        
        [_scoreLabel setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
        [_scoreLabel setPosition:CGPointMake(10.0, size.height - 42.0)];
        [_scoreLabel setText:@"0"];
        
        [self addChild:_scoreLabel];
        
        for (NSInteger i = 0; i < 3; i++) {
            SKNode *pipeNode = [SKNode node];
            
            [pipeNode setName:@"pipe"];
            [pipeNode setPosition:CGPointMake(size.width + 100.0 + (150.0 * i), 0.0)];
            
            [self addChild:pipeNode];
            
            SKSpriteNode *pipeTop = [SKSpriteNode spriteNodeWithImageNamed:@"pipe-top"];
            SKSpriteNode *pipeBottom = [SKSpriteNode spriteNodeWithImageNamed:@"pipe-bottom"];
            
            [pipeTop setName:@"pipe-top"];
            [pipeBottom setName:@"pipe-bottom"];
            
            [pipeTop setPosition:CGPointMake(0.0, arc4random_uniform(250) + 480.0)];
            [pipeBottom setPosition:CGPointMake(0.0, pipeTop.position.y - (520.0 + arc4random_uniform(40)))];
            
            [pipeTop setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:pipeTop.size]];
            [pipeBottom setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:pipeBottom.size]];
            
            [pipeTop.physicsBody setDynamic:NO];
            [pipeBottom.physicsBody setDynamic:NO];
            
            [pipeNode addChild:pipeTop];
            [pipeNode addChild:pipeBottom];
        }
        
        _totalMovedDistance = 0.0;
        _touchingFloor = NO;
        _totalTime = 0.0;
        _score = 0;
    }
    
    return self;
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
    
    if (_touchingFloor) {
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
                                   
                                   _score += 1;
                                   
                                   [_scoreLabel setText:[NSNumberFormatter localizedStringFromNumber:@(_score)
                                                                                         numberStyle:NSNumberFormatterDecimalStyle]];
                               }
                           }];
    
    _totalMovedDistance += -moveAmount.x;
    
    if (_totalMovedDistance < HPBSceneMoveVelocity) {
        return;
    }
    
    [self enumerateChildNodesWithName:@"pipe"
                           usingBlock:^(SKNode *node, BOOL *stop) {
                               [node setPosition:CGPointAdd(node.position, CGPointMultiplyScalar(moveAmount, 1.5))];
                               
                               if (node.position.x < -40.0) {
                                   [node setPosition:CGPointMake(self.size.width + 100.0, node.position.y)];
                                   
                                   SKSpriteNode *pipeTop = (SKSpriteNode *)[node childNodeWithName:@"pipe-top"];
                                   SKSpriteNode *pipeBottom = (SKSpriteNode *)[node childNodeWithName:@"pipe-bottom"];
                                   
                                   [pipeTop setPosition:CGPointMake(0.0, arc4random_uniform(250) + 480.0)];
                                   [pipeBottom setPosition:CGPointMake(0.0, pipeTop.position.y -
                                                                       (520.0 + arc4random_uniform(40)))];
                               }
                           }];
}

#pragma mark - Physics delegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
    _touchingFloor = YES;

    [_birdNode removeAllActions];
    [_birdNode setTexture:[SKTexture textureWithImageNamed:@"bird-3"]];
}

- (void)didEndContact:(SKPhysicsContact *)contact {
    _touchingFloor = NO;

    [_birdNode runAction:_birdFlapAction];
}

#pragma mark - Touch handling

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [_birdNode.physicsBody applyImpulse:CGVectorMake(0.0, 400.0)];
}

@end
