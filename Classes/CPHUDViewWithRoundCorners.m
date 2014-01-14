//
//  HUDViewWithRoundCorners.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 3/11/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "CPHUDViewWithRoundCorners.h"
#import "NSView+RoundedFrame.h"

@implementation CPHUDViewWithRoundCorners
- (void)drawRect:(NSRect)rect
{
	[[NSColor clearColor] setFill];
	NSRectFill(self.frame);
  
	[NSView drawRoundedFrame:self.frame
								withRadius:self.cornerRadius
				 	 filledWithColor:self.backgroundColor];
}

- (BOOL)isOpaque
{
	return NO;
}
@end
