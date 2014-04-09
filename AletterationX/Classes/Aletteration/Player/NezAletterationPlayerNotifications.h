//
//  NezAletterationPlayerNotifications.h
//  AletterationX
//
//  Created by David Nesbitt on 2014/03/14.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>

#define NEZ_ALETTERATION_NOTIFICATION_PLAYER_MOVE_LETTER_BLOCK @"NEZ_ALETTERATION_NOTIFICATION_PLAYER_MOVE_LETTER_BLOCK"
#define NEZ_ALETTERATION_NOTIFICATION_PLAYER_PLACE_LETTER_BLOCK @"NEZ_ALETTERATION_NOTIFICATION_PLAYER_PLACE_LETTER_BLOCK"
#define NEZ_ALETTERATION_NOTIFICATION_PLAYER_RETIRE_WORD @"NEZ_ALETTERATION_NOTIFICATION_PLAYER_RETIRE_WORD"
#define NEZ_ALETTERATION_NOTIFICATION_PLAYER_END_TURN @"NEZ_ALETTERATION_NOTIFICATION_PLAYER_END_TURN"
#define NEZ_ALETTERATION_NOTIFICATION_PLAYER_START_TURN @"NEZ_ALETTERATION_NOTIFICATION_PLAYER_START_TURN"
#define NEZ_ALETTERATION_NOTIFICATION_PLAYER_GAMEOVER @"NEZ_ALETTERATION_NOTIFICATION_PLAYER_GAMEOVER"

@interface NezAletterationPlayerNotification : NSObject

@property NSUInteger playerIndex;

+(instancetype)notificationWithPlayerIndex:(NSUInteger)playerIndex;
-(instancetype)initWithPlayerIndex:(NSUInteger)playerIndex;

@end

@interface NezAletterationPlayerNotificationMoveLetterBlock : NezAletterationPlayerNotification

@property GLKVector3 position;
@property GLKQuaternion orientation;

+(instancetype)notificationWithPlayerIndex:(NSUInteger)playerIndex Position:(GLKVector3)position andOrientation:(GLKQuaternion)orientation;
-(instancetype)initWithPlayerIndex:(NSUInteger)playerIndex Position:(GLKVector3)position andOrientation:(GLKQuaternion)orientation;

@end

@interface NezAletterationPlayerNotificationLine : NezAletterationPlayerNotification

@property NSUInteger lineIndex;

+(instancetype)notificationWithPlayerIndex:(NSUInteger)playerIndex andLineIndex:(NSUInteger)lineIndex;
-(instancetype)initWithPlayerIndex:(NSUInteger)playerIndex andLineIndex:(NSUInteger)lineIndex;

@end
