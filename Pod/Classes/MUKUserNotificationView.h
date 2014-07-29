#import <UIKit/UIKit.h>

/**
 View which displays an user notification.
 */
@interface MUKUserNotificationView : UIView
/**
 Label which displays notification's title.
 It is layed out completely inside -layoutSubviews.
 */
@property (nonatomic, weak, readonly) UILabel *titleLabel;
/**
 Label which displays notification's text.
 It is layed out completely inside -layoutSubviews.
 */
@property (nonatomic, weak, readonly) UILabel *textLabel;
/**
 Padding for content layout.
 It defaults to +defaultPadding.
 */
@property (nonatomic) UIEdgeInsets padding;
/**
 Gesture recognizer for tap gestures.
 */
@property (nonatomic, readonly) UITapGestureRecognizer *tapGestureRecognizer;
/**
 Gesture recognizer for pan gestures.
 */
@property (nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;
/**
 Default value for padding.
 `(4.0f, 8.0f, 4.0f, 8.0f)`
 */
+ (UIEdgeInsets)defaultPadding;
@end
