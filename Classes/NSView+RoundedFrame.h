//
//  NSView+RoundedFrame.h
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/23/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (RoundedFrame)
+ (void)drawRoundedFrame:(NSRect)roundedFrame withRadius:(NSInteger)radius filledWithColor:(NSColor *)color;
@end