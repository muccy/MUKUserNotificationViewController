#import <Foundation/Foundation.h>

extern NSTimeInterval const MUKUserNotificationDurationInfinite;

@class MUKUserNotificationView, MUKUserNotificationViewController;
typedef void (^MUKUserNotificationGestureHandler)(MUKUserNotificationViewController *viewController, MUKUserNotificationView *view);

/**
 Model object which represents an user notification to be presented.
 */
@interface MUKUserNotification : NSObject
/**
 Title of notification.
 It will have a bolder representation and it should be quite short.
 */
@property (nonatomic, copy) NSString *title;
/**
 Text of notification.
 It will have a lighter representation that title and it could be a bit longer,
 because it will be rendered inside a multi-line label.
 */
@property (nonatomic, copy) NSString  *text;
/**
 Duration of notification.
 The notification will be automatically dismissed after this amount of time.
 Default: `MUKUserNotificationDurationInfinite`, which means no expiration.
 */
@property (nonatomic) NSTimeInterval duration;
/**
 Background color of notification.
 If this property is nil, background color will be set to notification view 
 controller's tint color.
 */
@property (nonatomic) UIColor *color;
/**
 Text color of notification.
 If this property is nil, text color will be set to white.
 */
@property (nonatomic) UIColor *textColor;
/**
 Additional object you could attach to notification.
 You could use userInfo in order to find your notification between other ones.
 */
@property (nonatomic) id userInfo;
/**
 Tap handler.
 This block is called once user taps inside notification view.
 */
@property (nonatomic, copy) MUKUserNotificationGestureHandler tapGestureHandler;
/**
 Pan up handler.
 This block is called once user pan up inside notification view.
 */
@property (nonatomic, copy) MUKUserNotificationGestureHandler panUpGestureHandler;
@end
