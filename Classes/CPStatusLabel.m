//
//  StatusLabel.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/20/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "CPStatusLabel.h"

@implementation CPStatusLabel
- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
  
  if (self) {
    [self setBackgroundColor:[NSColor clearColor]];
    [self setTextColor:[NSColor grayColor]];
    [self setBordered:NO];
    [self setEditable:NO];
    [self setSelectable:NO];
  }
  
	return self;
}

- (BOOL)acceptsFirstResponder
{
	return NO;
}

- (void)mouseDown:(NSEvent *)theEvent
{
	if (self.clickUrl) {
		[[NSWorkspace sharedWorkspace] openURL:self.clickUrl];
	}
}

- (CGFloat)textWidth
{
  return [[self attributedStringValue] size].width;
}
@end