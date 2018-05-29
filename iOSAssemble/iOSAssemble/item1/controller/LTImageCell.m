//
//  LTImageCell.m
//  iOSAssemble
//
//  Created by liutong on 2018/5/29.
//  Copyright © 2018年 liutong. All rights reserved.
//

#import "LTImageCell.h"

@interface LTImageCell ()
@property (strong, nonatomic)  UIImageView *iconView;
@property (strong, nonatomic)  UILabel *nameLabel;
@property (strong, nonatomic)  UILabel *downloadLabel;
@end

@implementation LTImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 0, 65, 65)];
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(28+65, 14, 100, 30)];
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.nameLabel];
    }
    return self;
}

- (void)setModel:(LTImageCellModel *)model {
    _model = model;
}
@end
