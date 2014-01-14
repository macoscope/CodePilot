//
//  SearchFieldTextView.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/27/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "CPSearchFieldTextView.h"
#import "CPCodePilotConfig.h"
#import "CPSearchField.h"

static const CGSize TextContainerInset = (NSSize){5, 0};
enum {
  BackspaceCharacter = '\x7f',
  SpaceCharacter = ' '
};

@implementation CPSearchFieldTextView
- (id)init
{
	self = [super init];
  
  if (self) {
    [self setContinuousSpellCheckingEnabled:NO];
    [self setUsesFontPanel:NO];
    [self setRichText:NO];
    [self setInsertionPointColor:SEARCHFIELD_FONT_COLOR];
    [self setTextContainerInset:TextContainerInset];
    
    self.someKeyIsDown = NO;
  }
  
	return self;
}

- (void)keyDown:(NSEvent *)theEvent
{
  // we record key as pressed unless it has cmd pressed with it as well.
  // cmd-backspace for example doesn't cause keyUp to be called later on,
  // so we're left with someKeyIsDown set for the true until the next KeyDown
  if (![theEvent modifierFlags] & NSCommandKeyMask) {
    self.someKeyIsDown = YES;
  }
  
  unichar ch = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
  
  switch (ch) {
    case BackspaceCharacter:
      if ([theEvent modifierFlags] & NSCommandKeyMask) {
        if ([[self delegate] respondsToSelector:@selector(cmdBackspaceKeyDown)] && [(id)[self delegate] cmdBackspaceKeyDown]) {
          return;
        }
      }
      break;
      
    case SpaceCharacter:
      if ([[self delegate] respondsToSelector:@selector(spaceKeyDown)] && [(id)[self delegate] spaceKeyDown]) {
        return;
      }
      break;
  }
  
	[super keyDown:theEvent];
  
	// move the cursor to an end - the user is not allowed to move around freely.
	[super setSelectedRange:NSMakeRange([[self textStorage] length], 0)];
}

- (void)keyUp:(NSEvent *)theEvent
{
	self.someKeyIsDown = NO;
	[super keyUp:theEvent];
}

// prevent selection just by moving the cursor to an end
- (void)setSelectedRange:(NSRange)charRange affinity:(NSSelectionAffinity)affinity stillSelecting:(BOOL)flag
{
	if ([[self textStorage] length] == charRange.location && 0 == charRange.length) {
		[super setSelectedRange:NSMakeRange([[self textStorage] length], 0) affinity:affinity stillSelecting:flag];
	}
}

// pasting and dragging into are disabled
- (NSArray *)readablePasteboardTypes
{
  return [NSArray arrayWithObject:NSStringPboardType];
}

// insertText with some data sanitization
- (void)pasteString:(NSString *)str
{
  // trim newlines and spaces at the end and remove all other newlines
  str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
  str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
  
  [self insertText:str];
}

- (BOOL)readSelectionFromPasteboard:(NSPasteboard *)pboard type:(NSString *)type
{
  NSString *stringToBePasted = [pboard stringForType:NSStringPboardType];
  
  if (nil != stringToBePasted && stringToBePasted.length > 0) {
    [self pasteString:stringToBePasted];
    return YES;
  }
  
  return NO;
}

// disable right-click menu
- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	return nil;
}
@end