//
//  NezAletterationStoreKit.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/23.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezAletterationStoreKit.h"
#import "NezStoreKitProduct.h"

static const NSString *sharedSecret = @"a609aa72f2e24f42b8afe0e43a42e036";

@implementation NezAletterationStoreKit

+(NezAletterationStoreKit *)sharedInstance {
	static dispatch_once_t once;
	static NezAletterationStoreKit *sharedInstance;
	dispatch_once(&once, ^{
		NSArray *productIdentifierList = @[
			@"com.nezsoft.Aletteration3.iap.undo.X0010",
			@"com.nezsoft.Aletteration3.iap.undo.X0025",
			@"com.nezsoft.Aletteration3.iap.undo.X0100",
			@"com.nezsoft.Aletteration3.iap.undo.X0250",
			@"com.nezsoft.Aletteration3.iap.undo.X1000",
		];
		NSMutableDictionary * productDictionary = [NSMutableDictionary dictionaryWithCapacity:productIdentifierList.count];
		for (NSString *productIdentifier in productIdentifierList) {
			[productDictionary setObject:[[NezStoreKitProduct alloc] initWithProductIdentifier:productIdentifier] forKey:productIdentifier];
			
		}
		sharedInstance = [[self alloc] initWithProducts:productDictionary];
	});
	return sharedInstance;
}

@end
