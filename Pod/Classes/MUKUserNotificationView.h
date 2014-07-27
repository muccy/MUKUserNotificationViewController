//
//  MUKUserNotificationView.h
//  MUKUserNotificationViewController
//
//  Created by Marco on 26/07/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MUKUserNotificationView : UIView
@property (nonatomic, readonly) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, readonly) UISwipeGestureRecognizer *swipeUpGestureRecognizer;
@end
