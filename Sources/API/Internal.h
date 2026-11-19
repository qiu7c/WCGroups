#pragma once
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <math.h>
#import <string.h>
#import "Sources/Core/Config.h"

FOUNDATION_EXPORT NSNotificationName const WCGroupsDidChangeNotification;
CGFloat WCGroupsSettingsScaleFactor(void);
id WCGroupsTweakSafeValue(id object, NSString *key);
id WCGroupsServiceForClass(Class cls);
id WCGroupsPrivateContact(NSString *user);
NSString *WCGroupsPrivateContactUserName(id contact);
NSString *WCGroupsCurrentUserWXID(void);
NSArray *WCGroupsPrivateContactList(void);
NSString *WCGroupsPrivateContactDisplayName(id contact, NSString *fallback);
NSString *WCGroupsPrivateNotificationDisplayName(NSString *user, NSString *fallback);
UIView *WCGroupsContactAvatarView(NSString *user);
NSInteger WCGroupsContactPickerKind(id contact, NSString *user);
UITableViewCell *WCGroupsContactPickerCell(UITableView *table, NSString *user, NSString *title);
UIColor *WCGroupsColorForDefaultsKey(NSString *key, UIColor *fallback);
NSString *WCGroupsHexStringFromColor(UIColor *color);
UIImage *WCGroupsSettingsBackImage(void);
void WCGroupsSettingsConfigureNavigation(UIViewController *controller);
void WCGroupsSettingsPostChange(NSString *key);
UIView *WCGroupsSettingsSearchHeader(UITextField *field, CGFloat width);
UITableViewCell *WCGroupsSettingsCardCell(UITableView *table, NSString *identifier, UITableViewCellStyle style, NSIndexPath *path);
void WCGroupsEditChatOption(UIViewController *presenter, NSDictionary *option);
void WCGroupsShowToast(NSString *text);
UIViewController *WCGroupsCreateSettingsController(void);
void WCGroupsRefreshEntry(UIViewController *controller);
void WCGroupsRegisterEntry(void);
#import "Sources/API/WCGroupsHomePageCornerAPI.h"
#import "Sources/API/WCGroupsHomeGroupsAPI.h"
#import "Sources/API/WCGroupsPopupAPI.h"

@interface NewMainFrameViewController : UIViewController
@end

@interface MFBannerBtn : UIButton
@end

@interface MFWebMMBtn : MFBannerBtn
@end

@interface MainFrameLogicController : NSObject
@end

@interface MainSessionMgr : NSObject
@end

@interface CMessageMgr : NSObject
@end

@interface BaseMsgContentViewController : UIViewController
@end

@interface MMDarkModeConfigUtil : NSObject
@end

#import "Sources/Integration/HomeAppearanceBridge.h"

@interface MoreViewController : UIViewController
@end

UIViewController *WCGroupsCreatePluginSettingsController(void);
UIView *WCGroupsSettingsFooter(CGFloat width);
