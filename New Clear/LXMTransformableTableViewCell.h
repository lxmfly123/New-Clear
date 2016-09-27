//
// Created by FLY.lxm on 2016.9.21.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LXMTransformableTableViewCellStyle) {
  LXMTransformableTableViewCellStyleUnfolding,
  LXMTransformableTableViewCellStyleBottomFixed,
  LXMTransformableTableViewCellStyleTopFixed,
};

@protocol LXMTransformableTableViewCell <NSObject>

@property (nonatomic, assign) CGFloat finishedHeight;

@end

@interface LXMTransformableTableViewCell : UITableViewCell <LXMTransformableTableViewCell>

@property (nonatomic, assign) CGFloat finishedHeight;

+ (instancetype)transformableTableViewCellWithStyle:(LXMTransformableTableViewCellStyle)style reuseIdentifier:(NSString *)identifier;

@end

@interface LXMUnfoldingTransformableTableViewCell : LXMTransformableTableViewCell <LXMTransformableTableViewCell>

@property (nonatomic, strong) UIView *transformable1HalfView;
@property (nonatomic, strong) UIView *transformable2HalfView;

@end

@interface LXMFlippingTransformableTableViewCell : LXMTransformableTableViewCell <LXMTransformableTableViewCell>

@property (nonatomic, strong) UIView *transformableView;

@end