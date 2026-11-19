#import <UIKit/UIKit.h>

BOOL WCGroupsHomeGroupsEnabled(void);
BOOL WCGroupsHomeGroupsNative(void);
void WCGroupsHomeGroupsBeginNative(void);
void WCGroupsHomeGroupsEndNative(void);
NSArray<NSDictionary *> *WCGroupsHomeGroupsList(void);
NSString *WCGroupsHomeGroupsSelected(void);
void WCGroupsHomeGroupsSave(NSArray<NSDictionary *> *groups);
void WCGroupsHomeGroupsSelect(NSString *groupID);
NSString *WCGroupsHomeGroupsUserName(id session);
NSArray *WCGroupsHomeGroupsSection(id logic, NSInteger section);
NSIndexPath *WCGroupsHomeGroupsNativePath(id logic, NSIndexPath *path);
NSIndexPath *WCGroupsHomeGroupsFind(id logic, NSString *user);
void WCGroupsHomeGroupsInvalidate(id logic);
void WCGroupsHomeGroupsAttach(UIViewController *controller);
void WCGroupsHomeGroupsDidAppear(UIViewController *controller);
void WCGroupsHomeGroupsSettingsChanged(NSString *key);
void WCGroupsHomeGroupsRefreshAppearance(void);
void WCGroupsHomeGroupsLayoutChrome(UIView *view);
void WCGroupsHomeGroupsMessageAdded(id target, id wrap, BOOL localMessage);
void WCGroupsHomeGroupsChatEntered(id controller);
UIViewController *WCGroupsCreateHomeGroupsSettingsController(void);

NSArray<NSString *> *WCGroupsHomeGroupsPendingNames(void);
void WCGroupsHomeGroupsSetPendingNames(NSArray<NSString *> *names);
UIViewController *WCGroupsCreateHomeGroupsPendingController(void);

void WCGroupsHomeGroupsStyleCell(UIViewController *controller, UITableViewCell *cell, NSIndexPath *path);
