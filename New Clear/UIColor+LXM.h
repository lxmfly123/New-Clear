//
// Created by FLY.lxm on 2016.9.19.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (LXM)

+ (instancetype)lxm_colorBetweenColor:(UIColor *)startColor endColor:(UIColor *)endColor withPercentage:(CGFloat)percentage;

- (instancetype)lxm_colorWithBrightnessComponent:(CGFloat)brightnessComponent;
- (instancetype)lxm_colorWithBrightnessOffset:(CGFloat)brightnessOffset;
- (UIColor *)lxm_colorWithHueOffset:(CGFloat)hueOffset;

@end