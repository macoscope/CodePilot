//
//  SelectedObjectCell.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/28/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "CPSelectedObjectCell.h"
#import "CPCodePilotConfig.h"
#import "NSView+RoundedFrame.h"

@implementation CPSelectedObjectCell
- (id)init
{
	self = [super init];
  
  if (self) {
    self.stringAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                             [NSFont fontWithName:SEARCHFIELD_TOKEN_FONT
                                             size:SEARCHFIELD_TOKEN_FONT_SIZE], NSFontAttributeName,
                             [NSColor clearColor], NSBackgroundColorAttributeName,
                             SEARCHFIELD_TOKEN_FONT_COLOR, NSForegroundColorAttributeName, nil];
  }
  
	return self;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
}

- (NSRect)cellFrameForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(NSRect)lineFrag glyphPosition:(NSPoint)position characterIndex:(NSUInteger)charIndex
{
	NSSize sizeForString = [[self title] sizeWithAttributes:self.stringAttributes];
  
	return NSMakeRect(0, 0, sizeForString.width + SEARCHFIELD_TOKEN_INSIDE_MARGIN*2, sizeForString.height);
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView characterIndex:(NSUInteger)charIndex layoutManager:(NSLayoutManager *)layoutManager
{
	[NSView drawRoundedFrame:cellFrame
								withRadius:6
					 filledWithColor:SEARCHFIELD_TOKEN_BACKGROUND_COLOR];
  
	cellFrame.origin.x += SEARCHFIELD_TOKEN_INSIDE_MARGIN;
  
	[[self title] drawInRect:cellFrame withAttributes:self.stringAttributes];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)aView characterIndex:(NSUInteger)charIndex
{
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)aView
{
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)aTextView atCharacterIndex:(NSUInteger)charIndex untilMouseUp:(BOOL)flag
{
	return NO;
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)aTextView untilMouseUp:(BOOL)flag
{
	return NO;
}

- (BOOL)wantsToTrackMouse
{
	return NO;
}

- (BOOL)wantsToTrackMouseForEvent:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView atCharacterIndex:(NSUInteger)charIndex
{
	return NO;
}

- (NSCellType)type
{
	return NSTextCellType;
}

- (NSImage *)image
{
	return nil;
}

- (BOOL)importsGraphics
{
	return YES;
}
@end
