#import <math.h>
#import "Sources/API/Internal.h"

@interface WCGroupsLocalHomeGroupMembers : UITableViewController <UITextFieldDelegate>
@property (nonatomic, copy) NSString *groupID;
@property (nonatomic) BOOL instant;
@property (nonatomic, strong) NSMutableSet *selected;
@property (nonatomic, copy) NSArray<NSDictionary *> *contacts;
@property (nonatomic, copy) NSArray<NSDictionary *> *filtered;
@property (nonatomic, copy) NSArray<NSArray<NSDictionary *> *> *contactSections;
@property (nonatomic, strong) UITextField *search;
@end
@implementation WCGroupsLocalHomeGroupMembers
- (void)viewDidLoad {
    [super viewDidLoad];self.title=self.instant?@"即时消息会话":@"分组成员";WCGroupsSettingsConfigureNavigation(self);
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    self.tableView.backgroundColor=UIColor.systemGroupedBackgroundColor;
    self.tableView.rowHeight=64*WCGroupsSettingsScaleFactor();
    self.tableView.keyboardDismissMode=UIScrollViewKeyboardDismissModeOnDrag;
    NSMutableSet *assigned=[NSMutableSet set];
    for (NSDictionary *group in WCGroupsHomeGroupsList()) if (!self.instant && [group[@"type"] isEqual:@"custom"] && ![group[@"id"] isEqual:self.groupID]) [assigned addObjectsFromArray:group[@"members"]];
    NSMutableDictionary *rows=[NSMutableDictionary dictionary];
    for (id contact in WCGroupsPrivateContactList()) {
        NSString *user=[contact isKindOfClass:NSString.class]?contact:WCGroupsPrivateContactUserName(contact);
        id native=[contact isKindOfClass:NSString.class]?WCGroupsPrivateContact(user):contact;
        NSInteger kind=WCGroupsContactPickerKind(native,user);
        if (kind==NSNotFound || [assigned containsObject:user]) continue;
        rows[user]=@{@"user":user,@"kind":@(kind),@"title":WCGroupsPrivateContactDisplayName([contact isKindOfClass:NSString.class]?WCGroupsPrivateContact(user):contact,user)};
    }
    for (NSString *user in self.selected) if (!rows[user]) {
        NSInteger kind=WCGroupsContactPickerKind(WCGroupsPrivateContact(user),user);
        if (kind!=NSNotFound) rows[user]=@{@"user":user,@"kind":@(kind),@"title":WCGroupsPrivateNotificationDisplayName(user,user)};
    }
    self.contacts=[rows.allValues sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *a,NSDictionary *b){return [a[@"title"] localizedCaseInsensitiveCompare:b[@"title"]];}];
    self.search=[UITextField new];self.search.placeholder=@"搜索联系人或群聊";self.search.delegate=self;
    [self.search addTarget:self action:@selector(filter) forControlEvents:UIControlEventEditingChanged];
    self.tableView.tableHeaderView=WCGroupsSettingsSearchHeader(self.search,self.view.bounds.size.width);[self filter];
}
- (void)filter {
    NSString *q=self.search.text ?: @"";
    self.filtered=q.length?[self.contacts filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary *row,__unused NSDictionary *bindings){return [row[@"title"] localizedCaseInsensitiveContainsString:q] || [row[@"user"] localizedCaseInsensitiveContainsString:q];}]]:self.contacts;
    NSMutableArray *friends=[NSMutableArray array], *groups=[NSMutableArray array];
    for (NSDictionary *row in self.filtered) [( [row[@"kind"] integerValue]==0 ? friends : groups ) addObject:row];
    self.contactSections=@[friends,groups];
    [self.tableView reloadData];
}
- (BOOL)textFieldShouldReturn:(UITextField *)field { [field resignFirstResponder];return YES; }
- (NSArray<NSDictionary *> *)rowsInSection:(NSInteger)section {
    return self.contactSections[section];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)table { return 2; }
