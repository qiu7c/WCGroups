#import <objc/message.h>
#import "Sources/API/Internal.h"

static BOOL WCGroupsEntryRegistered;
static char WCGroupsEntryCellKey;

UIViewController *WCGroupsCreateSettingsController(void) {
    UIViewController *controller = WCGroupsCreateHomeGroupsSettingsController();
    controller.hidesBottomBarWhenPushed = YES;
    return controller;
}

void WCGroupsRegisterEntry(void) {
    if (WCGroupsEntryRegistered) return;
    Class managerClass = NSClassFromString(@"WCPluginsMgr");
    SEL shared = NSSelectorFromString(@"sharedInstance");
    if (![managerClass respondsToSelector:shared]) return;
    id manager = ((id (*)(id, SEL))objc_msgSend)(managerClass, shared);
    SEL registerSelector = NSSelectorFromString(@"registerControllerWithTitle:version:controller:");
    if (![manager respondsToSelector:registerSelector]) return;
    ((void (*)(id, SEL, id, id, id))objc_msgSend)(manager, registerSelector, @"微信分组", @"1.0.0", @"WCGroupsLocalHomeGroupsSettings");
    WCGroupsEntryRegistered = YES;
}

void WCGroupsRefreshEntry(UIViewController *controller) {
    WCGroupsRegisterEntry();
    id manager = WCGroupsTweakSafeValue(controller, @"m_tableViewMgr");
    NSArray *sections = WCGroupsTweakSafeValue(manager, @"getAllSections");
    if (![sections isKindOfClass:NSArray.class] || !sections.count) return;
    id ownSection = nil;
    NSUInteger ownIndex = NSNotFound;
    for (id section in sections) {
        NSArray *cells = WCGroupsTweakSafeValue(section, @"getAllCells");
        if (![cells isKindOfClass:NSArray.class]) continue;
        for (NSUInteger index = 0; index < cells.count; index++) {
            if (!objc_getAssociatedObject(cells[index], &WCGroupsEntryCellKey)) continue;
            ownSection = section; ownIndex = index;
            break;
        }
        if (ownSection) break;
    }
    if (WCGroupsEntryRegistered && ownSection) {
        ((void (*)(id, SEL, unsigned long long))objc_msgSend)(ownSection, NSSelectorFromString(@"removeCellAt:"), ownIndex);
    } else if (!WCGroupsEntryRegistered && !ownSection) {
        Class factoryClass = NSClassFromString(@"WCTableViewCellManager");
        SEL factory = NSSelectorFromString(@"normalCellForSel:target:leftImage:title:WithDisclosureIndicator:");
        if (![factoryClass respondsToSelector:factory]) return;
        UIImage *icon = [[UIImage systemImageNamed:@"rectangle.3.group"] imageWithTintColor:UIColor.systemBlueColor renderingMode:UIImageRenderingModeAlwaysOriginal];
        id cell = ((id (*)(id, SEL, SEL, id, id, id, BOOL))objc_msgSend)(factoryClass, factory, NSSelectorFromString(@"wcg_openSettings"), controller, icon, @"微信分组", YES);
        if (!cell) return;
        objc_setAssociatedObject(cell, &WCGroupsEntryCellKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        ((void (*)(id, SEL, id))objc_msgSend)(sections[MIN(2, sections.count - 1)], NSSelectorFromString(@"addCell:"), cell);
    } else return;
    ((void (*)(id, SEL))objc_msgSend)(manager, NSSelectorFromString(@"reloadTableView"));
}
