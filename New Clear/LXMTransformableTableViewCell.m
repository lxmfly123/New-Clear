//
// Created by FLY.lxm on 2016.9.21.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import "LXMTransformableTableViewCell.h"
#import "LXMGlobalSettings.h"
#import "UIColor+LXM.h"
#import "LXMTableViewState.h"

CG_INLINE CGFloat LXMTransformRotationFromHeights(CGFloat h1, CGFloat h2, CGFloat n) {

  CGFloat angle = 0;
  CGFloat part1 = sqrtf(powf(h1, 2) * (powf(h2, 2) - pow(n, 2)) + (powf(h2, 2) * powf(n, 2)));
  CGFloat part2 = h1 * h2;
  CGFloat part3 = n * (h1 + h2);
  angle = 2 * atanf((part1 - part2) / part3);
  return angle;
} ///< 根据变换后的高度反解出变换的角度，见 http://lxm9.com/2016/08/15/update-cell-with-customized-layout/。


// Unfolding Style Cell

@interface LXMUnfoldingTransformableTableViewCell ()

@property (nonatomic, weak) LXMGlobalSettings *globalSettings;

@end

@implementation LXMUnfoldingTransformableTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.contentView.layer.sublayerTransform = self.globalSettings.addingTransform3DIdentity;

    self.transformable1HalfView = [[UIView alloc] initWithFrame:self.bounds];
    self.transformable1HalfView.layer.anchorPoint = CGPointMake(0.5, 0);
    self.transformable1HalfView.clipsToBounds = YES;
    [self.contentView addSubview:self.transformable1HalfView];

    self.transformable2HalfView = [[UIView alloc] initWithFrame:self.bounds];
    self.transformable2HalfView.layer.anchorPoint = CGPointMake(0.5, 1);
    self.transformable2HalfView.clipsToBounds = YES;
    [self.contentView addSubview:self.transformable2HalfView];

    // 非常重要：self.backgroundColor 不能为透明，否则在动画过程中会行之间有大概率会产生细黑条
    self.backgroundColor = [UIColor blackColor];
    self.tintColor = [UIColor whiteColor];

    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.textColor = [UIColor whiteColor];

    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    // 这句是本次重构时加的，如果有问题可以删去。
    self.textLabel.textColor = [UIColor whiteColor];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }

  return self;
}

#pragma mark - layout

- (void)layoutTransformableViews {

  CGSize contentViewSize = self.contentView.frame.size;
  CGFloat labelHeight = self.finishedHeight / 2;
  CGFloat h1 = contentViewSize.height <= self.finishedHeight ? contentViewSize.height / 2 : labelHeight;
  CGFloat fraction = 2 * h1 / self.finishedHeight;

  CGFloat angle = LXMTransformRotationFromHeights(h1, labelHeight, ABS(1.0 / self.contentView.layer.sublayerTransform.m34));

  self.transformable1HalfView.backgroundColor = [self.tintColor lxm_colorWithBrightnessComponent:0.3f + 0.7f * fraction];
  self.transformable2HalfView.backgroundColor = [self.tintColor lxm_colorWithBrightnessComponent:0.5f + 0.5f * fraction];

  self.transformable1HalfView.frame = CGRectMake(0, contentViewSize.height / 2 - h1, contentViewSize.width, labelHeight + 0.5);
  self.transformable2HalfView.frame = CGRectMake(0, contentViewSize.height / 2 - (labelHeight - h1), contentViewSize.width, labelHeight);

  self.transformable1HalfView.layer.transform = CATransform3DMakeRotation(angle, -1, 0, 0);
  self.transformable2HalfView.layer.transform = CATransform3DMakeRotation(angle, 1, 0, 0);
}

- (void)layoutTextLabels {

  CGSize contentViewSize = self.contentView.frame.size;

  if ([self.textLabel.text length] > 0) {
    self.detailTextLabel.text = self.textLabel.text;
    self.detailTextLabel.font = self.textLabel.font;
    self.detailTextLabel.textColor = self.textLabel.textColor;
    self.detailTextLabel.textAlignment = self.textLabel.textAlignment;
  }

  self.textLabel.frame = CGRectMake(self.globalSettings.textFieldLeftMargin + self.globalSettings.textFieldLeftPadding,
    0,
    contentViewSize.width - 20.0f,
    self.finishedHeight);
  self.detailTextLabel.frame = CGRectOffset(self.textLabel.frame, 0, -self.finishedHeight / 2);
}

- (void)layoutSubviews {

  [super layoutSubviews];
  [self layoutTransformableViews];
  [self layoutTextLabels];
}

#pragma mark - getters

- (LXMGlobalSettings *)globalSettings {

  return [LXMGlobalSettings sharedInstance];
}

