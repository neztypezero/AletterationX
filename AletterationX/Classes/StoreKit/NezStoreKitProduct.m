//
//  NezStoreKitProduct.m
//  Aletteration3
//
//  Created by David Nesbitt on 2014/01/23.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import "NezStoreKitProduct.h"

@implementation NezStoreKitProduct

-(id)initWithProductIdentifier:(NSString *)productIdentifier {
	if ((self = [super init])) {
		self.availableForPurchase = NO;
		_productIdentifier = productIdentifier;
		self.skProduct = nil;
	}
	return self;
}

-(NSString*)getLocalizedPrice {
	if (self.availableForPurchase && self.skProduct) {
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[numberFormatter setLocale:self.skProduct.priceLocale];
		
		return [numberFormatter stringFromNumber:self.skProduct.price];
	} else {
		return @"N/A";
	}
}

@end
