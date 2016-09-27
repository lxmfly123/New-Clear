//
// Created by FLY.lxm on 2016.9.19.
// Copyright (c) 2016 FLY. All rights reserved.
//

#import "UIColor+LXM.h"

@implementation UIColor (LXM)

+ (instancetype)lxm_colorBetweenColor:(UIColor *)startColor endColor:(UIColor *)endColor withPercentage:(CGFloat)percentage {

  UIColor *color;
  CGFloat startHue, endHue, hue, saturation, brightness, alpha;

  [startColor getHue:&startHue saturation:&saturation brightness:&brightness alpha:&alpha];
  [endColor getHue:&endHue saturation:&saturation brightness:&brightness alpha:&alpha];

  hue = startHue + percentage * (endHue - startHue);
  color = [UIColor colorWithHue:hue
                     saturation:saturation
                     brightness:brightness
                          alpha:alpha];

  return color;
}

- (instancetype)lxm_colorWithBrightnessComponent:(CGFloat)brightnessComponent {

  UIColor *color;
  CGFloat hue, saturation, brightness, alpha;

  if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
    color = [UIColor colorWithHue:hue
                       saturation:saturation
                       brightness:brightness * brightnessComponent
                            alpha:alpha];
  }

  return color;
}

- (instancetype)lxm_colorWithBrightnessOffset:(CGFloat)brightnessOffset {

  UIColor *color;
  CGFloat hue, saturation, brightness, alpha;

  if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
    color = [UIColor colorWithHue:hue
                       saturation:saturation
                       brightness:brightness + brightnessOffset
                            alpha:alpha];
  }

  return color;
}

- (UIColor *)lxm_colorWithHueOffset:(CGFloat)hueOffset {

  UIColor *color;
  CGFloat hue, saturation, brightness, alpha;

  if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
    hue = fmodf(hue + hueOffset, 1);
    color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
  }

  return color;
}

@end