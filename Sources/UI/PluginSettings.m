#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import "Sources/API/Internal.h"

static BOOL WCGroupsImportConfiguration(NSData *data) {
    if (!data) return NO;
    id document = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (![document isKindOfClass:NSDictionary.class] || ![document[@"plugin"] isEqual:@"WCGroups"]
        || ![document[@"format"] isEqual:@1] || ![document[@"settings"] isKindOfClass:NSDictionary.class]) return NO;
    NSDictionary *settings = document[@"settings"], *defaults = WCGroupsDefaultSettings();
    NSDictionary *ranges = @{
        WCGroupsHomeGroupsGestureRatioKey: @[@0.02, @1],
        WCGroupsHomeGroupsFontSizeKey: @[@10, @24],
        WCGroupsHomeGroupsFontWeightKey: @[@100, @900],
        WCGroupsHomeGroupsSliderSizeKey: @[@0, @100],
        WCGroupsHomeGroupsSliderRadiusKey: @[@0, @100],
        WCGroupsHomeGroupsUnderlineLengthKey: @[@1, @200],
        WCGroupsHomeGroupsUnderlineThicknessKey: @[@0.5, @20],
        WCGroupsHomeGroupsUnderlineOffsetKey: @[@-50, @50],
        WCGroupsHomeGroupsBadgeXKey: @[@-50, @50],
        WCGroupsHomeGroupsBadgeYKey: @[@-50, @50]
    };
    for (NSString *key in settings) {
        id value = settings[key], expected = defaults[key];
        if (!expected) return NO;
        if ([expected isKindOfClass:NSNumber.class]) {
            if (![value isKindOfClass:NSNumber.class] || !isfinite([value doubleValue])) return NO;
            if (CFGetTypeID((__bridge CFTypeRef)expected) == CFBooleanGetTypeID()
                && CFGetTypeID((__bridge CFTypeRef)value) != CFBooleanGetTypeID()) return NO;
            NSArray *range = ranges[key];
            if (range && ([value doubleValue] < [range[0] doubleValue] || [value doubleValue] > [range[1] doubleValue])) return NO;
        } else if ([expected isKindOfClass:NSString.class]) {
            if (![value isKindOfClass:NSString.class]) return NO;
            if ([key hasSuffix:@"color"] && [value length]) {
                NSString *hex = [value hasPrefix:@"#"] ? [value substringFromIndex:1] : value;
                unsigned long long parsed;
                NSScanner *scanner = [NSScanner scannerWithString:hex];
                if ((hex.length != 6 && hex.length != 8) || ![scanner scanHexLongLong:&parsed] || !scanner.isAtEnd) return NO;
            }
        } else if ([expected isKindOfClass:NSArray.class]) {
            if (![value isKindOfClass:NSArray.class]) return NO;
        } else if ([expected isKindOfClass:NSDictionary.class]) {
            if (![value isKindOfClass:NSDictionary.class]) return NO;
        }
    }
    NSArray *groups = settings[WCGroupsHomeGroupsListKey];
    if (groups) {
        if (!groups.count) return NO;
        NSSet *types = [NSSet setWithArray:@[@"all", @"friend", @"group", @"other", @"instant", @"custom"]];
        NSMutableSet *identifiers = [NSMutableSet set];
        for (id group in groups) {
            if (![group isKindOfClass:NSDictionary.class]) return NO;
            id identifier = group[@"id"], title = group[@"title"], type = group[@"type"], members = group[@"members"];
            if (![identifier isKindOfClass:NSString.class] || ![identifier length] || [identifiers containsObject:identifier]
                || ![title isKindOfClass:NSString.class] || ![title length] || ![type isKindOfClass:NSString.class] || ![types containsObject:type]) return NO;
            [identifiers addObject:identifier];
            if (members) {
                if (![members isKindOfClass:NSArray.class]) return NO;
                for (id member in members) if (![member isKindOfClass:NSString.class] || ![member length]) return NO;
            }
        }
    }
    NSDictionary *pending = settings[WCGroupsHomeGroupsPendingKey];
    for (NSString *account in pending) {
        id members = pending[account];
        if (![members isKindOfClass:NSArray.class]) return NO;
        for (id member in members) if (![member isKindOfClass:NSString.class] || ![member length]) return NO;
    }

    NSUserDefaults *defaultsStore = NSUserDefaults.standardUserDefaults;
    for (NSString *key in settings) [defaultsStore setObject:settings[key] forKey:key];
    WCGroupsSettingsPostChange(nil);
    return YES;
}

