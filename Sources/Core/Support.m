#import <objc/message.h>
#import "Sources/API/Internal.h"

id WCGroupsTweakSafeValue(id object, NSString *key) {
    if (!object) return nil;
    @try { return [object valueForKey:key]; }
    @catch (__unused NSException *exception) { return nil; }
}

id WCGroupsServiceForClass(Class cls) {
    Class contextClass = NSClassFromString(@"MMContext");
    SEL current = NSSelectorFromString(@"currentContext");
    if (![contextClass respondsToSelector:current]) return nil;
    id context = ((id (*)(id, SEL))objc_msgSend)(contextClass, current);
    SEL service = NSSelectorFromString(@"getService:");
    if ([context respondsToSelector:service]) return ((id (*)(id, SEL, Class))objc_msgSend)(context, service, cls);
    id center = WCGroupsTweakSafeValue(context, @"serviceCenter");
    return [center respondsToSelector:service] ? ((id (*)(id, SEL, Class))objc_msgSend)(center, service, cls) : nil;
}

id WCGroupsPrivateContact(NSString *user) {
    id manager = WCGroupsServiceForClass(NSClassFromString(@"CContactMgr"));
    SEL selector = NSSelectorFromString(@"getContactByName:");
    return user.length && [manager respondsToSelector:selector] ? ((id (*)(id, SEL, id))objc_msgSend)(manager, selector, user) : nil;
}

NSString *WCGroupsPrivateContactUserName(id contact) {
    id value = WCGroupsTweakSafeValue(contact, @"m_nsUsrName");
    return [value isKindOfClass:NSString.class] ? value : @"";
}

NSString *WCGroupsCurrentUserWXID(void) {
    Class contextClass = NSClassFromString(@"MMContext");
    SEL selector = NSSelectorFromString(@"currentUserName");
    id value = [contextClass respondsToSelector:selector] ? ((id (*)(id, SEL))objc_msgSend)(contextClass, selector) : nil;
    return [value isKindOfClass:NSString.class] ? value : @"";
}


void WCGroupsShowToast(NSString *text) { [WCGroupsLocalPopup showMessage:text message:nil]; }

NSArray *WCGroupsPrivateContactList(void) {
    id manager = WCGroupsServiceForClass(NSClassFromString(@"CContactMgr"));
    SEL selector = NSSelectorFromString(@"getContactList:contactType:");
    NSMethodSignature *signature = [manager methodSignatureForSelector:selector];
    if (![manager respondsToSelector:selector] || signature.numberOfArguments != 4
        || signature.methodReturnType[0] != '@'
        || strcmp([signature getArgumentTypeAtIndex:2], @encode(unsigned int)) != 0
        || strcmp([signature getArgumentTypeAtIndex:3], @encode(unsigned int)) != 0) return @[];
    @try {
        id value = ((id (*)(id, SEL, unsigned int, unsigned int))objc_msgSend)(manager, selector, 1, 0);
        if (![value conformsToProtocol:@protocol(NSFastEnumeration)] || [value isKindOfClass:NSString.class]) return @[];
        NSMutableArray *contacts = [NSMutableArray array];
        for (id contact in value) if (contact) [contacts addObject:contact];
        return contacts;
    } @catch (__unused NSException *exception) { return @[]; }
}

