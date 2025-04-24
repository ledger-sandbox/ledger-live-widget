//
//  WalletWidgetModule.m
//  ledgerlivemobile
//
//  Created by Robin VINCENT on 24/04/2025.
//  Copyright © 2025 Ledger SAS. All rights reserved.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(WalletWidgetModule, NSObject)

RCT_EXTERN_METHOD(updateWalletData:(NSString *)price
                  percentage:(double)percentage
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
