//
// Created by FLY.lxm on 2016.9.18.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import "LXMStrikeThroughText.h"
#import "LXMGlobalSettings.h"
#import "LXMTableViewCell.h"
#import "LXMTodoItem.h"

@interface LXMStrikeThroughText ()

@property (nonatomic, weak) LXMGlobalSettings *globalSettings;
@property (nonatomic, assign) CGColorRef strikeThroughLineColor;
@property (nonatomic, strong, readwrite) CALayer *strikeThroughLine;
@property (nonatomic, assign, readwrite) CGFloat strikeThroughFullLength;

@end

@implementation LXMStrikeThroughText

- (instancetype)initWithFrame:(CGRect)frame {

  if (self = [super initWithFrame:frame]) {
    self.font = [UIFont systemFontOfSize:self.globalSettings.rowFontSize];
    self.isStrikeThrough = NO;
    self.returnKeyType = UIReturnKeyDone;
  }

  return self;
}

#pragma mark - layout

- (void)layoutSubviews {

  [super layoutSubviews];
  [self layoutStrikeThroughLine];
}

- (void)layoutStrikeThroughLine {

  [CATransaction begin];
  [CATransaction setDisableActions:YES];
  [CATransaction setAnimationDuration:0];

  self.strikeThroughLine.frame = CGRectMake(
    0,
    self.bounds.size.height / 2,
    self.strikeThroughLength,
    self.globalSettings.strikeThroughLineThickness
  );
  self.strikeThroughLine.backgroundColor = self.strikeThroughLineColor;

  [CATransaction commit];
}

- (CGRect)textRectForBounds:(CGRect)bounds {

  return CGRectMake(self.globalSettings.textFieldLeftPadding, bounds.origin.y, bounds.size.width, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {

  return [self textRectForBounds:bounds];
}

#pragma mark - getters

- (LXMGlobalSettings *)globalSettings {

  return [LXMGlobalSettings sharedInstance];
}

- (CALayer *)strikeThroughLine {

  if (!_strikeThroughLine) {
    _strikeThroughLine = [CALayer new];
    _strikeThroughLine.frame = CGRectNull;
    _strikeThroughLine.backgroundColor = self.strikeThroughLineColor;
    [self.layer addSublayer:_strikeThroughLine];
  }

  return _strikeThroughLine;
}

- (CGColorRef)strikeThroughLineColor {

  if (self.containerCell.todoItem.isCompleted) {
    return [UIColor grayColor].CGColor;
  } else {
    return [UIColor whiteColor].CGColor;
  }
}

- (CGFloat)strikeThroughFullLength {

  return [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}].width + 2 * self.globalSettings.textFieldLeftPadding;
}

//#pragma mark - setters

//- (void)setIsStrikeThrough:(BOOL)isStrikeThrough{
//
//  _isStrikeThrough = isStrikeThrough;
//  self.strikeThroughLine.hidden = !_isStrikeThrough;
//}

@end