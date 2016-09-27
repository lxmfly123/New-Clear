//
// Created by FLY.lxm on 2016.9.18.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import "LXMGlobalSettings.h"
#import "UIColor+LXM.h"

NSTimeInterval const LXMTableViewRowAnimationDurationShort = 0.15;
NSTimeInterval const LXMTableViewRowAnimationDurationNormal = 0.25;
NSTimeInterval const LXMTableViewRowAnimationDurationLong = 0.50;

UIViewAnimationOptions const LXMKeyboardAnimationCurve = 7 << 16;

@interface LXMGlobalSettings ()

// size

// font & type

// color & transparency

// behaviors


@end

@implementation LXMGlobalSettings

@synthesize listBaseColor = _listBaseColor;
@synthesize itemBaseColor = _itemBaseColor;
@synthesize editingCompletedColor = _editingCompletedColor;

+ (instancetype)sharedInstance {

  static LXMGlobalSettings *singleInstance;
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    singleInstance = [LXMGlobalSettings new];
  });

  return singleInstance;
}

- (instancetype)init {

  if (self = [super init]) {
    // size
    _normalRowHeight = 60.0f;

    _textFieldLeftPadding = 6.0f;
    _textFieldLeftMargin = 10.0f;
    _textFieldRightMargin = _textFieldLeftMargin;
    _strikeThroughLineThickness = 1.0f;
    // _editCommitTriggerWidth is a calculated property.

    // font & type
    _rowFontSize = 18.0f;
    _gestureHintFontSize = 40.0f;

    // color & transparency
    // _listBaseColor is a calculated property.
    // _itemBaseColor is a calculated property.
    // _editingCompletedColor is a calculated property.
    _rowColorHueOffset = 0.1f;

    // behaviors
    // _addingTransform3DIdentity is returned by a getter method
  }

  return self;
}

- (CGFloat)editCommitTriggerWidth {

  NSString *string = @"\u2713";
  CGFloat width = [string sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:self.gestureHintFontSize]}].width + self.textFieldLeftMargin + 20;

  return width;
}

- (UIColor *)listBaseColor {

  if (!_listBaseColor) {
    _listBaseColor = [UIColor colorWithHue:0.4 saturation:0.7 brightness:0.7 alpha:1];
  }

  return _listBaseColor;
}

- (UIColor *)itemBaseColor {

  if (!_itemBaseColor) {
    _itemBaseColor = [self.listBaseColor lxm_colorWithBrightnessOffset:0.1];
  }

  return _itemBaseColor;
}

- (UIColor *)editingCompletedColor {

  if (!_editingCompletedColor) {
    CGFloat baseHue;
    [self.listBaseColor getHue:&baseHue saturation:nil brightness:nil alpha:nil];
    _editingCompletedColor = [self.listBaseColor lxm_colorWithHueOffset:baseHue - (1 - baseHue)];
//    _editingCompletedColor = [self.listBaseColor lxm_colorWithHueOffset:1 - baseHue];
  }

  return _editingCompletedColor;
}

- (CATransform3D)addingTransform3DIdentity {

  CATransform3D identity = CATransform3DIdentity;
  identity.m34 = -1 / 500.0f;

  return identity;
}

@end