#import <objc/message.h>
#import "Sources/API/Internal.h"

@interface WCGroupsHomeIntegration : NSObject <WCHomeGroupsIntegration>
@end
@implementation WCGroupsHomeIntegration
+ (BOOL)enabled { return WCGroupsHomeGroupsEnabled(); }
+ (void)refreshAppearance { WCGroupsHomeGroupsRefreshAppearance(); }
@end

BOOL WCGroupsHomePageCornerEnabled(void) {
    return [(Class<WCHomeCornersIntegration>)NSClassFromString(@"WCRoundHomeIntegration") enabled];
}
BOOL WCGroupsHomePageIsDark(UIView *view) {
    Class<WCHomeCornersIntegration> corners = NSClassFromString(@"WCRoundHomeIntegration");
    if (corners) return [corners isDark:view];
    Class mode = NSClassFromString(@"MMDarkModeConfigUtil");
    SEL selector = NSSelectorFromString(@"isDarkMode");
    return [mode respondsToSelector:selector] ? ((BOOL (*)(id, SEL))objc_msgSend)(mode, selector) : view.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
}
UIColor *WCGroupsHomePageCornerColor(UIView *view, BOOL surface) {
    return [(Class<WCHomeCornersIntegration>)NSClassFromString(@"WCRoundHomeIntegration") color:view surface:surface];
}
CGFloat WCGroupsHomePageCornerInset(void) { return [(Class<WCHomeCornersIntegration>)NSClassFromString(@"WCRoundHomeIntegration") inset]; }
CGFloat WCGroupsHomePageCornerGap(void) { return [(Class<WCHomeCornersIntegration>)NSClassFromString(@"WCRoundHomeIntegration") gap]; }
NSInteger WCGroupsHomePageCornerMergedSection(UITableView *table) {
    Class<WCHomeCornersIntegration> corners = NSClassFromString(@"WCRoundHomeIntegration");
    return corners ? [corners mergedSection:table] : NSNotFound;
}
void WCGroupsHomePageCornerLayoutGroup(UIView *banner, CGFloat nativeHeight, CGFloat height, BOOL joined) {
    [(Class<WCHomeCornersIntegration>)NSClassFromString(@"WCRoundHomeIntegration") layoutGroup:banner nativeHeight:nativeHeight height:height joined:joined];
}
void WCGroupsHomePageCornerAttach(UIViewController *controller) {
    [(Class<WCHomeCornersIntegration>)NSClassFromString(@"WCRoundHomeIntegration") attach:controller];
}

CGFloat WCGroupsHomePageScaleFactor(void) {
    Class<WCHomeCornersIntegration> corners = NSClassFromString(@"WCRoundHomeIntegration");
    return [corners respondsToSelector:@selector(layoutScaleFactor)] ? [corners layoutScaleFactor] : 1;
}
