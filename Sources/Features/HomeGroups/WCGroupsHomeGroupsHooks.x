#import "Sources/API/Internal.h"

%hook NewMainFrameViewController
- (void)viewDidLoad {
    %orig;
    WCGroupsHomeGroupsAttach((UIViewController *)self);
    WCGroupsHomePageCornerAttach((UIViewController *)self);
}
- (void)tableView:(UITableView *)table willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)path {
    %orig(table,cell,path);
    WCGroupsHomeGroupsStyleCell((UIViewController *)self,cell,path);
}
- (void)viewWillAppear:(BOOL)animated {
    %orig(animated);
    WCGroupsHomeGroupsAttach((UIViewController *)self);
    WCGroupsHomePageCornerAttach((UIViewController *)self);
}
- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);
    WCGroupsHomeGroupsDidAppear((UIViewController *)self);
}
- (void)viewDidLayoutSubviews {
    %orig;
    WCGroupsHomeGroupsAttach((UIViewController *)self);
    WCGroupsHomePageCornerAttach((UIViewController *)self);
}
%end

%hook MainFrameLogicController
- (BOOL)isTopSessionFolding {
    if (WCGroupsHomeGroupsEnabled()) return NO;
    return %orig;
}
- (BOOL)canFoldTopSession {
    if (WCGroupsHomeGroupsEnabled()) return NO;
    return %orig;
}
- (void)setReadyToLoadData {
    WCGroupsHomeGroupsInvalidate(self);
    %orig;
    WCGroupsHomeGroupsInvalidate(self);
}
- (id)getSessionBaseInfoAtIndexPath:(NSIndexPath *)path {
    NSIndexPath *native=WCGroupsHomeGroupsNativePath(self,path);
    WCGroupsHomeGroupsBeginNative();
    id result=%orig(native);
    WCGroupsHomeGroupsEndNative();
    return result;
}
- (long long)getSessionCountForSection:(long long)section {
    if ((section!=1 && section!=2) || WCGroupsHomeGroupsNative() || !WCGroupsHomeGroupsEnabled()) {
        return %orig(section);
    }
    return (long long)WCGroupsHomeGroupsSection(self, section).count;
}
- (unsigned int)getSessionCount {
    if (WCGroupsHomeGroupsNative() || !WCGroupsHomeGroupsEnabled()) {
        return %orig;
    }
    return (unsigned int)(WCGroupsHomeGroupsSection(self,1).count + WCGroupsHomeGroupsSection(self,2).count);
}
- (unsigned int)getVisibleSessionCount {
    if (WCGroupsHomeGroupsNative() || !WCGroupsHomeGroupsEnabled()) {
        return %orig;
    }
    return (unsigned int)(WCGroupsHomeGroupsSection(self,1).count + WCGroupsHomeGroupsSection(self,2).count);
}
- (id)getSessionInfoAtIndexPath:(NSIndexPath *)path {
    NSIndexPath *native = WCGroupsHomeGroupsNativePath(self, path);
    WCGroupsHomeGroupsBeginNative();
    id result = %orig(native);
    WCGroupsHomeGroupsEndNative();
    return result;
}
- (id)getCellDataAtIndexPath:(NSIndexPath *)path {
    NSIndexPath *native = WCGroupsHomeGroupsNativePath(self, path);
    WCGroupsHomeGroupsBeginNative();
    id result = %orig(native);
    WCGroupsHomeGroupsEndNative();
    return result;
}
- (id)indexPathOfSessionUserName:(NSString *)user {
    if (WCGroupsHomeGroupsNative() || !WCGroupsHomeGroupsEnabled()) {
        return %orig(user);
    }
    return WCGroupsHomeGroupsFind(self,user);
}
- (long long)indexOfSessionUserName:(NSString *)user inSection:(long long)section {
    if (WCGroupsHomeGroupsNative() || !WCGroupsHomeGroupsEnabled()) {
        return %orig(user,section);
    }
    NSIndexPath *path = WCGroupsHomeGroupsFind(self,user);
    return path && path.section == section ? path.row : NSNotFound;
}
- (long long)indexInAllVisibleSessions:(NSString *)user {
    if (WCGroupsHomeGroupsNative() || !WCGroupsHomeGroupsEnabled()) {
        return %orig(user);
    }
    NSIndexPath *path = WCGroupsHomeGroupsFind(self,user);
    if (!path) return NSNotFound;
    NSUInteger count = path.row;
    for (NSInteger section=1;section<path.section;section++) count += WCGroupsHomeGroupsSection(self,section).count;
    return count;
}
- (void)onMainSessionReload {
    WCGroupsHomeGroupsInvalidate(self);
    %orig;
    WCGroupsHomeGroupsInvalidate(self);
}
- (void)onSessionRebuildEnd {
    WCGroupsHomeGroupsInvalidate(self);
    %orig;
    WCGroupsHomeGroupsInvalidate(self);
}
- (void)onNeedRebuild {
    WCGroupsHomeGroupsInvalidate(self);
    %orig;
    WCGroupsHomeGroupsInvalidate(self);
}
- (void)onSessionChanged:(id)session {
    WCGroupsHomeGroupsInvalidate(self);
    %orig(session);
    WCGroupsHomeGroupsInvalidate(self);
}
- (void)onNewMsgArriving:(id)message NotifyFlag:(long long)flag {
    WCGroupsHomeGroupsInvalidate(self);
    %orig(message,flag);
    WCGroupsHomeGroupsInvalidate(self);
}
- (void)onDeleteSession:(unsigned int)index withUser:(id)user {
    WCGroupsHomeGroupsInvalidate(self);
    %orig(index,user);
    WCGroupsHomeGroupsInvalidate(self);
}
- (void)onHideSessionWithUserName:(id)user {
    WCGroupsHomeGroupsInvalidate(self);
    %orig(user);
    WCGroupsHomeGroupsInvalidate(self);
}
- (void)OnChangeGroup:(id)group {
    WCGroupsHomeGroupsInvalidate(self);
    %orig(group);
    WCGroupsHomeGroupsInvalidate(self);
}
- (void)OnChangeNotifyStatus:(id)user withStatus:(BOOL)status {
    WCGroupsHomeGroupsInvalidate(self);
    %orig(user,status);
    WCGroupsHomeGroupsInvalidate(self);
}
%end

