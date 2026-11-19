#import "Sources/API/Internal.h"

@interface WCGroupsLocalContactPickerCell : UITableViewCell
@property (nonatomic, copy) NSString *username;
@property (nonatomic, strong) UIView *avatar;
@end
@implementation WCGroupsLocalContactPickerCell
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat scale=WCGroupsSettingsScaleFactor(), size=40*scale;
    self.avatar.frame=CGRectMake(16*scale,(self.contentView.bounds.size.height-size)/2,size,size);
    CGFloat x=CGRectGetMaxX(self.avatar.frame)+12*scale;
    self.textLabel.frame=CGRectMake(x,0,MAX(0,self.contentView.bounds.size.width-x-16*scale),self.contentView.bounds.size.height);
    self.textLabel.numberOfLines=1;
    self.textLabel.lineBreakMode=NSLineBreakByTruncatingTail;
}
@end
UITableViewCell *WCGroupsContactPickerCell(UITableView *table, NSString *username, NSString *title) {
    WCGroupsLocalContactPickerCell *cell=[table dequeueReusableCellWithIdentifier:@"wcgroups.contact"];
    if (!cell) cell=[[WCGroupsLocalContactPickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"wcgroups.contact"];
    if (![cell.username isEqual:username]) {
        [cell.avatar removeFromSuperview];cell.username=username;
        cell.avatar=WCGroupsContactAvatarView(username);cell.avatar.userInteractionEnabled=NO;
        cell.avatar.layer.cornerRadius=8*WCGroupsSettingsScaleFactor();cell.avatar.clipsToBounds=YES;
        [cell.contentView addSubview:cell.avatar];
    }
    cell.textLabel.text=title;cell.textLabel.font=[UIFont systemFontOfSize:15*WCGroupsSettingsScaleFactor()];
    cell.backgroundColor=UIColor.secondarySystemGroupedBackgroundColor;cell.tintColor=UIColor.systemBlueColor;
    [cell setNeedsLayout];return cell;
}
