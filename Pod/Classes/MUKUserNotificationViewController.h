#import <UIKit/UIKit.h>
#import <MUKUserNotificationViewController/MUKUserNotification.h>
#import <MUKUserNotificationViewController/MUKUserNotificationView.h>

extern NSTimeInterval const MUKUserNotificationViewControllerDefaultMinimumIntervalBetweenNotifications;

typedef NS_ENUM(NSInteger, MUKUserNotificationViewPresentation) {
    MUKUserNotificationViewPresentationReplaceStatusBar = 0,
    MUKUserNotificationViewPresentationBehindStatusBar
};

/**
 View controller which displays an user notifications on top.
 Usually, especially on phones, you would use it as root view controller.
 */
@interface MUKUserNotificationViewController : UIViewController
/**
 Contained view controller.
 This view controller is about actual content you want to display to user.
 You can assign it in order to perform view controller containment inside 
 -willWillAppear:. If you use storyboards this ivar will be automatically
 filled at -viewDidLoad.
 */
@property (nonatomic, strong) UIViewController *contentViewController;
/**
 How notifications are presented to user.
 It defaults to `MUKUserNotificationViewPresentationReplaceStatusBar`, which means
 status bar is hidden before to show notification views.
 Otherwise you could set `MUKUserNotificationViewPresentationBehindStatusBar` mode,
 which means status bar is never hidden and notification views slide under it.
 */
@property (nonatomic) MUKUserNotificationViewPresentation notificationViewsPresentation;
/**
 The amount of time which has to pass between a notification presentation and
 another.
 It defaults to `MUKUserNotificationViewControllerDefaultMinimumIntervalBetweenNotifications`.
 */
@property (nonatomic) NSTimeInterval minimumIntervalBetweenNotifications;
/**
 Notification views tend to adapt to contained navigation bar height.
 Default is YES. If YES and if notification view height is not too far from
 navigation bar one, the notification view's frame is slightly increased in order
 to fill navigation bar space.
 */
@property (nonatomic) BOOL notificationViewsSnapToNavigationBar;
/**
 Notifications which are displayed or pending (due rate limit).
 Keep in mind that not all notifications are currently displayed.
 */
@property (nonatomic, readonly) NSArray *notifications;
/**
 The latest notification which has been displayed.
 */
@property (nonatomic, readonly) MUKUserNotification *visibleNotification;
/**
 Display a notification.
 @param notification Notification which will be added to notifications and displayed
 if minimumIntervalBetweenNotifications has passed.
 @param animated If YES, notification view will be presented with an animation.
 @param completionHandler A block which will be invoked as transition finishes.
 */
- (void)showNotification:(MUKUserNotification *)notification animated:(BOOL)animated completion:(void (^)(BOOL completed))completionHandler;
/**
 Hide a notification.
 @param notification Notification which will be removed from notifications and 
 hidden. You could also hide a notification which has not been presented yet (due
 rate limit).
 @param animated If YES, notification view will be hidden with an animation.
 @param completionHandler A block which will be invoked as transition finishes.
 */
- (void)hideNotification:(MUKUserNotification *)notification animated:(BOOL)animated completion:(void (^)(BOOL completed))completionHandler;
@end

@interface MUKUserNotificationViewController (Expiration)
/**
 Callback invoked when an expired notification is about to be hidden.
 @param notification Notification which will be removed from notifications and
 hidden.
 */
- (void)notificationWillExpire:(MUKUserNotification *)notification;
/**
 Callback invoked when an expired notification has been hidden.
 @param notification Notification which has been removed from notifications and
 hidden.
 */
- (void)notificationDidExpire:(MUKUserNotification *)notification;
@end

@interface MUKUserNotificationViewController (NotificationView)
/**
 Search presented view for a notification.
 @param notification Notification to search for.
 @return The view which is displayed for a notification. It could return nil.
 */
- (MUKUserNotificationView *)viewForNotification:(MUKUserNotification *)notification;
/**
 Search notification for a presented view.
 @param view Notification view to search for.
 @return The notification for a displayed notification view. It could return nil.
 */
- (MUKUserNotification *)notificationForView:(MUKUserNotificationView *)view;
/**
 Creates new notification view.
 @param notification The notification which originates this view.
 @return A new notification view.
 */
- (MUKUserNotificationView *)newViewForNotification:(MUKUserNotification *)notification;
/**
 Configures a new notification view with notification details.
 @param view The view to configure.
 @param notification The notification which originates this view.
 */
- (void)configureView:(MUKUserNotificationView *)view forNotification:(MUKUserNotification *)notification;
/**
 Frame for notification view.
 @param view The notification view. It will be inkoved -sizeThatFits: on it.
 @param notification The notification model object.
 @param minimumSize The minimum size for resulting frame.
 @return The frame that will be set on view.
 */
- (CGRect)frameForView:(MUKUserNotificationView *)view notification:(MUKUserNotification *)notification minimumSize:(CGSize)minimumSize;
/**
 Callback for tap gesture.
 It no tap gesture handler is set inside notification, it automatically hides
 the view.
 @param view The view where gesture occured.
 @param notification The notification which view displays.
 */
- (void)didTapView:(MUKUserNotificationView *)view forNotification:(MUKUserNotification *)notification;
/**
 Callback for pan up gesture.
 It no pan up gesture handler is set inside notification, it automatically hides
 the view.
 @param view The view where gesture occured.
 @param notification The notification which view displays.
 */
- (void)didPanUpView:(MUKUserNotificationView *)view forNotification:(MUKUserNotification *)notification;
@end

@interface MUKUserNotificationViewController (NavigationControllers)
/**
 Navigation controllers contained inside contentViewController.
 Default implementation does its best to autodiscover nested navigation controllers,
 by checking tab bar controllers and split view controllers.
 @return An array of all navigation controllers affected by notification view
 presentation. Those view controllers will be used in order to find navigation
 bar height and to fix strange behaviors that occur after device rotation.
 */
- (NSArray *)affectedNavigationControllers;
@end
