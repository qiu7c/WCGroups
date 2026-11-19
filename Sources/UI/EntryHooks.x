#import "Sources/API/Internal.h"

%hook MoreViewController
- (void)addFunctionSection {
    %orig;
    WCGroupsRefreshEntry((UIViewController *)self);
}
- (void)viewWillAppear:(BOOL)animated {
    %orig(animated);
    WCGroupsRefreshEntry((UIViewController *)self);
}
%new
- (void)wcg_openSettings {
    [((UIViewController *)self).navigationController pushViewController:WCGroupsCreateSettingsController() animated:YES];
}
%end

%ctor {
    %init;
}
