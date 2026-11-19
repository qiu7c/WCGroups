#import "Sources/API/Internal.h"

NSString *const WCGroupsHomeGroupsUnifiedColorEnabledKey = @"com.qiu7c.wcgroups.home.groups.unified-color.enabled";
NSString *const WCGroupsHomeGroupsUnifiedColorKey = @"com.qiu7c.wcgroups.home.groups.unified-color.color";
NSString *const WCGroupsHomeGroupsEnabledKey = @"com.qiu7c.wcgroups.home.groups.enabled";
NSString *const WCGroupsHomeGroupsListKey = @"com.qiu7c.wcgroups.home.groups.list";
NSString *const WCGroupsHomeGroupsSelectedKey = @"com.qiu7c.wcgroups.home.groups.selected";
NSString *const WCGroupsHomeGroupsPendingKey = @"com.qiu7c.wcgroups.home.groups.pending-by-account";
NSString *const WCGroupsHomeGroupsBurnAfterReadingKey = @"com.qiu7c.wcgroups.home.groups.burn-after-reading";
NSString *const WCGroupsHomeGroupsPinnedPersistentKey = @"com.qiu7c.wcgroups.home.groups.pinned-persistent";
NSString *const WCGroupsHomeGroupsGestureKey = @"com.qiu7c.wcgroups.home.groups.gesture";
NSString *const WCGroupsHomeGroupsContinuousKey = @"com.qiu7c.wcgroups.home.groups.continuous";
NSString *const WCGroupsHomeGroupsReverseKey = @"com.qiu7c.wcgroups.home.groups.reverse";
NSString *const WCGroupsHomeGroupsButtonHapticKey = @"com.qiu7c.wcgroups.home.groups.button-haptic";
NSString *const WCGroupsHomeGroupsHapticKey = @"com.qiu7c.wcgroups.home.groups.haptic";
NSString *const WCGroupsHomeGroupsGestureRatioKey = @"com.qiu7c.wcgroups.home.groups.gesture-ratio";
NSString *const WCGroupsHomeGroupsSliderKey = @"com.qiu7c.wcgroups.home.groups.slider";
NSString *const WCGroupsHomeGroupsSliderSizeKey = @"com.qiu7c.wcgroups.home.groups.slider-size";
NSString *const WCGroupsHomeGroupsSliderRadiusKey = @"com.qiu7c.wcgroups.home.groups.slider-radius";
NSString *const WCGroupsHomeGroupsSliderAnimationKey = @"com.qiu7c.wcgroups.home.groups.slider-animation";
NSString *const WCGroupsHomeGroupsSliderColorKey = @"com.qiu7c.wcgroups.home.groups.slider-color";
NSString *const WCGroupsHomeGroupsUnderlineKey = @"com.qiu7c.wcgroups.home.groups.underline";
NSString *const WCGroupsHomeGroupsUnderlineLengthKey = @"com.qiu7c.wcgroups.home.groups.underline-length";
NSString *const WCGroupsHomeGroupsUnderlineThicknessKey = @"com.qiu7c.wcgroups.home.groups.underline-thickness";
NSString *const WCGroupsHomeGroupsUnderlineOffsetKey = @"com.qiu7c.wcgroups.home.groups.underline-offset";
NSString *const WCGroupsHomeGroupsUnderlineColorKey = @"com.qiu7c.wcgroups.home.groups.underline-color";
NSString *const WCGroupsHomeGroupsFontSizeKey = @"com.qiu7c.wcgroups.home.groups.font-size";
NSString *const WCGroupsHomeGroupsFontWeightKey = @"com.qiu7c.wcgroups.home.groups.font-weight";
NSString *const WCGroupsHomeGroupsHideBadgesKey = @"com.qiu7c.wcgroups.home.groups.hide-badges";
NSString *const WCGroupsHomeGroupsHideRedDotsKey = @"com.qiu7c.wcgroups.home.groups.hide-red-dots";
NSString *const WCGroupsHomeGroupsNativeBadgeKey = @"com.qiu7c.wcgroups.home.groups.native-badge";
NSString *const WCGroupsHomeGroupsBadgeXKey = @"com.qiu7c.wcgroups.home.groups.badge-x";
NSString *const WCGroupsHomeGroupsBadgeYKey = @"com.qiu7c.wcgroups.home.groups.badge-y";
NSString *const WCGroupsHomeGroupsBadgeColorKey = @"com.qiu7c.wcgroups.home.groups.badge-color";
NSString *const WCGroupsHomeGroupsBadgeTextColorKey = @"com.qiu7c.wcgroups.home.groups.badge-text-color";
NSString *const WCGroupsEnabledKey = @"com.qiu7c.wcgroups.enabled";

