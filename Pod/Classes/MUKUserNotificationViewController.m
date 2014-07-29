//
//  MUKUserNotificationViewController.m
//  MUKUserNotificationViewController
//
//  Created by Marco on 25/07/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "MUKUserNotificationViewController.h"

NSTimeInterval const MUKUserNotificationViewControllerDefaultMinimumIntervalBetweenNotifications = 1.0f;

static NSTimeInterval const kNotificationViewAnimationDuration = 0.45;
static CGFloat const kNotificationViewAnimationSpringDamping = 1.0f;
static CGFloat const kNotificationViewAnimationSpringVelocity = 1.0f;
static CGFloat const kDefaultStatusBarHeight = 20.0f;
static CGFloat const kNavigationBarSnapDifference = 14.0f;

@interface MUKUserNotificationViewController ()
@property (nonatomic, readwrite) NSMutableArray *notificationQueue;

@property (nonatomic) BOOL viewWillAppearAlreadyCalled, hasGapAboveContentViewController, needsNavigationBarAdjustmentInLandscape;
@property (nonatomic) CGFloat statusBarHeight;
@property (nonatomic) NSMapTable *notificationToViewMapping, *viewToNotificationMapping;
@property (nonatomic) CGRect lastLayoutBounds;
@property (nonatomic) NSDate *lastNotificationPresentationDate;
@end

@implementation MUKUserNotificationViewController
@dynamic notifications;
@dynamic visibleNotification;

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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Ensure gap above content view controller is displayed in portrait.
    // This is needed because if a notification is displayed in landscape, inset
    // is not set (due UIKit implementation of UINavigationBar). So, when you
    // rotate phone to portrait, notification view overlaps navigation bar.
    if (self.hasGapAboveContentViewController && UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
    {
        self.contentViewController.view.frame = [self contentViewControllerFrameWithInsets:UIEdgeInsetsMake(self.statusBarHeight, 0.0f, 0.0f, 0.0f)];
    }
    
    // Find variation of size (e.g. autorotation)
    BOOL layoutBoundsSizeChanged = NO;
    if (CGRectIsNull(self.lastLayoutBounds)) {
        self.lastLayoutBounds = self.view.bounds;
        layoutBoundsSizeChanged = YES;
    }
    else if (!CGSizeEqualToSize(self.lastLayoutBounds.size, self.view.bounds.size))
    {
        self.lastLayoutBounds = self.view.bounds;
        layoutBoundsSizeChanged = YES;
    }
    
    // If layout size changes I have to resize notification views
    if (layoutBoundsSizeChanged) {
        CGSize const minumumSize = [self minimumUserNotificationViewSize];
        for (MUKUserNotification *notification in self.notifications) {
            MUKUserNotificationView *notificationView = [self viewForNotification:notification];
            notificationView.frame = [self frameForView:notificationView notification:notification minimumSize:minumumSize];
        } // for
    }
}

#pragma mark - Overrides

- (BOOL)prefersStatusBarHidden {
    return [self couldHideStatusBar] && [self.notifications count] > 0;
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

- (NSArray *)notifications {
    return [self.notificationQueue copy];
}

- (MUKUserNotification *)visibleNotification {
    for (MUKUserNotification *notification in [self.notifications reverseObjectEnumerator])
    {
        // if it has not an associated view, it means notification view has not
        // been presented yet (probabily because of rate limit)
        if ([self viewForNotification:notification]) {
            return notification;
        }
    }

    return nil;
}

#pragma mark - Methods

- (void)showNotification:(MUKUserNotification *)notification animated:(BOOL)animated completion:(void (^)(BOOL))completionHandler
{
    [self showNotification:notification addToQueue:YES passingTest:nil animated:animated completion:completionHandler];
}

- (void)hideNotification:(MUKUserNotification *)notification animated:(BOOL)animated completion:(void (^)(BOOL))completionHandler
{
    if (!notification) {
        return;
    }
    
    // Get view for notification
    UIView *const notificationView = [self viewForNotification:notification];
    
    // Remove from queue
    [self removeNotification:notification];
    
    if (!notificationView) {
        return;
    }
    
    // Don't touch content view controller if there are pending notifications
    NSUInteger const pendingNotificationCount = [self.notifications count];
    BOOL const shouldResizeContentViewController = pendingNotificationCount == 0;
    
    // No more need to preserve gap if there aren't pending notifications
    if (pendingNotificationCount == 0) {
        self.hasGapAboveContentViewController = NO;
    }
    
    // Attempt navigation bar adjustment only in landscape and when last notification
    // is about to be hidden
    BOOL const shouldAttemptNavigationBarAdjustment = self.needsNavigationBarAdjustmentInLandscape && pendingNotificationCount == 0 && UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
    
    // Animate out
    NSTimeInterval const duration = animated ? kNotificationViewAnimationDuration : 0.0;
    
    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:kNotificationViewAnimationSpringDamping initialSpringVelocity:kNotificationViewAnimationSpringVelocity options:0 animations:^{
        // Move out
        notificationView.transform = CGAffineTransformMakeTranslation(0.0f, -CGRectGetHeight(notificationView.frame));
        
        // Resize content view controller if needed
        if (shouldResizeContentViewController) {
            self.contentViewController.view.frame = [self contentViewControllerFrameWithInsets:UIEdgeInsetsZero];
        }
        
        // Show status bar (order matters!)
        [self setNeedsStatusBarAppearanceUpdate];
        
        // Adjust navigation bar if possible and needed
        if (shouldAttemptNavigationBarAdjustment) {
            [self adjustNavigationBarOfAffectedNavigationControllers];
        }
    } completion:^(BOOL finished) {
        // No more need to preserve navigation bar if there aren't pending
        // notifications
        if (pendingNotificationCount == 0) {
            self.needsNavigationBarAdjustmentInLandscape = NO;
        }
        
        // Remove view from view hierarchy
        [notificationView removeFromSuperview];
        
        // Notify completion if needed
        if (completionHandler) {
            completionHandler(finished);
        }
    }];
}