- (NSString *)tableView:(UITableView *)table titleForHeaderInSection:(NSInteger)section { return section==0?@"好友":@"群聊"; }
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section { return [self rowsInSection:section].count; }
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)path {
    NSDictionary *row=[self rowsInSection:path.section][path.row];
    UITableViewCell *cell=WCGroupsContactPickerCell(table,row[@"user"],row[@"title"]);
    cell.accessoryType=[self.selected containsObject:row[@"user"]]?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;cell.tintColor=UIColor.systemBlueColor;return cell;
}
- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)path {
    NSString *user=[self rowsInSection:path.section][path.row][@"user"];
    if ([self.selected containsObject:user]) [self.selected removeObject:user];else [self.selected addObject:user];
    [table deselectRowAtIndexPath:path animated:YES];[table reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
}
- (void)save {
    if (self.instant) { WCGroupsHomeGroupsSetPendingNames(self.selected.allObjects);[self.navigationController popViewControllerAnimated:YES];return; }
    NSMutableArray *groups=[WCGroupsHomeGroupsList() mutableCopy];
    for (NSUInteger i=0;i<groups.count;i++) if ([groups[i][@"id"] isEqual:self.groupID]) {
        NSMutableDictionary *group=[groups[i] mutableCopy];group[@"members"]=[self.selected.allObjects sortedArrayUsingSelector:@selector(compare:)];groups[i]=group;break;
    }
    WCGroupsHomeGroupsSave(groups);[self.navigationController popViewControllerAnimated:YES];
}
@end

@interface WCGroupsGroupManager : UITableViewController
@end

@implementation WCGroupsGroupManager
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"分组管理";
    WCGroupsSettingsConfigureNavigation(self);
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.tableView.rowHeight = 54;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return WCGroupsHomeGroupsList().count + 1;
}
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)path {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.minimumScaleFactor = .85;
    if (path.row == (NSInteger)WCGroupsHomeGroupsList().count) {
        cell.textLabel.text = @"添加分组";
        cell.textLabel.textColor = UIColor.systemBlueColor;
        cell.imageView.image = [UIImage systemImageNamed:@"plus.circle"];
        cell.imageView.tintColor = UIColor.systemBlueColor;
        return cell;
    }
    NSDictionary *group = WCGroupsHomeGroupsList()[path.row];
    cell.textLabel.text = group[@"title"];
    cell.detailTextLabel.text = [group[@"id"] isEqual:WCGroupsHomeGroupsSelected()] ? @"当前"
        : ([group[@"type"] isEqual:@"custom"] ? [NSString stringWithFormat:@"%lu 位", (unsigned long)[group[@"members"] count]] : nil);
    cell.accessoryType = table.editing ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)path {
    [table deselectRowAtIndexPath:path animated:YES];
    if (table.editing) return;
    if (path.row == (NSInteger)WCGroupsHomeGroupsList().count) [self addGroup];
    else [self editGroup:WCGroupsHomeGroupsList()[path.row]];
}
- (BOOL)tableView:(UITableView *)table canEditRowAtIndexPath:(NSIndexPath *)path {
    return path.row < (NSInteger)WCGroupsHomeGroupsList().count;
}
- (BOOL)tableView:(UITableView *)table canMoveRowAtIndexPath:(NSIndexPath *)path {
    return [self tableView:table canEditRowAtIndexPath:path];
}
- (BOOL)tableView:(UITableView *)table shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)path {
    return [self tableView:table canEditRowAtIndexPath:path];
}
- (NSIndexPath *)tableView:(UITableView *)table targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)source toProposedIndexPath:(NSIndexPath *)target {
    return [NSIndexPath indexPathForRow:MIN(target.row, (NSInteger)WCGroupsHomeGroupsList().count - 1) inSection:0];
}
- (void)tableView:(UITableView *)table moveRowAtIndexPath:(NSIndexPath *)source toIndexPath:(NSIndexPath *)target {
    NSMutableArray *groups = [WCGroupsHomeGroupsList() mutableCopy];
    id group = groups[source.row];
    [groups removeObjectAtIndex:source.row];
    [groups insertObject:group atIndex:target.row];
    WCGroupsHomeGroupsSave(groups);
}
- (void)tableView:(UITableView *)table commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath *)path {
    if (style != UITableViewCellEditingStyleDelete) return;
    if (WCGroupsHomeGroupsList().count < 2) { WCGroupsShowToast(@"至少保留一个分组"); return; }
    NSMutableArray *groups = [WCGroupsHomeGroupsList() mutableCopy];
    [groups removeObjectAtIndex:path.row];
    WCGroupsHomeGroupsSave(groups);
    [table reloadData];
}
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView reloadData];
}
- (void)addGroup {
    NSMutableArray *options=[NSMutableArray arrayWithObject:[WCGroupsLocalPopupOption optionWithTitle:@"自定义分组" value:@"custom"]];
    NSArray *builtins=@[@{@"id":@"builtin.all",@"type":@"all",@"title":@"全部"},@{@"id":@"builtin.friend",@"type":@"friend",@"title":@"好友"},@{@"id":@"builtin.group",@"type":@"group",@"title":@"群聊"},@{@"id":@"builtin.other",@"type":@"other",@"title":@"其他"},@{@"id":@"builtin.instant",@"type":@"instant",@"title":@"即时消息"}];
    NSSet *ids=[NSSet setWithArray:[WCGroupsHomeGroupsList() valueForKey:@"id"]];
    for (NSDictionary *group in builtins) if (![ids containsObject:group[@"id"]]) [options addObject:[WCGroupsLocalPopupOption optionWithTitle:group[@"title"] value:group]];
    [WCGroupsLocalPopup showOptionsWithTitle:@"添加分组" message:nil options:options selected:nil completion:^(id choice){
        if ([choice isKindOfClass:NSDictionary.class]) { NSMutableArray *groups=[WCGroupsHomeGroupsList() mutableCopy];[groups addObject:choice];WCGroupsHomeGroupsSave(groups);[self.tableView reloadData];return; }
        [WCGroupsLocalPopup showInputWithTitle:@"新建分组" message:nil text:nil placeholder:@"分组名称" keyboard:UIKeyboardTypeDefault completion:^(NSString *title){
            if (!title.length) return;NSMutableArray *groups=[WCGroupsHomeGroupsList() mutableCopy];
            [groups addObject:@{@"id":NSUUID.UUID.UUIDString,@"type":@"custom",@"title":title,@"members":@[]}];WCGroupsHomeGroupsSave(groups);[self.tableView reloadData];
        }];
    }];
}
- (void)editGroup:(NSDictionary *)group {
    NSMutableArray *options=[NSMutableArray arrayWithObjects:[WCGroupsLocalPopupOption optionWithTitle:@"切换到此分组" value:@"select"],[WCGroupsLocalPopupOption optionWithTitle:@"重命名" value:@"rename"],nil];
    if ([group[@"type"] isEqual:@"custom"]) [options addObject:[WCGroupsLocalPopupOption optionWithTitle:@"设置成员" value:@"members"]];
    [WCGroupsLocalPopup showOptionsWithTitle:group[@"title"] message:nil options:options selected:nil completion:^(id action){
        if ([action isEqual:@"select"]) { WCGroupsHomeGroupsSelect(group[@"id"]);[self.tableView reloadData]; }
        else if ([action isEqual:@"members"]) {
            WCGroupsLocalHomeGroupMembers *picker=[[WCGroupsLocalHomeGroupMembers alloc] initWithStyle:UITableViewStyleInsetGrouped];picker.hidesBottomBarWhenPushed=YES;picker.groupID=group[@"id"];picker.selected=[NSMutableSet setWithArray:group[@"members"]];
            [self.navigationController pushViewController:picker animated:YES];
        } else if ([action isEqual:@"rename"]) {
            [WCGroupsLocalPopup showInputWithTitle:@"重命名" message:nil text:group[@"title"] placeholder:@"分组名称" keyboard:UIKeyboardTypeDefault completion:^(NSString *title){
                if (!title.length)return;NSMutableArray *groups=[WCGroupsHomeGroupsList() mutableCopy];
                for (NSUInteger i=0;i<groups.count;i++) if ([groups[i][@"id"] isEqual:group[@"id"]]) { NSMutableDictionary *item=[groups[i] mutableCopy];item[@"title"]=title;groups[i]=item;break; }
                WCGroupsHomeGroupsSave(groups);[self.tableView reloadData];
            }];
        }
    }];
}
@end

