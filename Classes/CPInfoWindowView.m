//
//  CPInfoWindowView.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 3/11/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "CPInfoWindowView.h"
#import "CPCodePilotConfig.h"
#import "CPStatusLabel.h"
#import "NSAttributedString+Hyperlink.h"
#import <Carbon/Carbon.h>

@implementation CPInfoWindowView
- (id)initWithFrame:(NSRect)frame
{
  self = [super initWithFrame:frame];
  
  if (self) {
    self.cornerRadius = CORNER_RADIUS;
    self.backgroundColor = BACKGROUND_COLOR;
    
    [self setupInfoLabel];
  }
  
  return self;
}

- (void)setupInfoLabel
{
  CGFloat infoLabelfontSize = [NSFont systemFontSize] + 2;
  
  self.infoLabel = [[CPStatusLabel alloc] initWithFrame:NSMakeRect(WINDOW_MARGIN,
                                                                   WINDOW_MARGIN,
                                                                   INFO_WINDOW_WIDTH / 2.0 - (WINDOW_MARGIN * 2) + 10,
                                                                   INFO_WINDOW_HEIGHT - (WINDOW_MARGIN * 2))];
  
	[self.infoLabel setFont:[[NSFontManager sharedFontManager] convertFont:[NSFont systemFontOfSize:infoLabelfontSize] toHaveTrait:NSBoldFontMask]];
	[self.infoLabel setTextColor:[NSColor whiteColor]];
  
	[self addSubview:self.infoLabel];
}

- (void)drawProductLogo
{
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	NSString *iconPath = [myBundle pathForResource:@"CodePilotIcon" ofType:@"icns"];
	NSImage *icon = [[NSImage alloc] initWithContentsOfFile:iconPath];
  
	NSRect dstRect = {INFO_WINDOW_WIDTH / 2.0 + WINDOW_MARGIN + 10, 0, 128, 128};
	NSRect srcRect = {0, 0, [icon size]};
  
	[icon drawInRect:dstRect
					fromRect:srcRect
				 operation:NSCompositeSourceOver
					fraction:1.0f];
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
  
	[self drawProductLogo];
}

- (NSSize)windowFrameRequirements
{
	return NSMakeSize(INFO_WINDOW_WIDTH, INFO_WINDOW_HEIGHT);
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{
	if (kVK_Escape == [theEvent keyCode]) {
		[PILOT_WINDOW_DELEGATE hideWindow];
	}
}

- (void)mouseDown:(NSEvent *)theEvent
{
	if (nil != self.clickUrl) {
		[[NSWorkspace sharedWorkspace] openURL:self.clickUrl];
	} else {
		[super mouseDown:theEvent];
	}
}
@end