#pragma mark - Expiration

- (void)notificationWillExpire:(MUKUserNotification *)notification {
    //
}

- (void)notificationDidExpire:(MUKUserNotification *)notification {
    //
}

#pragma mark - Notification View

- (MUKUserNotificationView *)viewForNotification:(MUKUserNotification *)notification {
    if (!notification) {
        return nil;
    }
    
    return [self.notificationToViewMapping objectForKey:notification];
}

- (MUKUserNotification *)notificationForView:(MUKUserNotificationView *)view
{
    if (!view) {
        return nil;
    }
    
    return [self.viewToNotificationMapping objectForKey:view];
}

- (MUKUserNotificationView *)newViewForNotification:(MUKUserNotification *)notification
{
    MUKUserNotificationView *view = [[MUKUserNotificationView alloc] initWithFrame:CGRectZero];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    return view;
}

- (void)configureView:(MUKUserNotificationView *)view forNotification:(MUKUserNotification *)notification
{
    view.titleLabel.text = notification.title;
    view.textLabel.text = notification.text;
    
    view.titleLabel.textColor = notification.textColor ?: [UIColor whiteColor];
    view.textLabel.textColor = notification.textColor ?: [UIColor whiteColor];
    view.backgroundColor = notification.color ?: self.view.tintColor;
    
    // Set gesture recognizer actions
    [view.tapGestureRecognizer addTarget:self action:@selector(handleNotificationViewTapGestureRecognizer:)];
    [view.panGestureRecognizer addTarget:self action:@selector(handleNotificationViewPanGestureRecognizer:)];
}

- (CGRect)frameForView:(MUKUserNotificationView *)view notification:(MUKUserNotification *)notification minimumSize:(CGSize)minimumSize
{
    CGFloat const maxHeight = roundf(CGRectGetHeight(self.view.frame) * 0.35f);
    CGSize expandedSize = [view sizeThatFits:CGSizeMake(minimumSize.width, maxHeight)];
    CGRect frame = CGRectMake(0.0f, 0.0f, minimumSize.width, fmaxf(minimumSize.height, expandedSize.height));
    
    if (self.notificationViewsSnapToNavigationBar) {
        CGFloat const affectedNavigationBarsMaxY = [self affectedNavigationBarsMaxY];
        CGFloat const diff = CGRectGetMaxY(frame) - affectedNavigationBarsMaxY;
        
        if (diff < 0.0f && fabsf(diff) < kNavigationBarSnapDifference) {
            frame.size.height -= diff;
        }
    }
    
    return frame;
}

- (void)didTapView:(MUKUserNotificationView *)view forNotification:(MUKUserNotification *)notification
{
    if (notification.tapGestureHandler) {
        notification.tapGestureHandler(self, view);
    }
    else {
        [self hideNotification:notification animated:YES completion:nil];
    }
}

- (void)didPanUpView:(MUKUserNotificationView *)view forNotification:(MUKUserNotification *)notification
{
    [self hideNotification:notification animated:YES completion:nil];
}

#pragma mark - Navigation Controllers

