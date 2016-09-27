//
// Created by FLY.lxm on 2016.9.18.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LXMTableViewCell;

@interface LXMStrikeThroughText : UITextField

@property (nonatomic, weak) LXMTableViewCell *containerCell;
@property (nonatomic, strong, readonly) CALayer *strikeThroughLine;
@property (nonatomic, assign) BOOL isStrikeThrough;
@property (nonatomic, assign, readonly) CGFloat strikeThroughFullLength;
@property (nonatomic, assign) CGFloat strikeThroughLength;

@end