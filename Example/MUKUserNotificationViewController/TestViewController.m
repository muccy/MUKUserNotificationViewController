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

@interface Command : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) dispatch_block_t action;
@end

@implementation Command
@end

@interface TestViewController ()
@property (nonatomic) NSArray *commands;
@end

@implementation TestViewController

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
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
#if DEBUG_OVERLAPPING_PRESENTATION
    [self parentUserNotificationViewController].notificationViewsPresentation = MUKUserNotificationViewPresentationBehindStatusBar;
#endif
}

#pragma mark - Overrides

#if DEBUG_STATUS_BAR_HIDDEN
- (BOOL)prefersStatusBarHidden {
    return YES;
}
#endif

#pragma mark - Private

static void CommonInit(TestViewController *me) {
    me.title = @"Example";
    me->_commands = [me newCommands];
}

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

#pragma mark - Private - Commands

- (NSArray *)newCommands {
    NSMutableArray *commands = [[NSMutableArray alloc] init];
    __weak TestViewController *weakSelf = self;
    
    Command *command = [[Command alloc] init];
    command.title = @"Hide Displayed Notification";
    command.action = ^{
        MUKUserNotificationViewController *const userNotificationViewController = [weakSelf parentUserNotificationViewController];
        [userNotificationViewController hideNotification:userNotificationViewController.visibleNotification animated:YES completion:nil];
    };
    [commands addObject:command];
    
    command = [[Command alloc] init];
    command.title = @"Show Sticky Notification";
    command.action = ^{
        MUKUserNotification *notification = [[MUKUserNotification alloc] init];
        notification.title = @"Sticky Notification";
        notification.tapGestureHandler = ^(MUKUserNotificationViewController *vc, MUKUserNotificationView *v) {};
        notification.panUpGestureHandler = ^(MUKUserNotificationViewController *vc, MUKUserNotificationView *v) {};
        notification.color = [UIColor colorWithRed:0.0f green:0.85f blue:0.0f alpha:1.0f];
        
        [[weakSelf parentUserNotificationViewController] showNotification:notification animated:YES completion:nil];
    };
    [commands addObject:command];
    
    command = [[Command alloc] init];
    command.title = @"Show Alert Notification";
    command.action = ^{
        MUKUserNotification *notification = [[MUKUserNotification alloc] init];
        notification.title = @"Alert Notification";
        notification.text = @"More text to explain alert";
        notification.duration = 1.5;
        notification.color = [UIColor redColor];
        
        [[weakSelf parentUserNotificationViewController] showNotification:notification animated:YES completion:nil];
    };
    [commands addObject:command];
    
    return [commands copy];
}

- (Command *)commandAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath || indexPath.row < 0 || indexPath.row >= [self.commands count])
    {
        return nil;
    }
    
    return self.commands[indexPath.row];
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Command *command = [self commandAtIndexPath:indexPath];
    if (command.action) {
        command.action();
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.commands count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Command *command = [self commandAtIndexPath:indexPath];
    cell.textLabel.text = command.title;
    
    return cell;
}

@end
