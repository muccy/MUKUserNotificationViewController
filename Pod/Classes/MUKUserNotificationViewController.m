//
//  MUKUserNotificationViewController.m
//  MUKUserNotificationViewController
//
//  Created by Marco on 25/07/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "MUKUserNotificationViewController.h"

static NSTimeInterval const kNotificationViewAnimationDuration = 0.2;
static CGFloat const kDefaultStatusBarHeight = 20.0f;

@interface MUKUserNotificationViewController ()
@property (nonatomic, readwrite) MUKUserNotification *displayedNotification;

@property (nonatomic) BOOL viewWillAppearAlreadyCalled;
@property (nonatomic) CGFloat statusBarHeight;
@end

@implementation MUKUserNotificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _statusBarHeight = kDefaultStatusBarHeight;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Before to call -viewWillAppear: try to autodetect an already inserted
    // content view controller
    [self setContentViewController:[self autodetectedContentViewController] attemptingInsertion:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self shouldInsertContentViewController:self.contentViewController]) {
        [self insertContentViewController:self.contentViewController];
    }
    
    self.viewWillAppearAlreadyCalled = YES;
}

#pragma mark - Overrides

- (BOOL)prefersStatusBarHidden {
    return self.displayedNotification != nil;
}

#pragma mark - Accessors

- (void)setContentViewController:(UIViewController *)contentViewController {
    [self setContentViewController:contentViewController attemptingInsertion:YES];
}

#pragma mark - Methods

- (void)showNotification:(MUKUserNotification *)notification animated:(BOOL)animated completion:(void (^)(BOOL))completionHandler
{
    if (!notification) {
        return;
    }
    
    // Mark as displayed notification
    self.displayedNotification = notification;
    
    // Get real status bar height is available
    [self captureStatusBarHeightIfAvailable];
    
    // Create notification view
    UIView *notificationView = [self newViewForUserNotification:notification];
    
    // Move offscreen
    CGAffineTransform const targetTransform = notificationView.transform;
    notificationView.transform = CGAffineTransformMakeTranslation(0.0f, -CGRectGetHeight(notificationView.frame));
    
    // Insert in view hierarchy
    [self.view addSubview:notificationView];
    
    // Animate in
    [UIView animateWithDuration:(animated ? kNotificationViewAnimationDuration : 0.0) delay:0.0 usingSpringWithDamping:1.0f initialSpringVelocity:1.0f options:0 animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
        notificationView.transform = targetTransform;

        self.contentViewController.view.frame = [self contentViewControllerFrameWithInsets:UIEdgeInsetsMake(self.statusBarHeight, 0.0f, 0.0f, 0.0f)];
    } completion:completionHandler];
}

#pragma mark - Private — Content View Controller

- (void)setContentViewController:(UIViewController *)contentViewController attemptingInsertion:(BOOL)attemptInsertion
{
    if (contentViewController != _contentViewController) {
        // Assign ivar
        UIViewController *const previousContentViewController = _contentViewController;
        _contentViewController = contentViewController;
        
        if (attemptInsertion) {
            // Insert directly if view has already appeared. Otherwise everything is
            // postponed to first -viewWillAppear: invocation, when view's bounds
            // are well defined
            if (self.viewWillAppearAlreadyCalled) {
                [self removeContentViewController:previousContentViewController];
                
                if ([self shouldInsertContentViewController:contentViewController]) {
                    [self insertContentViewController:contentViewController];
                }
            }
        }
    }
}

#pragma mark - Private — Containment

- (BOOL)shouldInsertContentViewController:(UIViewController *)viewController {
    // Insert if not already inserted
    return viewController && ![viewController.parentViewController isEqual:self];
}

- (BOOL)isCurrentContentViewController:(UIViewController *)viewController {
    return [viewController isEqual:self.contentViewController];
}

- (CGRect)contentViewControllerFrameWithInsets:(UIEdgeInsets)insets {
    return UIEdgeInsetsInsetRect(self.view.bounds, insets);
}

- (void)insertContentViewController:(UIViewController *)viewController
{
    // Also calls -willMoveToParentViewController: automatically.
    // This method is only intended to be called by an implementation
    // of a custom container view controller (so parents add children)
    [self addChildViewController:viewController];
    
    viewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    viewController.view.frame = [self contentViewControllerFrameWithInsets:UIEdgeInsetsZero];
    viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:viewController.view];
    
    [viewController didMoveToParentViewController:self];
}

- (void)removeContentViewController:(UIViewController *)viewController {
    if ([self isCurrentContentViewController:viewController]) {
        [viewController willMoveToParentViewController:nil];
        [viewController.view removeFromSuperview];
       
        // Also calls -didMoveToParentViewController: automatically.
        // This method is only intended to be called by an implementation
        // of a custom container view controller (so parents remove children)
        [viewController removeFromParentViewController];
    }
}

- (UIViewController *)autodetectedContentViewController {
    // Get child view controllers (e.g.: set in storyboard)
    for (UIViewController *viewController in self.childViewControllers) {
        if ([viewController.view.superview isEqual:self.view] &&
            CGRectEqualToRect(viewController.view.frame, self.view.bounds))
        {
            return viewController;
        }
    } // for
    
    return nil;
}

#pragma mark - Private — Notification View

- (UIView *)newViewForUserNotification:(MUKUserNotification *)notification {
    UIView *view = [[UIView alloc] initWithFrame:[self viewFrameForUserNotification:notification]];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    view.backgroundColor = [self viewBackgroundColorForUserNotification:notification];
    return view;
}

- (void)captureStatusBarHeightIfAvailable {
    if (![[UIApplication sharedApplication] isStatusBarHidden]) {
        CGRect const statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        CGFloat const statusBarHeight = fminf(CGRectGetWidth(statusBarFrame), CGRectGetHeight(statusBarFrame));
        
        if (statusBarHeight > 0.0f) {
            self.statusBarHeight = statusBarHeight;
        }
    }
}

- (CGRect)viewFrameForUserNotification:(MUKUserNotification *)notification {
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(CGRectGetWidth(self.view.bounds), self.statusBarHeight);
    return frame;
}

- (UIColor *)viewBackgroundColorForUserNotification:(MUKUserNotification *)notification
{
    return [UIColor redColor];
}

@end
