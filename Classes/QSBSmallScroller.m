//
//  QSSmallScroller.m
//
//  Copyright (c) 2007-2008 Google Inc. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are
//  met:
//
//    * Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above
//  copyright notice, this list of conditions and the following disclaimer
//  in the documentation and/or other materials provided with the
//  distribution.
//    * Neither the name of Google Inc. nor the names of its
//  contributors may be used to endorse or promote products derived from
//  this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
//  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
//  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
//  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
//  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "QSBSmallScroller.h"

@implementation QSBSmallScroller

// Set the width to 0 so our scrollers don't limit the size of the content area
+ (CGFloat)scrollerWidth {
  return 0;
}

 - (void)drawKnob {
  
	NSRect knobRect = NSInsetRect([self rectForPart:NSScrollerKnob], 2, 0);

  CGFloat propFraction = 1.0 - pow([self knobProportion], 10);
  // Restrict color by proportion
  // Almost complete scroll bars are nearly translucent
  
  CGFloat heightFraction = MAX(1.0 - (NSHeight(knobRect) / 128), 0.333);
  // Restrict color by height
  // Tall scrollbars are dimmer
  
  CGFloat alphaFraction = propFraction * heightFraction;
  
  NSColor *knobColor = [NSColor colorWithDeviceWhite:0.75 alpha:alphaFraction];
  [knobColor set];
  knobRect = NSInsetRect(knobRect, 3.0, 0.0);
  CGFloat width = NSWidth(knobRect) * 0.5;
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:knobRect
                                                       xRadius:width
                                                       yRadius:width];
  [path fill];
}

- (NSUsableScrollerParts)usableParts {
  return NSNoScrollerParts;
}

// Don't draw arrows
- (void)drawArrow:(NSScrollerArrow)whichArrow highlight:(BOOL)flag {
}

- (BOOL)isOpaque {
  return NO;
}

// Don't draw normal scroller parts
- (void)drawParts {
}

- (void)drawRect:(NSRect)rect {
  NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
  CGContextRef cgContext = (CGContextRef)([currentContext graphicsPort]);
  CGContextSetAlpha(cgContext, 0.75);
  CGContextBeginTransparencyLayer(cgContext, 0);
  [self drawKnob];
  CGContextEndTransparencyLayer(cgContext);
}
@end