%hook CMessageMgr
- (void)AddMsg:(NSString *)user MsgWrap:(id)wrap {
    %orig(user, wrap);
    WCGroupsHomeGroupsMessageAdded(user, wrap, NO);
}
- (void)onNewSyncAddMessage:(id)wrap {
    %orig(wrap);
    WCGroupsHomeGroupsMessageAdded(nil,wrap,NO);
}
- (void)AddLocalMsg:(id)user MsgWrap:(id)wrap {
    %orig(user,wrap);
    WCGroupsHomeGroupsMessageAdded(user,wrap,YES);
}
- (void)AddLocalMsg:(id)user MsgWrap:(id)wrap fixTime:(BOOL)fixTime NewMsgArriveNotify:(BOOL)notify {
    %orig(user,wrap,fixTime,notify);
    WCGroupsHomeGroupsMessageAdded(user,wrap,YES);
}
- (void)AsyncOnAddMsg:(id)user MsgWrap:(id)wrap {
    %orig(user,wrap);
    WCGroupsHomeGroupsMessageAdded(user,wrap,NO);
}
%end

%hook MainSessionMgr
- (BOOL)isFoldTopSession {
    if (WCGroupsHomeGroupsEnabled()) return NO;
    return %orig;
}
- (void)updateMainSessionList {
    WCGroupsHomeGroupsInvalidate(self);
    %orig;
    WCGroupsHomeGroupsInvalidate(self);
}
- (void)updateMainSessionListNotify:(BOOL)notify {
    WCGroupsHomeGroupsInvalidate(self);
    %orig(notify);
    WCGroupsHomeGroupsInvalidate(self);
}
- (void)rebuildMainSessions {
    WCGroupsHomeGroupsInvalidate(self);
    %orig;
    WCGroupsHomeGroupsInvalidate(self);
}
%end

%ctor {
    %init;
}
