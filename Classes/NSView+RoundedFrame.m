//
//  NSView+RoundedFrame.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/23/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "NSView+RoundedFrame.h"

@implementation NSView (RoundedFrame)
+ (void)drawRoundedFrame:(NSRect)roundedFrame withRadius:(NSInteger)radius filledWithColor:(NSColor *)color
{
	[color set];
  
	[[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(roundedFrame.origin.x, roundedFrame.size.height - radius, radius, radius)
																	 xRadius:radius
																	 yRadius:radius] fill];
  
	[[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(roundedFrame.origin.x + roundedFrame.size.width - radius, roundedFrame.size.height - radius, radius, radius)
																	 xRadius:radius
																	 yRadius:radius] fill];
  
  
	[[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(roundedFrame.origin.x, roundedFrame.origin.y, radius, radius)
																	 xRadius:radius
																	 yRadius:radius] fill];
  
	[[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(roundedFrame.origin.x + roundedFrame.size.width - radius, roundedFrame.origin.y, radius, radius)
																	 xRadius:radius
																	 yRadius:radius] fill];
  
	NSRectFill(NSMakeRect(roundedFrame.origin.x, roundedFrame.origin.y + radius / 2, roundedFrame.size.width, roundedFrame.size.height - radius));
  
	NSRectFill(NSMakeRect(roundedFrame.origin.x + radius / 2, roundedFrame.size.height - radius, roundedFrame.size.width - radius, radius));
  
	NSRectFill(NSMakeRect(roundedFrame.origin.x + radius / 2, roundedFrame.origin.y, roundedFrame.size.width - radius, radius));
}
@end