//
//  HelloWorldLayer.m
//  targetSky
//
//  Created by Samuel Mascarell on 19/05/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "CataPum.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation CataPum

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	CataPum *layer = [CataPum node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        
        winSize = [[CCDirector sharedDirector]winSize];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"CataPum.mp3" loop:YES];

        //instanciamos las capas
        l1 = [CCLayer node];
        l2 = [CCLayer node];
        l3 = [CCLayer node];
        l4 = [CCLayer node];
        
        //Instanciamos los arrays para los misiles y bombas
        
        arrayBomb = [[NSMutableArray alloc] init];
        arrayMisil = [[NSMutableArray alloc] init];

        //Añadimos las capas a la principal
        
        [self addChild:l1];
        [self addChild:l2];
        [self addChild:l3];
        [self addChild:l4];
    
        [self BuildBackground];
        [self BuildJoystick];
        [self BuildPlayer];
        
        
        //Le decimos a Cocos2d que nos devuelva los eventos touch
        self.isTouchEnabled = YES;

        //Le decimos a Cocos2d que permita multitouch

        [[[CCDirector sharedDirector] openGLView] setMultipleTouchEnabled:YES];
        
        //Inicializamos la puntuación
        labelScore = [CCLabelTTF labelWithString:@"Score:" fontName:@"Marker Felt" fontSize:32];
        labelScore.position =  ccp(labelScore.contentSize.width / 2 , winSize.height - labelScore.contentSize.height);
        [labelScore setColor:ccBLACK];
        [l4 addChild:labelScore];
        
        puntuacion = 0;
        puntuacionVisible = 0;

        [self schedule: @selector(updateJoystick:)];
        [self schedule: @selector(createTargets:) interval:1.0];
        [self schedule: @selector(updateCollisions:)];
         [self schedule: @selector(updateScore:)];

	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
}

-(void)BuildBackground {
    
    //Cargamos la imagen de fondo
    
    CGSize winSize = [[CCDirector sharedDirector]winSize];
    background = [CCSprite spriteWithFile:@"background.jpg"];
    background.position = ccp(winSize.width/2, winSize.height/2);
    [l1 addChild:background];
    
}

-(void)BuildJoystick {
    
    //Creamos y añadimos el Sprite del joystick
    CCSprite *joystickSprite = [CCSprite spriteWithFile:@"Joystick.png"];
    joystickSprite.position = ccp(60,60);
    [l4 addChild:joystickSprite];
    
    CCSprite *buttonA = [CCSprite spriteWithFile:@"ButtonA.png"];
    buttonA.position = ccp(480 - 42 - 84, 42);
    [l4 addChild:buttonA];
    
    CCSprite *buttonB = [CCSprite spriteWithFile:@"ButtonB.png"];
    buttonB.position = ccp(480 - 42, 42);
    [l4 addChild:buttonB];
    
    //Creamos el objeto para controlar el Joystick
    joystick = [[Joystick alloc]init];
    [joystick addStick:@"Stick1" rect:CGRectMake(0, 0, 120, 120)];
    [joystick addButton:@"A" rect:CGRectMake(buttonA.position.x-32, buttonA.position.y-32,64,64)];
    [joystick addButton:@"B" rect:CGRectMake(buttonB.position.x-32, buttonB.position.y-32,64,64)];
    
    [joystick setDelayFor:@"A" delay:0.5f];
    [joystick setDelayFor:@"B" delay:1.0f];
    
    
    if([joystick isDown:@"A"])
        [self PlayerShoot];
    
    if([joystick isDown:@"B"])
    {
        [self PlayerShoot];
        [self PlayerShoot]; 
    } 
}

