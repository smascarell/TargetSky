//
//  GameOverScene.m
//  targetSky
//
//  Created by Samuel Mascarell on 27/05/13.
//
//


#import "GameOverScene.h"

@implementation GameOverScene
@synthesize layer = _layer;

- (id)init {
    if ((self = [super init])) {
        self.layer = [GameOverLayer node];
        [self addChild:_layer];
    }
    return self;
}

- (void)dealloc {
    [_layer release];
    _layer = nil;
    [super dealloc];
}

@end

@implementation GameOverLayer
@synthesize label1 = _label1;
@synthesize label2 = _label2;

-(id) init
{
    if( (self=[super initWithColor:ccc4(0,0,0,255)] )) {
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        self.label1 = [CCLabelTTF labelWithString:@"X" fontName:@"Arial" fontSize:48];
        self.label2 = [CCLabelTTF labelWithString:@"X" fontName:@"Arial" fontSize:32];
        
        _label1.color = ccc3(255,255,255);
        _label1.position = ccp(winSize.width/2, winSize.height/2 + _label1.contentSize.height/2 - 10);
        
        _label2.color = ccc3(200,200,200);
        _label2.position = ccp(winSize.width/2, winSize.height/2 - _label2.contentSize.height/2 - 10);
        
        [self addChild:_label1];
        [self addChild:_label2];
        
        [self runAction:[CCSequence actions:
                         [CCDelayTime actionWithDuration:10],
                         [CCCallFunc actionWithTarget:self selector:@selector(gameOverDone)],
                         nil]];
        
    }
    return self;
}

- (void)gameOverDone { 
    [[CCDirector sharedDirector] replaceScene:[CataPum scene]]; 
} 

- (void)dealloc {
    [_label1 release]; 
    [_label2 release]; 
    _label1 = nil; 
    _label2 = nil; 
    [super dealloc]; 
} 
@end 

