//
//  NezGCD.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-21.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

typedef void (^ NezVoidBlock)(void);
typedef void (^ NezCompletionHandler)(BOOL finished);

@interface NezGCD : NSObject

//This function runs workBlock in the given queue
+(void)runOnQueue:(dispatch_queue_t)queue WithWorkBlock:(NezVoidBlock)workBlock;

//This function runs workBlock in the given queue and then when that's done runs doneBlock in the Main Thread
+(void)runOnQueue:(dispatch_queue_t)queue WithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock;

//This function runs workBlock in the given queue after specified number of seconds
+(void)runOnQueue:(dispatch_queue_t)queue afterSeconds:(double)seconds WithWorkBlock:(NezVoidBlock)workBlock;

//This function runs workBlock in the given queue after specified number of milliseconds
+(void)runOnQueue:(dispatch_queue_t)queue afterMilliseconds:(double)milliseconds WithWorkBlock:(NezVoidBlock)workBlock;

//This function runs workBlock in the given queue after specified number of seconds and when that's done runs doneBlock in the Main Thread
+(void)runOnQueue:(dispatch_queue_t)queue afterSeconds:(double)seconds WithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock;

//This function runs workBlock in the given queue after specified number of milliseconds and when that's done runs doneBlock in the Main Thread
+(void)runOnQueue:(dispatch_queue_t)queue afterMilliseconds:(double)milliseconds WithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock;

//This function runs workBlock in the High Priority Queue
+(void)runHighPriorityWithWorkBlock:(NezVoidBlock)workBlock;

//This function runs workBlock in the High Priority Queue and then when that's done runs doneBlock in the Main Thread
+(void)runHighPriorityWithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock;

//This function runs workBlock in the Default Priority Queue
+(void)runDefaultPriorityWithWorkBlock:(NezVoidBlock)workBlock;

//This function runs workBlock in the Default Priority Queue and then when that's done runs doneBlock in the Main Thread
+(void)runDefaultPriorityWithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock;

//This function runs workBlock in the Low Priority Queue
+(void)runLowPriorityWithWorkBlock:(NezVoidBlock)workBlock;

//This function runs workBlock in the Low Priority Queue and then when that's done runs doneBlock in the Main Thread
+(void)runLowPriorityWithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock;

//This function runs workBlock in the Background Priority Queue
+(void)runBackgroundPriorityWithWorkBlock:(NezVoidBlock)workBlock;

//This function runs workBlock in the Background Priority Queue and then when that's done runs doneBlock in the Main Thread
+(void)runBackgroundPriorityWithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock;

//calls dispatch_async using the block and dispatch_get_main_queue
+(void)dispatchBlock:(NezVoidBlock)block;

//runs block on Main Thread after specified number of milliseconds
+(void)dispatchBlock:(NezVoidBlock)block afterMilliseconds:(double)milliseconds;

//runs block on Main Thread after specified number of seconds
+(void)dispatchBlock:(NezVoidBlock)block afterSeconds:(double)seconds;

@end