-(void)BuildPlayer {
    CGSize winSize = [[CCDirector sharedDirector]winSize];
    player = [CCSprite spriteWithFile:@"Player.png"];
    player.position = ccp(winSize.width/2, winSize.height/2);
    [l3 addChild:player]; // capa 3 para nuestro player 
}
-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [joystick touchesBegan:touches withEvent:event];
}
-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [joystick touchesMoved:touches withEvent:event];
}
-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [joystick touchesEnded:touches withEvent:event];
}


-(void) updateJoystick: (ccTime) delta
{
    if([joystick isDown:@"A"])
        [self PlayerShoot];
    
    if([joystick isDown:@"B"])
    {
        [self PlayerShoot];
        [self PlayerShoot]; 
    } 
    
    CGPoint newPosition;
    
    //sacamos la velocidad del joystick
    CGPoint jvel = [joystick getVelocity:@"Stick1"];
    
    // y controlamos los limites
    if(jvel.x<-60) jvel.x = -60;
    if(jvel.x> 60) jvel.x =  60;
    if(jvel.y<-60) jvel.y = -60;
    if(jvel.y> 60) jvel.y =  60;
    
    // incrementamos la velocidad a nuestro vector
    // delta nos indica el tiempo desde la última vez que pasamos por esta funcion
    // lo tomamos
    velocity.x += jvel.x * delta;
    velocity.y += jvel.y * delta;
    
    // esto nos añade la resistencia necesaria para frenar el avion
    // si dejamos de pulsar el joystick
    velocity.x *= .9f;
    velocity.y *= .9f;
    
    // calculamos la nueva posición
    newPosition.x = player.position.x + velocity.x;
    newPosition.y = player.position.y + velocity.y;
    
    // y una vez mas controlamos los limites para no salir de la pantalla
    int sizex = player.contentSize.width / 2;
    int sizey = player.contentSize.height / 2;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    if(newPosition.x < sizex) newPosition.x = sizex;
    if(newPosition.x > winSize.width -sizex) newPosition.x = winSize.width-sizex;
    if(newPosition.y < sizey) newPosition.y = sizey;
    if(newPosition.y > winSize.height -sizey) newPosition.y = winSize.height -sizey;
   
    // ya está ... el player se mueve 
    [player setPosition:newPosition];
    
    //Actualizar la imagen de fondo según el movimiento del Player
    int cx = winSize.width/2;
    int cy = winSize.height/2;
    background.position = ccp(cx + (cx-player.position.x), cy + (cy-player.position.y));
    
}


-(void) createTargets: (ccTime) delta
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    CCSprite *target = [CCSprite spriteWithFile:@"Bomb.png" ];
    
    // Buscamos una X aleatoria .. en lugar de ir de 0 a 480
    // vamos a preocuparnos que ninguna bomba se salga por los limites latelares
    int minSizeX = target.contentSize.width / 2;
    int x = (arc4random() % (int)(winSize.width - minSizeX * 2) ) + minSizeX;
    int y = winSize.height + target.contentSize.height / 2;
    
    // El punto destino Y será abajo del todo
    int destY = 0 - target.contentSize.height/2;
    int duration = 10.0f;
    
    // le damos la posición de origen y creamos las acciones con el movimiento
    target.position = ccp(x,y);
    
    // la acción de movimiento y el evento cuando termine esta acción
    id action = [CCMoveTo actionWithDuration:duration position:ccp(x,destY)];
    id event  = [CCCallFuncN actionWithTarget:self selector:@selector(targetFinished:)];
    
    // y se las damos al petardaco para que lo ejecute
    [target runAction:[CCSequence actions:action, event, nil]];
    
    [l2 addChild:target]; // <- lo añadimos a la capa 2
    
    [arrayBomb addObject:target];
} 



-(void)targetFinished:(id)sender {
    // este metodo se llama cada vez que una bomba termina su accion
    // eliminamos el objeto de su capa
    CCSprite *sprite = (CCSprite *)sender;
    [l2 removeChild:sprite cleanup:YES];
    [arrayBomb removeObject:sprite];
} 