@interface WCGroupsLocalHomeGroupsSettings : UITableViewController
@property (nonatomic, copy) NSArray<NSArray<NSDictionary *> *> *rows;
@property (nonatomic, strong) NSMutableIndexSet *openSections;
@end
@implementation WCGroupsLocalHomeGroupsSettings
- (void)viewDidLoad {
    [super viewDidLoad];self.title=@"微信分组";WCGroupsSettingsConfigureNavigation(self);
    self.openSections=[NSMutableIndexSet indexSet];
    self.tableView.backgroundColor=UIColor.systemGroupedBackgroundColor;
    self.tableView.tableHeaderView=[[UIView alloc] initWithFrame:CGRectMake(0,0,0,12)];
    self.tableView.tableFooterView=WCGroupsSettingsFooter(self.tableView.bounds.size.width);
    self.tableView.sectionHeaderHeight=0;self.tableView.sectionFooterHeight=0;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight=50*WCGroupsSettingsScaleFactor();
    // Each number row contains its actual storage key and allowed UI range.
    self.rows=@[
      @[@{@"title":@"启用主页分组",@"key":WCGroupsHomeGroupsEnabledKey,@"type":@"switch"}],
      @[],
      @[@{@"title":@"阅后移出即时消息",@"key":WCGroupsHomeGroupsBurnAfterReadingKey,@"type":@"switch"},
        @{@"title":@"置顶会话持续显示",@"key":WCGroupsHomeGroupsPinnedPersistentKey,@"type":@"switch"},
        @{@"title":@"横滑切换",@"key":WCGroupsHomeGroupsGestureKey,@"type":@"switch"},
        @{@"title":@"切换方式",@"key":WCGroupsHomeGroupsContinuousKey,@"type":@"choice",@"items":@[@"到边停止",@"循环切换"]},
        @{@"title":@"切换方向",@"key":WCGroupsHomeGroupsReverseKey,@"type":@"choice",@"items":@[@"常规",@"反向"]},
        @{@"title":@"横滑震感",@"key":WCGroupsHomeGroupsHapticKey,@"type":@"switch"},
        @{@"title":@"按钮震感",@"key":WCGroupsHomeGroupsButtonHapticKey,@"type":@"switch"},
        @{@"title":@"两侧手势范围",@"key":WCGroupsHomeGroupsGestureRatioKey,@"type":@"number",@"min":@0.02,@"max":@1}],
      @[@{@"title":@"统一改色",@"key":WCGroupsHomeGroupsUnifiedColorEnabledKey,@"type":@"switch"},
        @{@"title":@"统一背景颜色",@"key":WCGroupsHomeGroupsUnifiedColorKey,@"type":@"color"},
        @{@"title":@"字号",@"key":WCGroupsHomeGroupsFontSizeKey,@"type":@"number",@"min":@10,@"max":@24},
        @{@"title":@"字重",@"key":WCGroupsHomeGroupsFontWeightKey,@"type":@"number",@"min":@100,@"max":@900},
        @{@"title":@"指示样式",@"type":@"indicator",@"items":@[@"滑块",@"下划线",@"同时",@"隐藏"]},
        @{@"title":@"滑块大小 (%)",@"key":WCGroupsHomeGroupsSliderSizeKey,@"type":@"number",@"min":@0,@"max":@100},
        @{@"title":@"滑块圆角",@"key":WCGroupsHomeGroupsSliderRadiusKey,@"type":@"number",@"min":@0,@"max":@100},
        @{@"title":@"滑块动画",@"key":WCGroupsHomeGroupsSliderAnimationKey,@"type":@"switch"},
        @{@"title":@"滑块颜色",@"key":WCGroupsHomeGroupsSliderColorKey,@"type":@"color"},
        @{@"title":@"下划线长度",@"key":WCGroupsHomeGroupsUnderlineLengthKey,@"type":@"number",@"min":@1,@"max":@200},
        @{@"title":@"下划线粗细",@"key":WCGroupsHomeGroupsUnderlineThicknessKey,@"type":@"number",@"min":@0.5,@"max":@20},
        @{@"title":@"下划线偏移",@"key":WCGroupsHomeGroupsUnderlineOffsetKey,@"type":@"number",@"min":@-50,@"max":@50},
        @{@"title":@"下划线颜色",@"key":WCGroupsHomeGroupsUnderlineColorKey,@"type":@"color"}],
      @[@{@"title":@"隐藏角标",@"key":WCGroupsHomeGroupsHideBadgesKey,@"type":@"switch"},
        @{@"title":@"隐藏红点",@"key":WCGroupsHomeGroupsHideRedDotsKey,@"type":@"switch"},
        @{@"title":@"角标样式",@"key":WCGroupsHomeGroupsNativeBadgeKey,@"type":@"choice",@"items":@[@"自绘",@"原生"]},
        @{@"title":@"角标横向偏移",@"key":WCGroupsHomeGroupsBadgeXKey,@"type":@"number",@"min":@-50,@"max":@50},
        @{@"title":@"角标纵向偏移",@"key":WCGroupsHomeGroupsBadgeYKey,@"type":@"number",@"min":@-50,@"max":@50},
        @{@"title":@"角标背景",@"key":WCGroupsHomeGroupsBadgeColorKey,@"type":@"color"},
        @{@"title":@"角标文字",@"key":WCGroupsHomeGroupsBadgeTextColorKey,@"type":@"color"}],
      @[@{@"title":@"插件设置",@"type":@"plugin"}]];
}
- (void)viewWillAppear:(BOOL)animated { [super viewWillAppear:animated];[self.openSections removeAllIndexes];[self.tableView reloadData]; }
- (CGFloat)tableView:(UITableView *)table heightForHeaderInSection:(NSInteger)section { return 0; }
- (CGFloat)tableView:(UITableView *)table heightForFooterInSection:(NSInteger)section { return 0; }
- (NSInteger)numberOfSectionsInTableView:(UITableView *)table { return self.rows.count; }
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section { if (section==0 || section==1 || section==5) return 1;
    if (![self.openSections containsIndex:section]) return 1;
    return 1+self.rows[section].count; }