NSDictionary *WCGroupsDefaultSettings(void) {
    return @{
        WCGroupsHomeGroupsUnifiedColorEnabledKey: @NO,
        WCGroupsHomeGroupsUnifiedColorKey: @"#FFFFFF",
        WCGroupsHomeGroupsEnabledKey: @NO,
        WCGroupsHomeGroupsListKey: @[@{@"id":@"builtin.friend",@"type":@"friend",@"title":@"好友"},@{@"id":@"builtin.group",@"type":@"group",@"title":@"群聊"},@{@"id":@"builtin.other",@"type":@"other",@"title":@"其他"},@{@"id":@"builtin.instant",@"type":@"instant",@"title":@"即时消息"}],
        WCGroupsHomeGroupsSelectedKey: @"builtin.friend",
        WCGroupsHomeGroupsPendingKey: @{},
        WCGroupsHomeGroupsBurnAfterReadingKey: @NO,
        WCGroupsHomeGroupsPinnedPersistentKey: @NO,
        WCGroupsHomeGroupsGestureKey: @YES,
        WCGroupsHomeGroupsContinuousKey: @NO,
        WCGroupsHomeGroupsReverseKey: @NO,
        WCGroupsHomeGroupsButtonHapticKey: @NO,
        WCGroupsHomeGroupsHapticKey: @YES,
        WCGroupsHomeGroupsGestureRatioKey: @0.125,
        WCGroupsHomeGroupsSliderKey: @YES,
        WCGroupsHomeGroupsSliderSizeKey: @100,
        WCGroupsHomeGroupsSliderRadiusKey: @7,
        WCGroupsHomeGroupsSliderAnimationKey: @YES,
        WCGroupsHomeGroupsSliderColorKey: @"",
        WCGroupsHomeGroupsUnderlineKey: @NO,
        WCGroupsHomeGroupsUnderlineLengthKey: @30,
        WCGroupsHomeGroupsUnderlineThicknessKey: @1.5,
        WCGroupsHomeGroupsUnderlineOffsetKey: @5,
        WCGroupsHomeGroupsUnderlineColorKey: @"",
        WCGroupsHomeGroupsFontSizeKey: @14,
        WCGroupsHomeGroupsFontWeightKey: @400,
        WCGroupsHomeGroupsHideBadgesKey: @NO,
        WCGroupsHomeGroupsHideRedDotsKey: @NO,
        WCGroupsHomeGroupsNativeBadgeKey: @NO,
        WCGroupsHomeGroupsBadgeXKey: @0,
        WCGroupsHomeGroupsBadgeYKey: @0,
        WCGroupsHomeGroupsBadgeColorKey: @"",
        WCGroupsHomeGroupsBadgeTextColorKey: @"",
        WCGroupsEnabledKey: @YES,
    };
}

void WCGroupsRegisterDefaults(void) {
    [NSUserDefaults.standardUserDefaults registerDefaults:WCGroupsDefaultSettings()];
}

BOOL WCGroupsEnabled(NSString *key) {
    return [NSUserDefaults.standardUserDefaults boolForKey:WCGroupsEnabledKey] && [NSUserDefaults.standardUserDefaults boolForKey:key];
}
