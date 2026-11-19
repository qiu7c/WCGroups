#import <UIKit/UIKit.h>
BOOL WCGroupsHomePageCornerEnabled(void);
BOOL WCGroupsHomePageIsDark(UIView *view);
UIColor *WCGroupsHomePageCornerColor(UIView *view, BOOL surface);
CGFloat WCGroupsHomePageCornerInset(void);
CGFloat WCGroupsHomePageCornerGap(void);
NSInteger WCGroupsHomePageCornerMergedSection(UITableView *table);
void WCGroupsHomePageCornerLayoutGroup(UIView *banner, CGFloat nativeHeight, CGFloat height, BOOL joined);
void WCGroupsHomePageCornerAttach(UIViewController *controller);

CGFloat WCGroupsHomePageScaleFactor(void);
