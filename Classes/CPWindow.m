//
//  SearchWindow.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/14/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "CPWindow.h"
#import "CPSearchWindowView.h"
#import "CPCodePilotConfig.h"
#import "CPNoProjectOpenWindowView.h"
#import "CPXcodeVersionUnsupportedWindowView.h"
#import "CPFirstRunWindowView.h"
#import "CPXcodeWrapper.h"

@implementation CPWindow
- (id)initWithDefaultSettings
{
	return [[CPWindow alloc] initWithContentRect:NSMakeRect(100, 100, WINDOW_WIDTH, 500)
                                     styleMask:NSTitledWindowMask
                                       backing:NSBackingStoreBuffered
                                         defer:0];
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
	self = [super initWithContentRect:contentRect
                          styleMask:NSBorderlessWindowMask
                            backing:bufferingType
                              defer:flag];
  
  if (self) {
    [self setBackgroundColor:[NSColor clearColor]];
    [self setHasShadow:YES];
    [self setOpaque:NO];
    
    self.xcodeVersionUnsupportedWindowView = [[CPXcodeVersionUnsupportedWindowView alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
    self.noProjectOpenWindowView = [[CPNoProjectOpenWindowView alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
    self.searchWindowView = [[CPSearchWindowView alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
    self.firstRunWindowView = [[CPFirstRunWindowView alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
    
    [self setCollectionBehavior:NSWindowCollectionBehaviorMoveToActiveSpace];
  }
  
	return self;
}

- (void)firstRunOrderFront
{
	[self setContentView:self.firstRunWindowView];
	[self updateFrameWithViewRequirements];
	[self makeFirstResponder:[self contentView]];
	[super orderFront:self];
}

- (void)orderFront:(id)sender
{
  if (NO_PROJECT_IS_CURRENTLY_OPEN) {
    [self setContentView:self.noProjectOpenWindowView];
  } else {
    [self setContentView:self.searchWindowView];
    [self.searchWindowView layoutSubviews];
  }
  
	[self updateFrameWithViewRequirements];
	[self makeFirstResponder:[self contentView]];
	[super orderFront:sender];
}

- (NSScreen *)destinationScreen
{
  NSScreen *xCodeCurrentScreen = [[[CPCodePilotPlugin sharedInstance] xcWrapper] currentScreen];
  
  return xCodeCurrentScreen ?: [NSScreen mainScreen];
}

- (void)updateFrameWithViewRequirements
{
  [self updateFrameWithViewRequirementsWithAnimation:NO];
}

- (void)updateFrameWithViewRequirementsWithAnimation:(BOOL)animation
{
	NSSize viewWindowSizeRequirements = [self.contentView windowFrameRequirements];
  
	CGFloat newXorigin = [self destinationScreen].frame.origin.x + ([self destinationScreen].frame.size.width - viewWindowSizeRequirements.width) / 2.0;
	CGFloat newYorigin = [self destinationScreen].frame.origin.y + (([self destinationScreen].frame.size.height * (1 - WINDOW_TOP_LOCATION_ON_THE_SCREEN)) -
                                                                  viewWindowSizeRequirements.height);
  
  NSRect newWindowFrame = NSMakeRect(newXorigin,
                                     newYorigin,
                                     viewWindowSizeRequirements.width,
                                     viewWindowSizeRequirements.height);
  
	[self setFrame:newWindowFrame display:YES animate:animation];
}

// Normally windows with the NSBorderlessWindowMask can't become the key window
- (BOOL)canBecomeKeyWindow
{
  return YES;
}
@end
