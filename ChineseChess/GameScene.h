//
//  GameScene.h
//  ChineseChess
//
//  Created by gurdjieff on 12-12-28.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface GameScene : CCLayer
{
    CGSize screenSize;
    CCSpriteBatchNode * mpBatch;
    CCSprite * mpChessSprite;
    NSMutableArray * mpBlackSceneAry;
    NSMutableArray * mpRedSceneAry;
    CCSprite * winSprite;
    CCSprite * failSprite;
    int miLevel;
}
@property int level;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end