//
//  CPResultScrollView.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 5/26/11.
//  Copyright 2011 Macoscope. All rights reserved.
//

#import "CPResultScrollView.h"

@implementation CPResultScrollView
- (void)tile
{
  [super tile];
  
  // makes clipview wider, so we get an overlay scrollbar
  for (NSView *subview in [self subviews]) {
    if ([subview isKindOfClass:[NSClipView class]]) {
      subview.frame = NSMakeRect(subview.frame.origin.x,
                                 subview.frame.origin.y,
                                 self.frame.size.width,
                                 subview.frame.size.height);
    }
  }
}
@end
