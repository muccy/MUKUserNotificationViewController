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

extern NSTimeInterval const MUKUserNotificationViewControllerDefaultMinimumIntervalBetweenNotifications;

typedef NS_ENUM(NSInteger, MUKUserNotificationViewPresentation) {
    MUKUserNotificationViewPresentationReplaceStatusBar = 0,
    MUKUserNotificationViewPresentationBehindStatusBar
};

@interface MUKUserNotificationViewController : UIViewController
@property (nonatomic, strong) UIViewController *contentViewController;
@property (nonatomic) MUKUserNotificationViewPresentation notificationViewsPresentation;
@property (nonatomic) NSTimeInterval minimumIntervalBetweenNotifications;

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
- (CGRect)frameForView:(MUKUserNotificationView *)view notification:(MUKUserNotification *)notification minimumSize:(CGSize)minimumSize;

- (void)didTapView:(MUKUserNotificationView *)view forNotification:(MUKUserNotification *)notification;
- (void)didSwipeUpView:(MUKUserNotificationView *)view forNotification:(MUKUserNotification *)notification;
@end

@interface MUKUserNotificationViewController (NavigationControllers)
- (NSArray *)affectedNavigationControllers;
@end