-(void) PlayerShoot
{
    // Sacamos las coordenadas del avion
    int x = player.position.x;
    int y = player.position.y - 18;
    
    // estas cordenadas son al centro del avion, asi que está bien
    // tirar los petardos desde ahi .. unicamente vamos a variar la coordenada
    // x para que cada petardo salga por un lado
    static int disparoCount = 0;
    disparoCount++;
    if(disparoCount % 2 == 0) x+=15;
    else x-=15;
    
    // Creamos el petardaco y le damos la posición de inicio
    CCSprite *petardaco = [CCSprite spriteWithFile:@"Misil.png" ];
    petardaco.position = ccp(x,y);
    
    // la posición fin será la misma x y en Y vamos a subir hasta que no se vea
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int posY = winSize.height + petardaco.contentSize.height / 2;
    
    // calculamos la velocidad que queremos para el petardo
    float len = posY - y;
    float vel = 320/1; // 320pixels/1sec
    float duration = len/vel;
    
    // creamos el sprite con nuestro disparo
    // la accion de movimiento y el evento cuando termine esta accion
    id action = [CCMoveTo actionWithDuration:duration position:ccp(x,posY)];
    id event  = [CCCallFuncN actionWithTarget:self selector:@selector(petardacoFinished:)];
    
    // y se las damos al petardaco para que lo ejecute
    [[SimpleAudioEngine sharedEngine] playEffect:@"Shoot.caf"]; 
    [petardaco runAction:[CCSequence actions:action, event, nil]];

    [l2 addChild:petardaco];
    [arrayMisil addObject:petardaco];
} 


-(void)petardacoFinished:(id)sender {
    CCSprite *sprite = (CCSprite *)sender;
    [l2 removeChild:sprite cleanup:YES];
    [arrayMisil removeObject:sprite];
}

