#import "MUKUserNotification.h"

NSTimeInterval const MUKUserNotificationDurationInfinite = -1.0;

@implementation MUKUserNotification

- (id)init {
    self = [super init];
    if (self) {
        _duration = MUKUserNotificationDurationInfinite;
    }
    
    return self;
}

@end
