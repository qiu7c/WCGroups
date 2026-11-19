#import "Sources/API/Internal.h"

NSNotificationName const WCGroupsDidChangeNotification = @"com.qiu7c.wcgroups.changed";

%ctor {
    @autoreleasepool {
        WCGroupsRegisterDefaults();
        %init;
        dispatch_async(dispatch_get_main_queue(), ^{ WCGroupsRegisterEntry(); });
        [NSNotificationCenter.defaultCenter addObserverForName:WCGroupsDidChangeNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note) {
            WCGroupsHomeGroupsSettingsChanged(note.object);
        }];
    }
}
