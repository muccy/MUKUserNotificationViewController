//
//  TestViewController.m
//  MUKUserNotificationViewController
//
//  Created by Marco on 25/07/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "TestViewController.h"
#import <MUKUserNotificationViewController/MUKUserNotificationViewController.h>

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

#pragma mark - Actions

- (void)showNotificationButtonPressed:(id)sender {
    MUKUserNotification *notification = [[MUKUserNotification alloc] init];
    notification.text = @"Alert Message";
    
    [[self parentUserNotificationViewController] showNotification:notification animated:YES completion:^(BOOL completed)
    {
        NSLog(@"Notification displayed (completed? %@)", completed ? @"Y" : @"N");
    }];
}

- (IBAction)hideNotificationButtonPressed:(id)sender {
    [[self parentUserNotificationViewController] hideNotificationAnimated:YES completion:^(BOOL completed) {
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

@end
