//
//  LedgerLiveWidgetBridge.m
//  ledgerlivemobile
//
//  Created by Come GRELLARD on 23/04/2025.
//  Copyright © 2025 Ledger SAS. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(LedgerLiveWidgetModule, NSObject)

+ (bool)requiresMainQueueSetup {
  return NO;
}

RCT_EXTERN_METHOD(startLiveActivity:(NSString)tx)
RCT_EXTERN_METHOD(stopLiveActivity)

@end
