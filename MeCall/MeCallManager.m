//
//  MeCallManager.m
//  MeCall
//
//  Created by u2systems on 13/07/2016.
//  Copyright © 2016 u2systems. All rights reserved.
//

#import "MeCallManager.h"
#import "linphonecore.h"

@implementation MeCallManager

static LinphoneCore* theLinphoneCore;


+ (NSUInteger)addBoth:(NSUInteger)a :(NSUInteger)b
{
    return a + b;
    
    
}

+ (void)createLinphoneCore {
    
    if (theLinphoneCore != nil)
        return;
}

@end