- (CGFloat)tableView:(UITableView *)table heightForRowAtIndexPath:(NSIndexPath *)path {
    if (path.section<2 || path.section==5 || !path.row) return 50;
    NSString *type=self.rows[path.section][path.row-1][@"type"];
    return [type isEqual:@"choice"] || [type isEqual:@"indicator"] ? 88 : 50;
}
- (NSString *)tableView:(UITableView *)table titleForHeaderInSection:(NSInteger)section { return nil; }
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)path {
    UITableViewCell *cell=WCGroupsSettingsCardCell(table,nil,UITableViewCellStyleValue1,path);
    cell.textLabel.font=[UIFont systemFontOfSize:15*WCGroupsSettingsScaleFactor()];cell.detailTextLabel.font=[UIFont systemFontOfSize:13*WCGroupsSettingsScaleFactor()];
    cell.backgroundColor=UIColor.clearColor;
    if (path.section==5) {
        cell.textLabel.text=@"插件设置";
        cell.imageView.image=[UIImage systemImageNamed:@"gearshape"];
        cell.imageView.tintColor=UIColor.systemBlueColor;
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    if (path.section==1) {
        cell.textLabel.text=@"分组管理";
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%lu 个",(unsigned long)WCGroupsHomeGroupsList().count];
        cell.imageView.image=[UIImage systemImageNamed:@"rectangle.3.group"];
        cell.imageView.tintColor=UIColor.systemBlueColor;
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    if (path.section>0 && path.row==0) {
        cell.textLabel.text=@[@"",@"分组管理",@"切换与置顶",@"分组外观",@"未读角标"][path.section];
        cell.imageView.image=[UIImage systemImageNamed:@[@"",@"rectangle.3.group",@"arrow.left.arrow.right",@"slider.horizontal.3",@"app.badge"][path.section]
            withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:17 weight:UIImageSymbolWeightRegular]];
        cell.imageView.tintColor=UIColor.systemBlueColor;
        UIImageView *arrow=[[UIImageView alloc] initWithImage:[UIImage systemImageNamed:[self.openSections containsIndex:path.section]?@"chevron.down":@"chevron.right"]];
        arrow.tintColor=UIColor.tertiaryLabelColor;arrow.frame=CGRectMake(0,0,12,16);arrow.contentMode=UIViewContentModeScaleAspectFit;cell.accessoryView=arrow;return cell;
    }
    if (path.section>0) cell.indentationLevel=1;
    cell.indentationWidth=18*WCGroupsSettingsScaleFactor();
    NSInteger rowIndex=path.row-(path.section>0?1:0);
    NSDictionary *row=self.rows[path.section][rowIndex];NSString *key=row[@"key"];cell.textLabel.text=row[@"title"];
    NSString *type=row[@"type"];
    if ([type isEqual:@"choice"] || [type isEqual:@"indicator"]) {
        cell.textLabel.text=nil;
        UILabel *label=[UILabel new]; label.text=row[@"title"]; label.font=[UIFont systemFontOfSize:15];
        UISegmentedControl *control=[[UISegmentedControl alloc] initWithItems:row[@"items"]];
        control.accessibilityIdentifier=key; control.accessibilityLabel=type;
        NSUserDefaults *defaults=NSUserDefaults.standardUserDefaults;
        if ([type isEqual:@"indicator"]) {
            BOOL slider=[defaults boolForKey:WCGroupsHomeGroupsSliderKey], underline=[defaults boolForKey:WCGroupsHomeGroupsUnderlineKey];
            control.selectedSegmentIndex=slider?(underline?2:0):(underline?1:3);
        } else control.selectedSegmentIndex=[defaults boolForKey:key]?1:0;
        [control addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
        for (UIView *view in @[label,control]) { view.translatesAutoresizingMaskIntoConstraints=NO; [cell.contentView addSubview:view]; }
        [NSLayoutConstraint activateConstraints:@[
            [label.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:34],
            [label.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-16],
            [label.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:10],
            [control.leadingAnchor constraintEqualToAnchor:label.leadingAnchor],
            [control.trailingAnchor constraintEqualToAnchor:label.trailingAnchor],
            [control.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:8],
            [control.heightAnchor constraintEqualToConstant:32]
        ]];
    } else if ([row[@"type"] isEqual:@"switch"]) {
        UISwitch *toggle=[UISwitch new];toggle.onTintColor=UIColor.systemBlueColor;toggle.on=[NSUserDefaults.standardUserDefaults boolForKey:key];
        toggle.accessibilityIdentifier=key;[toggle addTarget:self action:@selector(toggle:) forControlEvents:UIControlEventValueChanged];cell.accessoryView=toggle;
    } else { cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;if ([row[@"type"] isEqual:@"number"]) cell.detailTextLabel.text=[[NSUserDefaults.standardUserDefaults objectForKey:key] description]; }
    return cell;
}
- (void)segmentChanged:(UISegmentedControl *)control {
    NSUserDefaults *defaults=NSUserDefaults.standardUserDefaults;
    NSInteger index=control.selectedSegmentIndex;
    if ([control.accessibilityLabel isEqual:@"indicator"]) {
        [defaults setBool:index==0 || index==2 forKey:WCGroupsHomeGroupsSliderKey];
        [defaults setBool:index==1 || index==2 forKey:WCGroupsHomeGroupsUnderlineKey];
        WCGroupsSettingsPostChange(nil);
    } else {
        [defaults setBool:index==1 forKey:control.accessibilityIdentifier];
        WCGroupsSettingsPostChange(control.accessibilityIdentifier);
    }
}
- (void)toggle:(UISwitch *)toggle {
    [NSUserDefaults.standardUserDefaults setBool:toggle.on forKey:toggle.accessibilityIdentifier];WCGroupsSettingsPostChange(toggle.accessibilityIdentifier);
}
- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)path {
    [table deselectRowAtIndexPath:path animated:YES];
    if (path.section==5) {
        [self.navigationController pushViewController:WCGroupsCreatePluginSettingsController() animated:YES];
        return;
    }
    if (path.section==1) {
        WCGroupsGroupManager *manager=[[WCGroupsGroupManager alloc] initWithStyle:UITableViewStyleInsetGrouped];
        manager.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:manager animated:YES];
        return;
    }
    if (path.section>0 && path.row==0) {
        if ([self.openSections containsIndex:path.section]) [self.openSections removeIndex:path.section];else [self.openSections addIndex:path.section];
        [table reloadSections:[NSIndexSet indexSetWithIndex:path.section] withRowAnimation:UITableViewRowAnimationAutomatic];return;
    }
    NSInteger rowIndex=path.row-(path.section>0?1:0);
    NSDictionary *row=self.rows[path.section][rowIndex];NSString *key=row[@"key"];
    if ([row[@"type"] isEqual:@"color"]) { WCGroupsEditChatOption(self,@{@"title":row[@"title"],@"type":@"color",@"key":key});return; }
    if (![row[@"type"] isEqual:@"number"]) return;
    [WCGroupsLocalPopup showInputWithTitle:row[@"title"] message:nil text:[[NSUserDefaults.standardUserDefaults objectForKey:key] description]
        placeholder:[NSString stringWithFormat:@"%@–%@",row[@"min"],row[@"max"]] keyboard:UIKeyboardTypeNumbersAndPunctuation completion:^(NSString *text){
        NSScanner *scan=[NSScanner scannerWithString:text];double value=0;
        if (![scan scanDouble:&value] || !scan.isAtEnd || !isfinite(value) || value<[row[@"min"] doubleValue] || value>[row[@"max"] doubleValue]) { WCGroupsShowToast(@"数值超出范围");return; }
        [NSUserDefaults.standardUserDefaults setDouble:value forKey:key];WCGroupsSettingsPostChange(key);[self.tableView reloadData];
    }];
}

@end

UIViewController *WCGroupsCreateHomeGroupsSettingsController(void) { WCGroupsLocalHomeGroupsSettings *controller=[[WCGroupsLocalHomeGroupsSettings alloc] initWithStyle:UITableViewStylePlain];controller.hidesBottomBarWhenPushed=YES;return controller; }

UIViewController *WCGroupsCreateHomeGroupsPendingController(void) { WCGroupsLocalHomeGroupMembers *picker=[[WCGroupsLocalHomeGroupMembers alloc] initWithStyle:UITableViewStyleInsetGrouped];picker.instant=YES;picker.hidesBottomBarWhenPushed=YES;picker.selected=[NSMutableSet setWithArray:WCGroupsHomeGroupsPendingNames()];return picker; }