static NSString *WCContactsName(id contact, NSArray<NSString *> *keys) {
    for (NSString *key in keys) {
        id value = WCGroupsTweakSafeValue(contact, key);
        if (![value isKindOfClass:NSString.class]) continue;
        NSString *name = [value stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        if (name.length) return name;
    }
    return nil;
}

NSString *WCGroupsPrivateContactDisplayName(id contact, NSString *fallback) {
    return WCContactsName(contact, @[@"m_nsRemark", @"getRemark", @"remark", @"remarkName",
        @"getContactDisplayName", @"getDisplayName", @"m_nsNickName", @"getNickName", @"nickName", @"nickname"])
        ?: (fallback ?: @"");
}

NSString *WCGroupsPrivateNotificationDisplayName(NSString *username, NSString *fallback) {
    id contact = username.length ? WCGroupsPrivateContact(username) : nil;
    NSArray *remarkKeys = @[@"m_nsRemark", @"getRemark", @"remark", @"remarkName"];
    NSString *remark = WCContactsName(contact, remarkKeys);
    if (remark.length) return remark;
    id listContact = nil;
    if (username.length) for (id candidate in WCGroupsPrivateContactList()) {
        if ([candidate isKindOfClass:NSString.class]) continue;
        NSString *alias = WCContactsName(candidate, @[@"m_nsAliasName", @"m_nsAlias", @"getAlias", @"alias", @"aliasName"]);
        if ([WCGroupsPrivateContactUserName(candidate) isEqualToString:username] || [alias isEqualToString:username]) {
            listContact = candidate;
            break;
        }
    }
    remark = WCContactsName(listContact, remarkKeys);
    if (remark.length) return remark;
    NSString *name = WCGroupsPrivateContactDisplayName(contact, nil);
    if (!name.length) name = WCGroupsPrivateContactDisplayName(listContact, nil);
    return name.length ? name : (fallback.length ? fallback : (username ?: @""));
}

static UIView *WCContactAvatarView(NSString *username, BOOL rounded) {
    id contact = WCGroupsPrivateContact(username);
    NSString *url = WCContactsName(contact, @[@"m_nsHeadHDImgUrl", @"m_nsHeadImgUrlHD", @"m_nsHeadImgUrl"]) ?: @"";
    Class helper = NSClassFromString(@"MMHeadImageHelper");
    for (NSString *name in @[@"getContactHeadImageViewWithUsrName:headImgUrl:bAutoUpdate:bRoundCorner:",
                            @"getMainFrameHeadImageViewWithUsrName:headImgUrl:bAutoUpdate:bRoundCorner:"]) {
        SEL selector = NSSelectorFromString(name);
        NSMethodSignature *signature = [helper methodSignatureForSelector:selector];
        if (![helper respondsToSelector:selector] || signature.numberOfArguments != 6
            || signature.methodReturnType[0] != '@' || [signature getArgumentTypeAtIndex:2][0] != '@'
            || [signature getArgumentTypeAtIndex:3][0] != '@'
            || !strchr("BcCsSiIlLqQ", [signature getArgumentTypeAtIndex:4][0])
            || !strchr("BcCsSiIlLqQ", [signature getArgumentTypeAtIndex:5][0])) continue;
        @try {
            id view = ((id (*)(id, SEL, id, id, BOOL, BOOL))objc_msgSend)(helper, selector, username, url, YES, rounded);
            if ([view isKindOfClass:UIView.class]) return view;
        } @catch (__unused NSException *exception) {}
    }
    UIView *view = [UIView new];
    view.backgroundColor = UIColor.tertiarySystemGroupedBackgroundColor;
    return view;
}

UIView *WCGroupsContactAvatarView(NSString *username) { return WCContactAvatarView(username, YES); }

NSInteger WCGroupsContactPickerKind(id contact, NSString *username) {
    if (!username.length) return NSNotFound;
    if ([username hasSuffix:@"@chatroom"] || [username hasSuffix:@"@im.chatroom"]) return 1;
    if ([username hasPrefix:@"gh_"] || !contact) return NSNotFound;
    for (NSString *key in @[@"isBrandContact", @"isOfficialContact", @"isEnterpriseBrand"])
        if ([WCGroupsTweakSafeValue(contact,key) boolValue]) return NSNotFound;
    return [WCGroupsTweakSafeValue(contact,@"isMyContact") boolValue] || [username isEqual:WCGroupsCurrentUserWXID()] ? 0 : NSNotFound;
}
UIColor *WCGroupsColorForDefaultsKey(NSString *key, UIColor *fallbackColor) {
    NSString *hex = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    if (![hex isKindOfClass:[NSString class]]) return fallbackColor;
    NSString *value = [[hex stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    if (value.length != 6 && value.length != 8) return fallbackColor;
    unsigned long long rgba = 0;
    if (![[NSScanner scannerWithString:value] scanHexLongLong:&rgba]) return fallbackColor;
    CGFloat red = ((rgba >> (value.length == 8 ? 24 : 16)) & 0xFF) / 255.0;
    CGFloat green = ((rgba >> (value.length == 8 ? 16 : 8)) & 0xFF) / 255.0;
    CGFloat blue = ((rgba >> (value.length == 8 ? 8 : 0)) & 0xFF) / 255.0;
    CGFloat alpha = value.length == 8 ? (rgba & 0xFF) / 255.0 : 1.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
NSString *WCGroupsHexStringFromColor(UIColor *color) {
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 1.0;
    if (![color getRed:&red green:&green blue:&blue alpha:&alpha]) return @"#8E8E93FF";
    return [NSString stringWithFormat:@"#%02X%02X%02X%02X",
            (int)lround(red * 255.0), (int)lround(green * 255.0),
            (int)lround(blue * 255.0), (int)lround(alpha * 255.0)];
}

@interface WCGroupsColorPicker : UIColorPickerViewController <UIColorPickerViewControllerDelegate>
@property (nonatomic, copy) NSString *defaultsKey;
@end
@implementation WCGroupsColorPicker
- (void)viewDidLoad { [super viewDidLoad];
    WCGroupsSettingsConfigureNavigation(self); self.delegate = self; self.supportsAlpha = YES; }
- (void)saveColor:(UIColor *)color {
    UIColor *resolved = [color resolvedColorWithTraitCollection:self.traitCollection];
    [NSUserDefaults.standardUserDefaults setObject:WCGroupsHexStringFromColor(resolved) forKey:self.defaultsKey];
    WCGroupsSettingsPostChange(self.defaultsKey);
}
- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)picker { [self saveColor:picker.selectedColor]; }
- (void)colorPickerViewControllerDidSelectColor:(UIColorPickerViewController *)picker { [self saveColor:picker.selectedColor]; }
- (void)colorPickerViewController:(UIColorPickerViewController *)picker didSelectColor:(UIColor *)color continuously:(BOOL)continuous API_AVAILABLE(ios(15.0)) {
    [self saveColor:color];
}
@end


void WCGroupsEditChatOption(UIViewController *presenter, NSDictionary *option) {
    WCGroupsColorPicker *picker = [WCGroupsColorPicker new];
    picker.defaultsKey = option[@"key"]; picker.title = option[@"title"];
    picker.selectedColor = WCGroupsColorForDefaultsKey(picker.defaultsKey, UIColor.secondaryLabelColor);
    [presenter presentViewController:picker animated:YES completion:nil];
}
