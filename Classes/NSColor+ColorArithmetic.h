//
//  NSColor+ColorArithmetic.h
//  CodePilot
//
//  Created by Karol Kozub on 08.08.2013.
//  Copyright (c) 2013 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (ColorArithmetic)
- (BOOL)isDark;
- (NSColor *)colorByMutliplyingComponentsBy:(CGFloat)multiplier;
@end