@interface WCGroupsPluginSettingsController : UITableViewController <UIDocumentPickerDelegate>
@end

@implementation WCGroupsPluginSettingsController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"插件设置";
    WCGroupsSettingsConfigureNavigation(self);
    self.tableView.backgroundColor = UIColor.systemGroupedBackgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 52;
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 0;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 12)];
    self.tableView.tableFooterView = WCGroupsSettingsFooter(self.tableView.bounds.size.width);
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)table { return 2; }
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section { return section == 0 ? 2 : 3; }
- (CGFloat)tableView:(UITableView *)table heightForHeaderInSection:(NSInteger)section { return 0; }
- (CGFloat)tableView:(UITableView *)table heightForFooterInSection:(NSInteger)section { return 0; }
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)path {
    UITableViewCell *cell = WCGroupsSettingsCardCell(table, nil, UITableViewCellStyleValue1, path);
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    if (path.section == 0) {
        cell.textLabel.text = @[@"导出配置", @"导入配置"][path.row];
        cell.imageView.image = [UIImage systemImageNamed:@[@"square.and.arrow.up", @"square.and.arrow.down"][path.row]];
        cell.imageView.tintColor = UIColor.systemBlueColor;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.textLabel.text = @[@"版本", @"联系作者", @"项目地址"][path.row];
        cell.detailTextLabel.text = @[@"1.0.0", @"cc", @"GitHub"][path.row];
        cell.accessoryType = path.row ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        if (!path.row) cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}
- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)path {
    [table deselectRowAtIndexPath:path animated:YES];
    if (path.section == 1) {
        NSString *url = path.row == 1 ? @"https://qm.qq.com/q/ijROto4Oqc" : @"https://github.com/qiu7c/WCGroups";
        if (path.row) [UIApplication.sharedApplication openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
        return;
    }
    if (path.row == 1) {
        UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[UTTypeJSON] asCopy:YES];
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
        return;
    }
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    for (NSString *key in WCGroupsDefaultSettings()) settings[key] = [NSUserDefaults.standardUserDefaults objectForKey:key];
    NSDictionary *document = @{@"plugin":@"WCGroups", @"format":@1, @"version":@"1.0.0", @"settings":settings};
    NSData *data = [NSJSONSerialization dataWithJSONObject:document options:NSJSONWritingPrettyPrinted | NSJSONWritingSortedKeys error:nil];
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"WCGroups-config.json"]];
    if (!data || ![data writeToURL:url options:NSDataWritingAtomic error:nil]) {
        [WCGroupsLocalPopup showMessage:@"导出失败" message:nil];
        return;
    }
    UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    share.popoverPresentationController.sourceView = table;
    share.popoverPresentationController.sourceRect = [table rectForRowAtIndexPath:path];
    [self presentViewController:share animated:YES completion:nil];
}
- (void)documentPicker:(UIDocumentPickerViewController *)picker didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSData *data = [NSData dataWithContentsOfURL:urls.firstObject];
    BOOL success = WCGroupsImportConfiguration(data);
    dispatch_async(dispatch_get_main_queue(), ^{
        [WCGroupsLocalPopup showMessage:success ? @"配置已导入" : @"导入失败" message:success ? nil : @"请选择此插件导出的有效配置文件"];
    });
}
@end

UIViewController *WCGroupsCreatePluginSettingsController(void) {
    WCGroupsPluginSettingsController *controller = [[WCGroupsPluginSettingsController alloc] initWithStyle:UITableViewStylePlain];
    controller.hidesBottomBarWhenPushed = YES;
    return controller;
}

UIView *WCGroupsSettingsFooter(CGFloat width) {
    UILabel *footer = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 56)];
    footer.text = @"WCGroups by cc\n1.0.0";
    footer.numberOfLines = 2;
    footer.textAlignment = NSTextAlignmentCenter;
    footer.font = [UIFont systemFontOfSize:12];
    footer.textColor = UIColor.secondaryLabelColor;
    footer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    return footer;
}
