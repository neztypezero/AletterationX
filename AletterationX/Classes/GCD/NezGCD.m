//
//  NezGCD.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-21.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezGCD.h"

@implementation NezGCD

//This function runs workBlock in the given queue
+(void)runOnQueue:(dispatch_queue_t)queue WithWorkBlock:(NezVoidBlock)workBlock {
	[self runOnQueue:queue WithWorkBlock:workBlock DoneBlock:nil];
}

//This function runs workBlock in the given queue and then when that's done runs doneBlock in the Main Thread
+(void)runOnQueue:(dispatch_queue_t)queue WithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock {
	dispatch_async(queue, ^{
		if (workBlock != NULL) {
			workBlock();
		}
		if (doneBlock != NULL) {
			dispatch_async(dispatch_get_main_queue(), ^{
				doneBlock();
			});
		}
	});
}


//This function runs workBlock in the given queue after specified number of seconds
+(void)runOnQueue:(dispatch_queue_t)queue afterSeconds:(double)seconds WithWorkBlock:(NezVoidBlock)workBlock {
	[self runOnQueue:queue afterMilliseconds:seconds*1000.0 WithWorkBlock:workBlock DoneBlock:nil];
}

//This function runs workBlock in the given queue after specified number of milliseconds
+(void)runOnQueue:(dispatch_queue_t)queue afterMilliseconds:(double)milliseconds WithWorkBlock:(NezVoidBlock)workBlock {
	[self runOnQueue:queue afterMilliseconds:milliseconds WithWorkBlock:workBlock DoneBlock:nil];
}

//This function runs workBlock in the given queue after specified number of seconds and when that's done runs doneBlock in the Main Thread
+(void)runOnQueue:(dispatch_queue_t)queue afterSeconds:(double)seconds WithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock {
	[self runOnQueue:queue afterMilliseconds:seconds*1000.0 WithWorkBlock:workBlock DoneBlock:doneBlock];
}

//This function runs workBlock in the given queue after specified number of milliseconds and when that's done runs doneBlock in the Main Thread
+(void)runOnQueue:(dispatch_queue_t)queue afterMilliseconds:(double)milliseconds WithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock {
	if (workBlock != NULL) {
		uint64_t interval = milliseconds * NSEC_PER_MSEC;
		uint64_t leeway = 0;
		dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
		
		dispatch_source_set_event_handler(timer, ^{
			dispatch_source_cancel(timer); // one shot timer
			workBlock();
			if (doneBlock != NULL) {
				dispatch_async(dispatch_get_main_queue(), ^{
					doneBlock();
				});
			}
		});
		dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval), DISPATCH_TIME_FOREVER, leeway);
		dispatch_resume(timer);
	}
}

//This function runs workBlock in the High Priority Queue
+(void)runHighPriorityWithWorkBlock:(NezVoidBlock)workBlock {
	[self runOnQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) WithWorkBlock:workBlock DoneBlock:nil];
}

//This function runs workBlock in the High Priority Queue and then when that's done runs doneBlock in the Main Thread
+(void)runHighPriorityWithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock {
	[self runOnQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) WithWorkBlock:workBlock DoneBlock:doneBlock];
}

//This function runs workBlock in the Default Priority Queue
+(void)runDefaultPriorityWithWorkBlock:(NezVoidBlock)workBlock {
	[self runOnQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) WithWorkBlock:workBlock DoneBlock:nil];
}

//This function runs workBlock in the Default Priority Queue and then when that's done runs doneBlock in the Main Thread
+(void)runDefaultPriorityWithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock {
	[self runOnQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) WithWorkBlock:workBlock DoneBlock:doneBlock];
}

//This function runs workBlock in the Low Priority Queue
+(void)runLowPriorityWithWorkBlock:(NezVoidBlock)workBlock {
	[self runOnQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0) WithWorkBlock:workBlock DoneBlock:nil];
}

//This function runs workBlock in the Low Priority Queue and then when that's done runs doneBlock in the Main Thread
+(void)runLowPriorityWithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock {
	[self runOnQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0) WithWorkBlock:workBlock DoneBlock:doneBlock];
}

//This function runs workBlock in the Background Priority Queue
+(void)runBackgroundPriorityWithWorkBlock:(NezVoidBlock)workBlock {
	[self runOnQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0) WithWorkBlock:workBlock DoneBlock:nil];
}

//This function runs workBlock in the Background Priority Queue and then when that's done runs doneBlock in the Main Thread
+(void)runBackgroundPriorityWithWorkBlock:(NezVoidBlock)workBlock DoneBlock:(NezVoidBlock)doneBlock {
	[self runOnQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0) WithWorkBlock:workBlock DoneBlock:doneBlock];
}

//calls dispatch_async using the block and dispatch_get_main_queue
+(void)dispatchBlock:(NezVoidBlock)block {
	if (block != NULL) {
		dispatch_async(dispatch_get_main_queue(), ^{
			block();
		});
	}
}

//runs block on Main Thread after specified number of milliseconds
+(void)dispatchBlock:(NezVoidBlock)block afterMilliseconds:(double)milliseconds {
	[self runOnQueue:dispatch_get_main_queue() afterMilliseconds:milliseconds WithWorkBlock:block DoneBlock:nil];
}

//runs block on Main Thread after specified number of seconds
+(void)dispatchBlock:(NezVoidBlock)block afterSeconds:(double)seconds {
	[self runOnQueue:dispatch_get_main_queue() afterMilliseconds:seconds*1000.0 WithWorkBlock:block DoneBlock:nil];
}

@end