- (void)updateCollisions:(ccTime)dt
{
    NSMutableArray *BombToDelete = [[NSMutableArray alloc] init];
    NSMutableArray *MisilToDelete = [[NSMutableArray alloc] init];
    
    // bucle para recorrer todas las bombas
    for (CCSprite *Bomb in arrayBomb)
    {
        CGRect BombRect = CGRectMake(Bomb.position.x - (Bomb.contentSize.width/2), Bomb.position.y - (Bomb.contentSize.height/2), Bomb.contentSize.width, Bomb.contentSize.height);
        
        // bucle para recorrer todos los misiles
        for (CCSprite *Misil in arrayMisil)
        {
            CGRect MisilRect = CGRectMake(Misil.position.x - (Misil.contentSize.width/2),Misil.position.y - (Misil.contentSize.height/2),  Misil.contentSize.width, Misil.contentSize.height);
            
            // comprobamos si los RECT de cada sprite colisionan
            if (CGRectIntersectsRect(BombRect, MisilRect))
            {
                [BombToDelete addObject:Bomb];
                [MisilToDelete addObject:Misil];
            }
        }
    }
    
    // destruimos las bombas
    for (CCSprite *Bomb in BombToDelete)
    {
        // Quitamos la bomba de su capa
        [l2 removeChild:Bomb cleanup:YES];
        // la borramos del array porque ya no está en juego
        [arrayBomb removeObject:Bomb];
        // creamos una explosion
        [self CreateExplosion:Bomb.position.x y:Bomb.position.y];
        puntuacion+=1;
    }
    
    // destruimos los Misiles
    for (CCSprite *Misil in MisilToDelete)
    {
        // Quitamos el misil de su capa, y de su array
        [l2 removeChild:Misil cleanup:YES]; 
        [arrayMisil removeObject:Misil]; 
    } 
    // una vez hemos terminado ya podemos liberar los arrays temporales 
    [BombToDelete release]; 
    [MisilToDelete release];
    
    
    // Sacamos el Rect de la nave - le restamos unos picos
    CGRect PlayerRect = CGRectMake(player.position.x - (player.contentSize.width/2) -8,
                                   player.position.y - (player.contentSize.height/2) - 15,
                                   player.contentSize.width -16,
                                   player.contentSize.height -15);
    
    // Bucle para recorrer todas las bombas
    for (CCSprite *Bomb in arrayBomb)
    {
        CGRect BombRect = CGRectMake(Bomb.position.x - (Bomb.contentSize.width/2) - 8,
                                     Bomb.position.y - (Bomb.contentSize.height/2) -15,
                                     Bomb.contentSize.width-16,
                                     Bomb.contentSize.height-15); 
        // Miramos si colisiona con alguna bomba 
        
        if (CGRectIntersectsRect(BombRect, PlayerRect))
        {
            // Paramos el audio y lanzamos un fx de gameover
            [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
            [[SimpleAudioEngine sharedEngine] playEffect:@"GameOver.caf"];
            
            // GAME OVER !!!!!
            // NSString * scoreStr = [self stringWithFormat:@"Score: %d", puntuacion];
            NSString *stringScore = [NSString stringWithFormat:@"Score: %d", puntuacion];
            
            // Creamos la escena y le damos los 2 strings, el GameOver y la puntuacion obtenida
            GameOverScene *gameOverScene = [GameOverScene node];
            [gameOverScene.layer.label1 setString:@"GAME OVER"];
            [gameOverScene.layer.label2 setString:stringScore];
            // Cambiamos a la escena del game over 
            [[CCDirector sharedDirector] replaceScene:gameOverScene]; 
        } 

    }

} 


-(void)CreateExplosion:(int)x y:(int)y
{
    
    // Load sprite frames, which are just a bunch of named rectangle
    // definitions that go along with the image in a sprite sheet
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"explosion.plist"];
    
    // Add the sprite as a child of the sheet, so that it knows where to get its image data.

    explosionAnimada = [CCSpriteBatchNode batchNodeWithFile:@"explosion.png"];

    [l3 addChild:explosionAnimada];
    [[SimpleAudioEngine sharedEngine] playEffect:@"Explosion.caf"]; 

    NSMutableArray *animFrames = [NSMutableArray array];
    for(int i = 1; i < 17; i++) {
        
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"Explosion%i.png",i]];
        [animFrames addObject:frame];
    }

    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.1f];
    
    id anim = [CCAnimate actionWithAnimation:animation];
    id finished  = [CCCallFuncN actionWithTarget:self selector:@selector(explosionFinished:)];
    
    // Finally, create a sprite, using the name of a frame in our frame cache.
    CCSprite *sprite1 = [CCSprite spriteWithSpriteFrameName:@"Explosion1.png"];
    sprite1.position = ccp(x,y);
    
    [explosionAnimada addChild:sprite1];
    
    [sprite1 runAction:[CCSequence actions:anim,finished,nil]];
}



-(void)explosionFinished:(id)sender {
    [l3 removeChild:explosionAnimada cleanup:YES];
}


- (void)updateScore:(ccTime)dt
{
    // no queremos tener puntuaciones negativas
    if(puntuacion < 0) puntuacion = 0;
    
    // puntuacionVisible se incrementa con una parte proporcional
    puntuacionVisible += (puntuacion - puntuacionVisible) * 0.3f;
    
    // arreglamos los fallos de coma flotante cuando estemos a 1 punto de diferencia
    if(puntuacionVisible == puntuacion-1 ) puntuacionVisible  = puntuacion;
    if(puntuacionVisible == puntuacion+1 ) puntuacionVisible = puntuacion;
    
    // pasamos el valor al Label de pantalla
    NSString *stringScore = [NSString stringWithFormat: @"Score: %d", puntuacionVisible];
    [labelScore setString:stringScore];
    
    labelScore.position =  ccp(labelScore.contentSize.width / 2 + 4, winSize.height - labelScore.contentSize.height / 2 -4);
} 




#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
