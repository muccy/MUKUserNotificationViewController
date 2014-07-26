//
//  MUKUserNotificationViewController.h
//  MUKUserNotificationViewController
//
//  Created by Marco on 25/07/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MUKUserNotificationViewController/MUKUserNotification.h>

@interface MUKUserNotificationViewController : UIViewController
@property (nonatomic, strong) UIViewController *contentViewController;

@property (nonatomic, readonly) NSArray *notifications;
@property (nonatomic, readonly) MUKUserNotification *visibleNotification;

- (void)showNotification:(MUKUserNotification *)notification animated:(BOOL)animated completion:(void (^)(BOOL completed))completionHandler;
- (void)hideNotification:(MUKUserNotification *)notification animated:(BOOL)animated completion:(void (^)(BOOL completed))completionHandler;
@end
