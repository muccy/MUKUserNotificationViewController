//
//  MUKUserNotification.m
//  MUKUserNotificationViewController
//
//  Created by Marco on 25/07/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "MUKUserNotification.h"

NSTimeInterval const MUKUserNotificationDurationInfinite = -1.0;

@implementation MUKUserNotification

- (id)init {
    self = [super init];
    if (self) {
        _duration = MUKUserNotificationDurationInfinite;
    }
    
    return self;
}

@end
