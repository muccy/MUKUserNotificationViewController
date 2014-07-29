//
//  MUKUserNotification.h
//  MUKUserNotificationViewController
//
//  Created by Marco on 25/07/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSTimeInterval const MUKUserNotificationDurationInfinite;

@class MUKUserNotificationView, MUKUserNotificationViewController;
typedef void (^MUKUserNotificationGestureHandler)(MUKUserNotificationViewController *viewController, MUKUserNotificationView *view);

@interface MUKUserNotification : NSObject
@property (nonatomic, copy) NSString *title, *text;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) UIColor *color, *textColor;
@property (nonatomic) id userInfo;

@property (nonatomic, copy) MUKUserNotificationGestureHandler tapGestureHandler, panUpGestureHandler;
@end
