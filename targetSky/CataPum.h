//
//  HelloWorldLayer.h
//  targetSky
//
//  Created by Samuel Mascarell on 19/05/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import <GameKit/GameKit.h>
#import "Joystick.h"
#import "SimpleAudioEngine.h"

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "GameOverScene.h"

// HelloWorldLayer
@interface CataPum : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
    CGSize winSize;
    Joystick *joystick;
    CCLayer *l1,*l2,*l3,*l4;    // Capas para los gráficos
    CCSprite *background;       // Capa para el fondo
    CCSprite *player;           // Capa para nuestra nave
    CGPoint velocity;           // Array para la velocidad
    
    NSMutableArray *arrayBomb;  //array para almacenar las bombas de los malos
    NSMutableArray *arrayMisil; //array para almacenar los misiles que disparamos
    
    CCSpriteBatchNode *explosionAnimada; //Explosion
    
    int puntuacion;
    int puntuacionVisible;
    CCLabelTTF *labelScore;

}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

-(void)BuildBackground;
-(void)BuildJoystick;
-(void)BuildPlayer;
-(void)updateJoystick: (ccTime) delta;
-(void)createTargets: (ccTime) delta;
-(void)targetFinished:(id)sender;
-(void)petardacoFinished:(id)sender;
-(void)explosionFinished:(id)sender;
-(void)CreateExplosion:(int)x y:(int)y;

@end
