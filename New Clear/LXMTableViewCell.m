//
// Created by FLY.lxm on 2016.9.18.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import "LXMTableViewCell.h"
#import "LXMGlobalSettings.h"
#import "LXMTableViewState.h"
#import "LXMStrikeThroughText.h"
#import "LXMTodoItem.h"

typedef NS_ENUM(NSUInteger, LXMTableViewRowGestureHintType) {
  LXMTableViewRowGestureHintCompletion,
  LXMTableViewRowGestureHintDeletion,
};

@interface LXMTableViewCell () <UITextFieldDelegate>

@property (nonatomic, weak) LXMGlobalSettings *globalSettings;
@property (nonatomic, weak) LXMTableViewState *tableViewState;

@property (nonatomic, strong) UILabel *gestureCompletionHintLabel;
@property (nonatomic, strong) UILabel *gestureDeletionHintLabel;
@property (nonatomic, strong) CAGradientLayer *separationLineLayer;
@property (nonatomic, assign) CGFloat gestureHintWidth;
//@property (nonatomic, strong) UIColor *lastBackgroundColor;

@end

@implementation LXMTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // self
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor blackColor];
    self.contentView.backgroundColor = [UIColor blackColor];
    self.editingState = LXMTableViewCellEditingStateNone;
    self.isModifying = NO;

    // actual content view
    self.actualContentView = [[UIView alloc] initWithFrame:CGRectNull];
    [self.contentView addSubview:self.actualContentView];

    // separate line
    self.separationLineLayer = [CAGradientLayer new];
    self.separationLineLayer.colors =
      @[(id)[UIColor colorWithWhite:1.0f alpha:0.0f].CGColor,
        (id)[UIColor colorWithWhite:1.0f alpha:0.0f].CGColor,
        (id)[UIColor clearColor].CGColor,
        (id)[UIColor colorWithWhite:0.0f alpha:0.1f].CGColor];
    self.separationLineLayer.locations = @[@0.0f, @0.01f, @0.98f, @1.0f];
    [self.actualContentView.layer addSublayer:self.separationLineLayer];

    // gesture hint labels
    self.gestureCompletionHintLabel = [self labelForGestureHint:LXMTableViewRowGestureHintCompletion];
    [self.contentView insertSubview:self.gestureCompletionHintLabel belowSubview:self.actualContentView];

    self.gestureDeletionHintLabel = [self labelForGestureHint:LXMTableViewRowGestureHintDeletion];
    [self.contentView insertSubview:self.gestureDeletionHintLabel belowSubview:self.actualContentView];

    // strike through label
    self.strikeThroughText = [[LXMStrikeThroughText alloc] initWithFrame:CGRectNull];
    self.strikeThroughText.delegate = self;
    [self.actualContentView addSubview:self.strikeThroughText];
    self.strikeThroughText.containerCell = self;
  }
  return self;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {

  return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
}

- (UILabel *)labelForGestureHint:(LXMTableViewRowGestureHintType)hintType {

  UILabel *label = [[UILabel alloc] initWithFrame:CGRectNull];
  label.backgroundColor = [UIColor blackColor];
  label.font = [UIFont boldSystemFontOfSize:self.globalSettings.gestureHintFontSize];
  label.textColor = [UIColor whiteColor];

  switch (hintType) {
    case LXMTableViewRowGestureHintCompletion:
      label.text = @"\u2713";
      [label setTextAlignment:NSTextAlignmentRight];
      break;

    case LXMTableViewRowGestureHintDeletion:
      label.text = @"\u2717";
      [label setTextAlignment:NSTextAlignmentLeft];
      break;
  }

  return label;
}

#pragma mark - layout

- (CGFloat)percentage {

  NSLog(@"%@", self.todoItem.isCompleted ? @"YES" : @"NO");

  CGFloat per = 1.0f;
  if (self.actualContentView.frame.origin.x >= 0) {
    if (self.todoItem.isCompleted) {
      per = (1 - MIN(self.actualContentView.frame.origin.x / [LXMGlobalSettings sharedInstance].editCommitTriggerWidth, 1.0f));
    } else {
      per = (MIN(self.actualContentView.frame.origin.x / [LXMGlobalSettings sharedInstance].editCommitTriggerWidth, 1.0f));
    }
  }
  NSLog(@"%f", per);
  return per;
}

