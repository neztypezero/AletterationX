//
//  NezStoreKitProduct.h
//  Aletteration3
//
//  Created by David Nesbitt on 2014/01/23.
//  Copyright (c) 2014 David Nesbitt. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface NezStoreKitProduct : NSObject


-(id)initWithProductIdentifier:(NSString *)productIdentifier;

@property (nonatomic, strong) SKProduct * skProduct;
@property (readonly, strong) NSString * productIdentifier;
@property (nonatomic, assign) BOOL availableForPurchase;
@property (readonly, getter=getLocalizedPrice) NSString *localizedPrice;

@end