- (UILabel *)textLabel {

  UILabel *label = [super textLabel];

  if ([label superview] != self.transformable1HalfView) {
    [self.transformable1HalfView addSubview:label];
  }
  return label;
}

- (UILabel *)detailTextLabel {

  UILabel *label = [super detailTextLabel];

  if ([label superview] != self.transformable2HalfView) {
    [self.transformable2HalfView addSubview:label];
  }

  return label;
}

@end

// Flipping Style Cell

@interface LXMFlippingTransformableTableViewCell ()

@property (nonatomic, weak) LXMGlobalSettings *globalSettings;

@end

@implementation LXMFlippingTransformableTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

  return [self initWithStyle:style anchorPoint:(CGPoint){0.5, 1.0} reuseIdentifier:reuseIdentifier];
}

- (instancetype)initWithAnchorPoint:(CGPoint)anchorPoint reuseIdentifier:(NSString *)reuseIdentifier {

  return [self initWithStyle:UITableViewCellStyleDefault anchorPoint:anchorPoint reuseIdentifier:reuseIdentifier];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style anchorPoint:(CGPoint)anchorPoint reuseIdentifier:(NSString *)reuseIdentifier {

  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    self.contentView.layer.sublayerTransform = self.globalSettings.addingTransform3DIdentity;
    self.transformableView = [[UIView alloc] initWithFrame:self.bounds];
    self.transformableView.layer.anchorPoint = anchorPoint;
    self.transformableView.clipsToBounds = YES;
    [self.contentView addSubview:self.transformableView];

    // 非常重要：self.backgroundColor 不能为透明，否则在动画过程中会row之间有大概率会产生细黑条
    self.backgroundColor = [UIColor blackColor];
    self.tintColor = [UIColor whiteColor];

    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.textColor = [UIColor whiteColor];

    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }

  return self;
}

#pragma mark - layout

- (void)layoutTransformableView {

  CGSize contentViewSize = self.contentView.frame.size;
  CGFloat labelHeight = self.finishedHeight;
  CGFloat h1 = contentViewSize.height <= self.finishedHeight ? contentViewSize.height : self.finishedHeight;
  CGFloat angle = LXMTransformRotationFromHeights(h1, labelHeight, ABS(1.0 / self.contentView.layer.sublayerTransform.m34));
  CGFloat fraction = h1 / self.finishedHeight;

  self.transformableView.backgroundColor = [self.tintColor lxm_colorWithBrightnessComponent:0.5f + 0.5f * fraction];
  self.transformableView.frame = self.transformableView.layer.anchorPoint.y < 0.5f ?
    CGRectMake(0, 0, contentViewSize.width, labelHeight) :
    CGRectMake(0, h1 - labelHeight, contentViewSize.width, labelHeight);
  self.transformableView.layer.transform = CATransform3DMakeRotation(angle, self.transformableView.layer.anchorPoint.y < 0.5f ? -1 : 1, 0, 0);
}

- (void)layoutTextLabel {

  CGSize contentViewSize = self.contentView.frame.size;

  self.textLabel.frame =
    CGRectMake(self.globalSettings.textFieldLeftMargin +self.globalSettings.textFieldLeftPadding,
      0,
      contentViewSize.width - 20.0f,
      self.finishedHeight);
}

- (void)layoutSubviews {

  [super layoutSubviews];
  [self layoutTransformableView];
  [self layoutTextLabel];
}

#pragma mark - getters

- (UILabel *)textLabel {

  UILabel *label = [super textLabel];
  if ([label superview] != self.transformableView) {
    [self.transformableView addSubview:label];
  }

  return label;
}

- (LXMGlobalSettings *)globalSettings {

  return [LXMGlobalSettings sharedInstance];
}

@end

// super class

@implementation LXMTransformableTableViewCell

+ (instancetype)transformableTableViewCellWithStyle:(LXMTransformableTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

  LXMTransformableTableViewCell *cell;

  switch (style) {
    case LXMTransformableTableViewCellStyleUnfolding:
      cell = [[LXMUnfoldingTransformableTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                           reuseIdentifier:reuseIdentifier];
      break;

    case LXMTransformableTableViewCellStyleBottomFixed:
      cell = [[LXMFlippingTransformableTableViewCell alloc] initWithAnchorPoint:(CGPoint){0.5, 1.0} reuseIdentifier:reuseIdentifier];
      break;

    case LXMTransformableTableViewCellStyleTopFixed:
      cell = [[LXMFlippingTransformableTableViewCell alloc] initWithAnchorPoint:(CGPoint){0.5, 0.0} reuseIdentifier:reuseIdentifier];
      break;
  }

  return cell;
}

#pragma mark - getters

- (CGFloat)finishedHeight {

  return [LXMGlobalSettings sharedInstance].normalRowHeight;
}

@end