- (void)layoutSubviews {

  [super layoutSubviews];

  // actual content view
  if (self.editingState == LXMTableViewCellEditingStateNone) {
    self.actualContentView.frame = self.bounds;
  }

  // separation line
  self.separationLineLayer.frame = self.actualContentView.bounds;

  // gesture hints
  [self layoutGestureHintLabels];

  // strike through text
  self.strikeThroughText.frame = CGRectMake(
    self.globalSettings.textFieldLeftMargin,
    0,
    self.bounds.size.width - self.globalSettings.textFieldLeftMargin - self.globalSettings.textFieldRightMargin,
    self.bounds.size.height
  );
  self.strikeThroughText.strikeThroughLength = self.strikeThroughText.strikeThroughFullLength * [self percentage];
  [self.strikeThroughText setNeedsLayout];
}

- (void)layoutGestureHintLabels {

  self.gestureCompletionHintLabel.frame =
    CGRectMake([self gestureHintOffset:LXMTableViewRowGestureHintCompletion].x,
      [self gestureHintOffset:LXMTableViewRowGestureHintCompletion].y,
      [self gestureHintWidth],
      self.bounds.size.height - [self gestureHintOffset:LXMTableViewRowGestureHintCompletion].y * 2);
  self.gestureCompletionHintLabel.textColor = [self gestureHintColor:LXMTableViewRowGestureHintCompletion];

  self.gestureDeletionHintLabel.frame =
    CGRectMake([self gestureHintOffset:LXMTableViewRowGestureHintDeletion].x,
      [self gestureHintOffset:LXMTableViewRowGestureHintDeletion].y,
      [self gestureHintWidth],
      self.bounds.size.height - [self gestureHintOffset:LXMTableViewRowGestureHintDeletion].y * 2);
  self.gestureDeletionHintLabel.textColor = [self gestureHintColor:LXMTableViewRowGestureHintDeletion];
}

#pragma mark - getters

- (LXMGlobalSettings *)globalSettings {

  return [LXMGlobalSettings sharedInstance];
}

- (LXMTableViewState *)tableViewState {

  return [LXMTableViewState sharedInstance];
}

- (CGFloat)gestureHintWidth {

  return [LXMGlobalSettings sharedInstance].editCommitTriggerWidth;
}

- (UIColor *)gestureHintColor:(LXMTableViewRowGestureHintType)hintType {

  UIColor *hintColor;

  switch (hintType) {
    case LXMTableViewRowGestureHintCompletion:
    {
      if (self.actualContentView.frame.origin.x >[[LXMGlobalSettings sharedInstance] editCommitTriggerWidth]) {
        hintColor = [UIColor colorWithHue:107 / 360.0f saturation:1 brightness:1 alpha:1];
      } else {
        hintColor = self.todoItem.isCompleted ? [UIColor grayColor] : [UIColor whiteColor];
      }
    }
      break;

    case LXMTableViewRowGestureHintDeletion:
    {
      if (ABS(self.actualContentView.frame.origin.x) >[[LXMGlobalSettings sharedInstance] editCommitTriggerWidth]) {
        hintColor = [UIColor colorWithHue:1 saturation:1 brightness:1 alpha:1];
      } else {
        hintColor = self.todoItem.isCompleted ? [UIColor grayColor] : [UIColor whiteColor];
      }
    }
      break;
  }

  return hintColor;
}

- (CGPoint)gestureHintOffset:(LXMTableViewRowGestureHintType)hintType {

  CGPoint hintOffset = CGPointZero;

  switch (hintType) {
    case LXMTableViewRowGestureHintCompletion:
      hintOffset = (CGPoint){MAX(self.actualContentView.frame.origin.x - self.gestureHintWidth, 0), 5};
      break;

    case LXMTableViewRowGestureHintDeletion:
      hintOffset = (CGPoint){MIN((self.bounds.size.width - self.gestureHintWidth) + (self.actualContentView.frame.origin.x + self.gestureHintWidth), self.bounds.size.width - self.gestureHintWidth), 5};
      break;
  }

  return hintOffset;
}

#pragma mark - setters

- (void)setTodoItem:(LXMTodoItem *)todoItem {

  _todoItem = todoItem;
  _strikeThroughText.text = _todoItem.text;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

  return [self.delegate tableViewCellShouldBeginTextEditing:self];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {

  [self.delegate tableViewCellDidBeginTextEditing:self];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {

  [textField resignFirstResponder];
  return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {

  return [self.delegate tableViewCellShouldEndTextEditing:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {

  self.todoItem.text = textField.text;
  [self.delegate tableViewCellDidEndTextEditing:self];
}

- (BOOL)isUserInteractionEnabled {

  return self.isModifying;
}

@end