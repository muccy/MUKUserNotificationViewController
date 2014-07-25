//
//  MUKUserNotificationViewController.m
//  MUKUserNotificationViewController
//
//  Created by Marco on 25/07/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "MUKUserNotificationViewController.h"

@interface MUKUserNotificationViewController ()
@property (nonatomic) BOOL viewWillAppearAlreadyCalled;
@end

@implementation MUKUserNotificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

#pragma mark - Accessors

- (void)setContentViewController:(UIViewController *)contentViewController {
    [self setContentViewController:contentViewController attemptingInsertion:YES];
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

- (void)insertContentViewController:(UIViewController *)viewController
{
    // Also calls -willMoveToParentViewController: automatically.
    // This method is only intended to be called by an implementation
    // of a custom container view controller (so parents add children)
    [self addChildViewController:viewController];
    
    viewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    viewController.view.frame = self.view.bounds;
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

@end
