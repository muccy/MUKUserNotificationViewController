//
//  MUKUserNotification.h
//  MUKUserNotificationViewController
//
//  Created by Marco on 25/07/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSTimeInterval const MUKUserNotificationDurationInfinite;

@interface MUKUserNotification : NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) UIColor *color;
@end