- (NSArray *)affectedNavigationControllers {
    NSMutableArray *navigationControllers = [[NSMutableArray alloc] init];
    
    if ([self.contentViewController isKindOfClass:[UINavigationController class]])
    {
        [navigationControllers addObject:self.contentViewController];
    }
    else if ([self.contentViewController isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tabBarController = (UITabBarController *)self.contentViewController;
        
        if ([tabBarController.selectedViewController isKindOfClass:[UINavigationController class]])
        {
            [navigationControllers addObject:tabBarController.selectedViewController];
        }
    }
    
    if (self.splitViewController) {
        for (UIViewController *viewController in self.splitViewController.viewControllers)
        {
            if ([viewController isKindOfClass:[UINavigationController class]])
            {
                [navigationControllers addObject:viewController];
            }
        } // for
    }
    
    return [navigationControllers copy];
}

#pragma mark - Private 

static void CommonInit(MUKUserNotificationViewController *me) {
    me->_statusBarHeight = kDefaultStatusBarHeight;
    me->_notificationToViewMapping = [NSMapTable weakToWeakObjectsMapTable];
    me->_viewToNotificationMapping = [NSMapTable weakToWeakObjectsMapTable];
    me->_notificationQueue = [[NSMutableArray alloc] init];
    me->_lastLayoutBounds = CGRectNull;
    me->_minimumIntervalBetweenNotifications = MUKUserNotificationViewControllerDefaultMinimumIntervalBetweenNotifications;
    me->_notificationViewsPresentation = MUKUserNotificationViewPresentationReplaceStatusBar;
    me->_notificationViewsSnapToNavigationBar = YES;
}

- (BOOL)couldHideStatusBar {
    return self.notificationViewsPresentation == MUKUserNotificationViewPresentationReplaceStatusBar;
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

+ (CGFloat)actualStatusBarHeight {
    CGRect const statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    return fminf(CGRectGetWidth(statusBarFrame), CGRectGetHeight(statusBarFrame));
}

- (void)captureStatusBarHeightIfAvailable {
    if (![[UIApplication sharedApplication] isStatusBarHidden]) {
        CGFloat const statusBarHeight = [[self class] actualStatusBarHeight];
        
        if (statusBarHeight > 0.0f) {
            self.statusBarHeight = statusBarHeight;
        }
    }
}

- (CGSize)minimumUserNotificationViewSize {
    return CGSizeMake(CGRectGetWidth(self.view.bounds), self.statusBarHeight);
}

- (void)adjustNotificationViewPaddingIfNeeded:(MUKUserNotificationView *)notificationView
{
    if (![self couldHideStatusBar]) {
        UIEdgeInsets padding = notificationView.padding;
        padding.top += self.statusBarHeight;
        notificationView.padding = padding;
    }
}

- (void)handleNotificationViewTapGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        MUKUserNotificationView *view = (MUKUserNotificationView *)recognizer.view;
        MUKUserNotification *notification = [self notificationForView:view];
        
        if (view && notification) {
            [self didTapView:view forNotification:notification];
        }
    }
}

- (void)handleNotificationViewPanGestureRecognizer:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint const translation = [recognizer translationInView:recognizer.view];
        if (translation.y < 0.0f && fabsf(translation.y) > 0.3f * CGRectGetHeight(recognizer.view.frame))
        {
            MUKUserNotificationView *view = (MUKUserNotificationView *)recognizer.view;
            MUKUserNotification *notification = [self notificationForView:view];
            
            if (view && notification) {
                [self didPanUpView:view forNotification:notification];
            }
        }
    }
}

