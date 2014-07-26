//
//  MUKUserNotificationViewController.m
//  MUKUserNotificationViewController
//
//  Created by Marco on 25/07/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "MUKUserNotificationViewController.h"

static NSTimeInterval const kNotificationViewAnimationDuration = 0.15;
static CGFloat const kNotificationViewAnimationSpringDamping = 1.0f;
static CGFloat const kNotificationViewAnimationSpringVelocity = 1.0f;
static CGFloat const kDefaultStatusBarHeight = 20.0f;

@interface MUKUserNotificationViewController ()
@property (nonatomic, readwrite) MUKUserNotification *displayedNotification;

@property (nonatomic) BOOL viewWillAppearAlreadyCalled;
@property (nonatomic) CGFloat statusBarHeight;
@property (nonatomic) NSMapTable *notificationToViewMapping;
@end

@implementation MUKUserNotificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    if ([self prefersStatusBarHidden]) {
        return nil;
    }
    
    return self.contentViewController;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.contentViewController;
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
    
    // Map view to notification
    [self setView:notificationView forUserNotification:notification];
    
    // Move offscreen
    CGAffineTransform const targetTransform = notificationView.transform;
    notificationView.transform = CGAffineTransformMakeTranslation(0.0f, -CGRectGetHeight(notificationView.frame));
    
    // Insert in view hierarchy
    [self.view addSubview:notificationView];
    
    // Animate in
    NSTimeInterval const duration = animated ? kNotificationViewAnimationDuration : 0.0;
    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:kNotificationViewAnimationSpringDamping initialSpringVelocity:kNotificationViewAnimationSpringVelocity options:0 animations:^{
        // Hide status bar
        [self setNeedsStatusBarAppearanceUpdate];
        
        // Resize content view controller
        self.contentViewController.view.frame = [self contentViewControllerFrameWithInsets:UIEdgeInsetsMake(self.statusBarHeight, 0.0f, 0.0f, 0.0f)];
        
        // Move notification view in
        notificationView.transform = targetTransform;
    } completion:completionHandler];
}

- (void)hideNotificationAnimated:(BOOL)animated completion:(void (^)(BOOL completed))completionHandler
{
    if (!self.displayedNotification) {
        return;
    }
    
    // Get view for notification
    UIView *const notificationView = [self viewForUserNotification:self.displayedNotification];
    
    // Set no displayed notification is here
    self.displayedNotification = nil;
    
    if (!notificationView) {
        return;
    }
    
    // Animate out
    NSTimeInterval const duration = animated ? kNotificationViewAnimationDuration : 0.0;
    
    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:kNotificationViewAnimationSpringDamping initialSpringVelocity:kNotificationViewAnimationSpringVelocity options:0 animations:^{
        // Move out
        notificationView.transform = CGAffineTransformMakeTranslation(0.0f, -CGRectGetHeight(notificationView.frame));
        
        // Resize content view controller
        self.contentViewController.view.frame = [self contentViewControllerFrameWithInsets:UIEdgeInsetsZero];
        
        // Show status bar (order matters!)
        [self setNeedsStatusBarAppearanceUpdate];
    } completion:^(BOOL finished) {
        // Remove view from view hierarchy
        [notificationView removeFromSuperview];
        
        // Notify completion if needed
        if (completionHandler) {
            completionHandler(finished);
        }
    }];
}

#pragma mark - Private 

static void CommonInit(MUKUserNotificationViewController *me) {
    me->_statusBarHeight = kDefaultStatusBarHeight;
    me->_notificationToViewMapping = [NSMapTable weakToWeakObjectsMapTable];
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
    [self.view sendSubviewToBack:viewController.view];
    
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

#pragma mark - Private — Notification to view mapping

- (UIView *)viewForUserNotification:(MUKUserNotification *)notification {
    if (!notification) {
        return nil;
    }
    
    return [self.notificationToViewMapping objectForKey:notification];
}

- (void)setView:(UIView *)view forUserNotification:(MUKUserNotification *)notification
{
    [self.notificationToViewMapping setObject:view forKey:notification];
}

@end
