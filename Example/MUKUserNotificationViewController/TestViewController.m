//
//  TestViewController.m
//  MUKUserNotificationViewController
//
//  Created by Marco on 25/07/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "TestViewController.h"
#import <MUKUserNotificationViewController/MUKUserNotificationViewController.h>

#define DEBUG_STATUS_BAR_HIDDEN         0
#define DEBUG_OVERLAPPING_PRESENTATION  0

@interface TestViewController ()

@end

@implementation TestViewController

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
#if DEBUG_OVERLAPPING_PRESENTATION
    [self parentUserNotificationViewController].notificationViewsPresentation = MUKUserNotificationViewPresentationBehindStatusBar;
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Overrides

#if DEBUG_STATUS_BAR_HIDDEN
- (BOOL)prefersStatusBarHidden {
    return YES;
}
#endif

#pragma mark - Actions

- (void)showExpiringNotificationButtonPressed:(id)sender {
    MUKUserNotification *notification = [self newNotification];
    notification.text = nil;
    notification.duration = 2.0;
    
    [[self parentUserNotificationViewController] showNotification:notification animated:YES completion:^(BOOL completed)
     {
         NSLog(@"Notification displayed (completed? %@)", completed ? @"Y" : @"N");
     }];
}

- (void)showStickyNotificationButtonPressed:(id)sender {
    MUKUserNotification *notification = [self newNotification];
    notification.duration = MUKUserNotificationDurationInfinite;
    
    [[self parentUserNotificationViewController] showNotification:notification animated:YES completion:^(BOOL completed)
     {
         NSLog(@"Notification displayed (completed? %@)", completed ? @"Y" : @"N");
     }];
}

- (IBAction)hideNotificationButtonPressed:(id)sender {
    MUKUserNotificationViewController *const userNotificationViewController = [self parentUserNotificationViewController];
    [userNotificationViewController hideNotification:userNotificationViewController.visibleNotification animated:YES completion:^(BOOL completed) {
        NSLog(@"Notification hidden (completed? %@)", completed ? @"Y" : @"N");
    }];
}

#pragma mark - Private

- (MUKUserNotificationViewController *)parentUserNotificationViewController {
    UIViewController *viewController = self;
    MUKUserNotificationViewController *foundViewController = nil;
    
    do {
        viewController = viewController.parentViewController;
        if ([viewController isKindOfClass:[MUKUserNotificationViewController class]])
        {
            foundViewController = (MUKUserNotificationViewController *)viewController;
        }
    } while (!foundViewController && viewController);
    
    return foundViewController;
}

- (MUKUserNotification *)newNotification {
    MUKUserNotification *notification = [[MUKUserNotification alloc] init];
    notification.title = @"Alert title. This is actually long as title, but it's needed because I need to test long lines wrapping. Bla bla bla bla bla bla.";
    notification.text = @"Alert message. I need to test long lines wrapping. Bla bla bla bla bla bla. Gne gne gne gne gne.";
    return notification;
}

@end