- (void)showNotification:(MUKUserNotification *)notification addToQueue:(BOOL)addToQueue passingTest:(BOOL (^)(void))testBlock animated:(BOOL)animated completion:(void (^)(BOOL))completionHandler
{
    if (!notification) {
        return;
    }
    
    // Add to notification queue if needed
    if (addToQueue) {
        [self addNotification:notification];
    }
    
    // Pass test before to proceed
    BOOL const testPassed = testBlock ? testBlock() : YES;
    if (!testPassed) {
        return;
    }
    
    // Check against rate limit
    if (![self hasPassedMinimumIntervalFromLastNotification]) {
        NSTimeInterval remainingInterval = [self missingTimeIntervalToNextPresentableNotification];
        
        // Retry later
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(remainingInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
        {
            // Deferred recursion
            // Note addToQueue:NO, because I don't want to add model twice
            // What is more I have to check if notification object is still
            // inside queue (e.g. -hideNotification:... called during rate
            // limit interval
            [self showNotification:notification addToQueue:NO passingTest:^
            {
                return [self.notifications containsObject:notification];
            } animated:animated completion:completionHandler];
        });
        
        // Exit point
        return;
    }
    
    // Rate limit test is passed
    // Presentation will take place now
    self.lastNotificationPresentationDate = [NSDate date];
    
    // Get real status bar height if available
    [self captureStatusBarHeightIfAvailable];
    
    // Don't touch content view controller if status bar is hidden and we are
    // not in landscape (because UIKit implementation of UINavigationController)
    BOOL const portraitStatusBar = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    BOOL const statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    BOOL const shouldResizeContentViewController = !statusBarHidden && portraitStatusBar && [self couldHideStatusBar];
    
    // Mark if there is a gap above content view controller, preserving
    // previous positive state
    if (!self.hasGapAboveContentViewController) {
        self.hasGapAboveContentViewController = !statusBarHidden && [self couldHideStatusBar];
    }
    
    // Mark if navigation bar in landscape will be messed up, preserving
    // previous positive state
    if (!self.needsNavigationBarAdjustmentInLandscape) {
        self.needsNavigationBarAdjustmentInLandscape = portraitStatusBar && !statusBarHidden && [self couldHideStatusBar];
    }
    
    // Create notification view
    MUKUserNotificationView *notificationView = [self newViewForNotification:notification];
    [self configureView:notificationView forNotification:notification];
    
    // If status bar is not replaced, contents should not overlap with it
    [self adjustNotificationViewPaddingIfNeeded:notificationView];
    
    // Adjust frame
    notificationView.frame = [self frameForView:notificationView notification:notification minimumSize:[self minimumUserNotificationViewSize]];
    
    // Map view to notification (and viceversa)
    [self setView:notificationView forUserNotification:notification];
    [self setUserNotification:notification forView:notificationView];
    
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
        
        // Resize content view controller if needed
        if (shouldResizeContentViewController) {
            self.contentViewController.view.frame = [self contentViewControllerFrameWithInsets:UIEdgeInsetsMake(self.statusBarHeight, 0.0f, 0.0f, 0.0f)];
        }
        
        // Move notification view in
        notificationView.transform = targetTransform;
    } completion:^(BOOL finished) {
        // Set expiration if needed
        if ([self notificationCanExpire:notification]) {
            [self scheduleExpirationForNotification:notification];
        }
        
        // Invoke completion handler if any
        if (completionHandler) {
            completionHandler(finished);
        }
    }];
}

#pragma mark - Private — Notification <-> view mapping

- (void)setView:(MUKUserNotificationView *)view forUserNotification:(MUKUserNotification *)notification
{
    if (view && notification) {
        [self.notificationToViewMapping setObject:view forKey:notification];
    }
}

- (void)setUserNotification:(MUKUserNotification *)notification forView:(MUKUserNotificationView *)view
{
    if (view && notification) {
        [self.viewToNotificationMapping setObject:notification forKey:view];
    }
}

#pragma mark - Private – Notifications

- (void)addNotification:(MUKUserNotification *)notification {
    if (notification) {
        [self.notificationQueue addObject:notification];
    }
}

- (void)removeNotification:(MUKUserNotification *)notification {
    if (notification) {
        [self.notificationQueue removeObject:notification];
    }
}

#pragma mark - Private — Notification Expiration

- (BOOL)notificationCanExpire:(MUKUserNotification *)notification {
    return notification.duration > 0.0f;
}

- (void)scheduleExpirationForNotification:(MUKUserNotification *)notification
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(notification.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // If notification is still there proceed with expiration
        if ([self.notifications containsObject:notification]) {
            [self notificationWillExpire:notification];
            [self hideNotification:notification animated:YES completion:^(BOOL completed)
            {
                [self notificationDidExpire:notification];
            }];
        }
    });
}

#pragma mark - Private — Navigation Controllers

- (void)adjustNavigationBarOfAffectedNavigationControllers {
    for (UINavigationController *navController in [self affectedNavigationControllers])
    {
        [navController setNavigationBarHidden:YES animated:NO];
        [navController setNavigationBarHidden:NO animated:NO];
    } // for
}

- (CGFloat)affectedNavigationBarsMaxY {
    CGFloat foundMaxY = -1.0f;
    
    for (UINavigationController *navigationController in [self affectedNavigationControllers])
    {
        CGRect const convertedNavigationBarFrame = [navigationController.navigationBar.superview convertRect:navigationController.navigationBar.frame toView:self.view];
        CGFloat const maxY = CGRectGetMaxY(convertedNavigationBarFrame);
        
        if (maxY > 0.0f) {
            foundMaxY = fmaxf(foundMaxY, maxY);
        }
    } // for
    
    return foundMaxY;
}

#pragma mark - Private - Notification Rate Limit

- (BOOL)hasPassedMinimumIntervalFromLastNotification {
    if (!self.lastNotificationPresentationDate) {
        return YES;
    }
    
    return [self missingTimeIntervalToNextPresentableNotification] > 0.0;
}

- (NSTimeInterval)missingTimeIntervalToNextPresentableNotification {
    NSTimeInterval interval = -[self.lastNotificationPresentationDate timeIntervalSinceNow];
    return interval - self.minimumIntervalBetweenNotifications;
}

@end
