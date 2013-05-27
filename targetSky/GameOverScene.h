//
//  GameOverScene.h
//  targetSky
//
//  Created by Samuel Mascarell on 27/05/13.
//
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"
#import "CataPum.h"

@interface GameOverLayer : CCLayerColor {
    CCLabelTTF *_label1;
    CCLabelTTF *_label2;
}
@property (nonatomic, retain) CCLabelTTF *label1;
@property (nonatomic, retain) CCLabelTTF *label2;
@end


@interface GameOverScene : CCScene {
    GameOverLayer *_layer;
}
@property (nonatomic, retain) GameOverLayer *layer;
@end
