//
//  NSColor+ColorArithmetic.m
//  CodePilot
//
//  Created by Karol Kozub on 08.08.2013.
//  Copyright (c) 2013 Macoscope. All rights reserved.
//

#import "NSColor+ColorArithmetic.h"

static const NSInteger NumberOfComponents = 4;
static const NSInteger NumberOfComponentsWithoutAlpha = 3;
static const CGFloat ComponentIsDarkBoundary = 0.4;

@implementation NSColor (ColorArithmetic)
- (BOOL)isDark
{
  CGFloat components[NumberOfComponents];
  
  [self getCalibratedComponents:components];
  
  for (NSInteger i = 0; i < NumberOfComponentsWithoutAlpha; i++) {
    if (components[i] >= ComponentIsDarkBoundary) {
      return NO;
    }
  }
  
  return YES;
}

- (NSColor *)colorByMutliplyingComponentsBy:(CGFloat)multiplier
{
  CGFloat components[NumberOfComponents];
  
  [self getCalibratedComponents:components];
  
  for (NSInteger i = 0; i < NumberOfComponentsWithoutAlpha; i++) {
    components[i] = MIN(1, MAX(0, components[i] * multiplier));
  }
  
  return [NSColor colorWithCalibratedRed:components[0] green:components[1] blue:components[2] alpha:components[3]];
}

- (void)getCalibratedComponents:(CGFloat *)components
{
  [[self colorUsingColorSpaceName:@"NSCalibratedRGBColorSpace"] getComponents:components];
}
@end
