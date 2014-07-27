//
//  MUKUserNotificationView.m
//  MUKUserNotificationViewController
//
//  Created by Marco on 26/07/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "MUKUserNotificationView.h"

@implementation MUKUserNotificationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CommonInit(self);
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        CommonInit(self);
    }
    
    return self;
}

#pragma mark - Private

static void CommonInit(MUKUserNotificationView *me) {
    [me createAndAttachGestureRecognizers];
}

- (void)createAndAttachGestureRecognizers {
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [self addGestureRecognizer:_tapGestureRecognizer];
    
    _swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] init];
    _swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:_swipeUpGestureRecognizer];
}

@end
