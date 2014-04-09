//
//  NezStoreKit.h
//  Aletteration3
//
//  Created by David Nesbitt on 2013/11/23.
//  Copyright (c) 2013 David Nesbitt. All rights reserved.
//

#import <StoreKit/StoreKit.h>

#define NEZ_ALETTERATION_NOTIFICATION_PRODUCT_PURCHASE @"NEZ_ALETTERATION_NOTIFICATION_PRODUCT_PURCHASE"

typedef void (^NezStoreKitRequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface NezStoreKit : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>

-(id)initWithProducts:(NSDictionary*)productDictionary;

-(void)requestProductsWithCompletionHandler:(NezStoreKitRequestProductsCompletionHandler)completionHandler;

-(void)buyProduct:(SKProduct *)product;
-(BOOL)productPurchased:(NSString *)productIdentifier;

@end