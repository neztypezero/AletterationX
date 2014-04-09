//
//  NezStoreKit.m
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/23.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import "NezStoreKit.h"
#import "NezStoreKitProduct.h"

@implementation NezStoreKit {
	SKProductsRequest * _productsRequest;

	NezStoreKitRequestProductsCompletionHandler _completionHandler;
	NSDictionary * _productDictionary;
	NSMutableSet * _purchasedProductIdentifiers;
}

-(id)initWithProducts:(NSDictionary*)productDictionary {
	if ((self = [super init])) {
		 // Store product identifiers
		 _productDictionary = productDictionary;
		 
//		 // Check for previously purchased products
//		 _purchasedProductIdentifiers = [NSMutableSet set];
//		 for (NSString * productIdentifier in _productIdentifiers) {
//			 BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
//			 if (productPurchased) {
//				 [_purchasedProductIdentifiers addObject:productIdentifier];
//				 NSLog(@"Previously purchased: %@", productIdentifier);
//			 } else {
//				 NSLog(@"Not purchased: %@", productIdentifier);
//			 }
//		 }
//		 [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

-(void)requestProductsWithCompletionHandler:(NezStoreKitRequestProductsCompletionHandler)completionHandler {
	_completionHandler = [completionHandler copy];
	
	NSMutableSet * productIdentifiers =
	[NSMutableSet setWithCapacity:_productDictionary.count];
	for (NezStoreKitProduct * product in _productDictionary.allValues) {
		product.availableForPurchase = NO;
		[productIdentifiers addObject:product.productIdentifier];
	}
	_productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
	_productsRequest.delegate = self;
	[_productsRequest start];
	
}

-(BOOL)productPurchased:(NSString *)productIdentifier {
	return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

-(void)buyProduct:(SKProduct *)product {
	
	NSLog(@"Buying %@...", product.productIdentifier);
	
	SKPayment * payment = [SKPayment paymentWithProduct:product];
	[[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - SKProductsRequestDelegate

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
	
	NSLog(@"Loaded list of products...");
	_productsRequest = nil;
	
	NSArray * skProducts = response.products;
	for (SKProduct * skProduct in skProducts) {
		NezStoreKitProduct *product = _productDictionary[skProduct.productIdentifier];
		product.skProduct = skProduct;
		product.availableForPurchase = YES;
		NSLog(@"Found product: %@ %@ %0.2f", skProduct.productIdentifier, skProduct.localizedTitle, skProduct.price.floatValue);
	}
	for (NSString * invalidProductIdentifier in response.invalidProductIdentifiers) {
		NezStoreKitProduct * product = _productDictionary[invalidProductIdentifier];
		product.availableForPurchase = NO;
		NSLog(@"Invalid product identifier, removing: %@", invalidProductIdentifier);
	}
	NSMutableArray *availableProducts = [NSMutableArray array];
	for (NezStoreKitProduct *product in _productDictionary.allValues) {
		if (product.availableForPurchase) {
			[availableProducts addObject:product];
		}
	}
	_completionHandler(YES, availableProducts);
	_completionHandler = nil;
	
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"Failed to load list of products: %@", error.localizedDescription);
	_productsRequest = nil;
	
	_completionHandler(NO, nil);
	_completionHandler = nil;
	
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
	for (SKPaymentTransaction * transaction in transactions) {
		switch (transaction.transactionState) {
			case SKPaymentTransactionStatePurchased: {
				[self completeTransaction:transaction];
				break;
			} case SKPaymentTransactionStateFailed: {
				[self failedTransaction:transaction];
				break;
			} case SKPaymentTransactionStateRestored: {
				[self restoreTransaction:transaction];
			} default: {
				break;
			}
		}
	}
}

-(void)completeTransaction:(SKPaymentTransaction *)transaction {
	NSLog(@"completeTransaction...");
	
	[self provideContentForProductIdentifier:transaction.payment.productIdentifier];
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void)restoreTransaction:(SKPaymentTransaction *)transaction {
	NSLog(@"restoreTransaction...");
	
	[self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void)failedTransaction:(SKPaymentTransaction *)transaction {
	NSLog(@"failedTransaction...");
	if (transaction.error.code != SKErrorPaymentCancelled) {
		NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
	}
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

-(void)provideContentForProductIdentifier:(NSString *)productIdentifier {
	[_purchasedProductIdentifiers addObject:productIdentifier];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[[NSNotificationCenter defaultCenter] postNotificationName:NEZ_ALETTERATION_NOTIFICATION_PRODUCT_PURCHASE object:productIdentifier userInfo:nil];
	
}

@end
