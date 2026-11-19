#import "Sources/API/Internal.h"

%hook BaseMsgContentViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);
    WCGroupsHomeGroupsChatEntered(self);
}
%end

%hook MFBannerBtn
- (void)layoutSubviews {
    %orig;
    WCGroupsHomeGroupsLayoutChrome((UIView *)self);
}
%end

%hook MFWebMMBtn
- (void)updateWithOnlineStatus {
    %orig;
    WCGroupsHomeGroupsLayoutChrome((UIView *)self);
}
%end

%hook MMDarkModeConfigUtil
+ (void)updateCurrentIsDarkMode:(BOOL)dark {
    %orig(dark);
    WCGroupsHomeGroupsRefreshAppearance();
}
%end

%ctor {
    %init;
}
