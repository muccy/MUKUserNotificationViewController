//
//  MUKUserNotificationViewController.h
//  MUKUserNotificationViewController
//
//  Created by Marco on 25/07/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MUKUserNotificationViewController/MUKUserNotification.h>
#import <MUKUserNotificationViewController/MUKUserNotificationView.h>

@interface MUKUserNotificationViewController : UIViewController
@property (nonatomic, strong) UIViewController *contentViewController;

@property (nonatomic, readonly) NSArray *notifications;
@property (nonatomic, readonly) MUKUserNotification *visibleNotification;

- (void)showNotification:(MUKUserNotification *)notification animated:(BOOL)animated completion:(void (^)(BOOL completed))completionHandler;
- (void)hideNotification:(MUKUserNotification *)notification animated:(BOOL)animated completion:(void (^)(BOOL completed))completionHandler;
@end

@interface MUKUserNotificationViewController (Expiration)
- (void)notificationWillExpire:(MUKUserNotification *)notification;
- (void)notificationDidExpire:(MUKUserNotification *)notification;
@end

@interface MUKUserNotificationViewController (NotificationView)
- (MUKUserNotificationView *)viewForNotification:(MUKUserNotification *)notification;
- (MUKUserNotification *)notificationForView:(MUKUserNotificationView *)view;

- (MUKUserNotificationView *)newViewForNotification:(MUKUserNotification *)notification;
- (void)configureView:(MUKUserNotificationView *)view forNotification:(MUKUserNotification *)notification;

- (void)didTapView:(MUKUserNotificationView *)view forNotification:(MUKUserNotification *)notification;
- (void)didSwipeUpView:(MUKUserNotificationView *)view forNotification:(MUKUserNotification *)notification;
@end
