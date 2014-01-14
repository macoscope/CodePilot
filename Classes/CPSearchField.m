//
//  SearchField.m
//  CodePilot
//
//  Created by Zbigniew Sobiecki on 2/27/10.
//  Copyright 2010 Macoscope. All rights reserved.
//

#import "CPSearchField.h"
#import "CPCodePilotConfig.h"
#import "CPSearchController.h"
#import "CPSelectedObjectCell.h"
#import "NSView+RoundedFrame.h"
#import "CPStatusLabel.h"
#import "CPSymbol.h"
#import "CPSearchFieldTextView.h"

static NSString * const SelectedObjectKeyPath = @"selectedObject";

@implementation CPSearchField
- (CPSearchField *)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
  
  if (self) {
    [self setDrawsBackground:NO];
    [self setContinuous:YES];
    [self setImportsGraphics:YES];
    [self setTextColor:SEARCHFIELD_FONT_COLOR];
    [self setFocusRingType:NSFocusRingTypeNone];
    
    self.delay = DEFAULT_SEARCHFIELD_DELAY_VALUE;
    
    if (nil != [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_SEARCH_INTERVAL_KEY]) {
      self.delay = [[NSUserDefaults standardUserDefaults] floatForKey:DEFAULTS_SEARCH_INTERVAL_KEY];
      USER_LOG(@"Custom user searchfield delay set to %f", self.delay);
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setAlignment:NSCenterTextAlignment];
    
    NSFont *placeholderFont = [NSFont fontWithName:SEARCHFIELD_PLACEHOLDER_FONT size:SEARCHFIELD_PLACEHOLDER_FONT_SIZE];
    
    if (nil == placeholderFont) {
      placeholderFont = [NSFont fontWithName:SEARCHFIELD_PLACEHOLDER_ALTERNATIVE_FONT size:SEARCHFIELD_PLACEHOLDER_FONT_SIZE];
    }
    
    NSDictionary *placeholderAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                           SEARCHFIELD_PLACEHOLDER_FONT_COLOR, NSForegroundColorAttributeName,
                                           paragraphStyle, NSParagraphStyleAttributeName,
                                           placeholderFont, NSFontAttributeName, nil];
    
    NSAttributedString *placeholderAttributedString = [[NSAttributedString alloc] initWithString:SEARCHFIELD_PLACEHOLDER_STRING
                                                                                      attributes:placeholderAttributes];
    
    self.placeholderTextField = [[CPStatusLabel alloc] initWithFrame:NSMakeRect(-27, 4, self.frame.size.width, self.frame.size.height)];
    [self.placeholderTextField setAttributedStringValue:placeholderAttributedString];
    
    [self addSubview:self.placeholderTextField];
    
    [self setFont:[NSFont fontWithName:SEARCHFIELD_FONT size:SEARCHFIELD_FONT_SIZE]];
    
    [self addObserver:self
           forKeyPath:SelectedObjectKeyPath
              options:0
              context:nil];
    
    [self letDelegateKnowAboutChangedQueries];
  }
  
  return self;
}

- (void)dealloc
{
  [self removeObserver:self forKeyPath:SelectedObjectKeyPath];
}

- (void)setupDelegateNotificationAboutChangedQueriesTimer
{
	if (nil != self.delegateNotificationAboutChangedQueriesTimer) {
		[self.delegateNotificationAboutChangedQueriesTimer invalidate];
	}
  
	self.delegateNotificationAboutChangedQueriesTimer = [NSTimer scheduledTimerWithTimeInterval:self.delay
																																											 target:self
																																										 selector:@selector(letDelegateKnowAboutChangedQueries)
																																										 userInfo:NULL
																																											repeats:NO];
  
	[[NSRunLoop currentRunLoop] addTimer:self.delegateNotificationAboutChangedQueriesTimer
															 forMode:NSEventTrackingRunLoopMode];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:SelectedObjectKeyPath]) {
		[self selectedObjectDidChange];
	}
}

- (void)selectedObjectDidChange
{
	if (self.selectedObject) {
		NSTextAttachment *at = [[NSTextAttachment alloc] initWithFileWrapper:nil];
		CPSelectedObjectCell *attachCell = [[CPSelectedObjectCell alloc] init];
    
		[attachCell setTitle:[self.selectedObject name]];
		[attachCell setAttachment:at];
		[at setAttachmentCell: attachCell];
    
		NSMutableAttributedString *as = [[NSAttributedString attributedStringWithAttachment: at] mutableCopy];
    
		[self setStringValue:@" "];
		NSMutableAttributedString *currentSpace = [[self attributedStringValue] mutableCopy];
    
		// by default, text after the attachment gets lowered baseline, to start where the icon starts
		[currentSpace addAttribute:NSBaselineOffsetAttributeName
												 value:[NSNumber numberWithFloat:3.0]
												 range:NSMakeRange(0, [currentSpace length])];
    
		[as appendAttributedString:currentSpace];
		[self setAttributedStringValue:as];
    
		self.symbolQuery = nil;
	}
}

- (void)reset
{
	[self setStringValue:@""];
  
	self.fileQuery = nil;
	self.symbolQuery = nil;
	self.selectedObject = nil;
}

- (BOOL)cmdBackspaceKeyDown
{
  if (nil != self.selectedObject) {
    if (!IsEmpty(self.symbolQuery)) {
      // redo current symbol with empty query string when user
      // presses cmd-backspace in in-file-symbol-query-mode
      [self selectedObjectDidChange];
    } else {
      // cmd-backspace when only file attachment is visible
      // in query results with total reset of the query
      [self reset];
    }
    
    [self textDidChange:nil];
    return YES;
	}
  
  return NO; // not handled here
}

// called from SearchFieldTextView
- (BOOL)spaceKeyDown
{
	if ([self delegate] && [[self delegate] respondsToSelector:@selector(spacePressedForSearchField:)]) {
		return [(CPSearchController *)[self delegate] spacePressedForSearchField:self];
	}
  
	return NO; // not handled here.
}

// programmatic setting of the search query
- (void)pasteString:(NSString *)str
{
	[(CPSearchFieldTextView *)[self currentEditor] pasteString:str];
}

- (void)textDidChange:(NSNotification *)aNotification
{
	[self setupDelegateNotificationAboutChangedQueriesTimer];
  
	if (self.selectedObject) {
		// stripping funny ascii representations of text attachments
		NSString *strValue = [self stringValue];
		NSMutableString *tmpString = [NSMutableString new];
		
		for (NSInteger i = 0; i < [strValue length]; i++) {
			unichar ch = [strValue characterAtIndex:i];
			if (ch == ' ' || [[NSCharacterSet alphanumericCharacterSet] characterIsMember:ch]) {
				[tmpString appendFormat:@"%c", ch];
			}
		}
    
		// backspace pressed where the situation was: "[object] "
		if (0 == [tmpString length]) {
			self.symbolQuery = nil;
      self.stringValue = self.fileQuery;
			self.selectedObject = nil;
		} else {
			self.symbolQuery = [tmpString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		}
	} else {
		self.fileQuery = [self stringValue];
		self.symbolQuery = nil;
	}
}

- (void)letDelegateKnowAboutChangedQueries
{
	if ([self delegate] && [[self delegate] respondsToSelector:@selector(noteQueriesChanged)] &&
      (!((CPSearchFieldTextView *)[self currentEditor]).someKeyIsDown)) {
		[self.delegate performSelector:@selector(noteQueriesChanged)];
	}
}

- (id)copyWithZone:(NSZone *)zone
{
  CPSearchField *newSelf = [[self class] new];
  
	[newSelf disableObservers];
	newSelf.fileQuery = self.fileQuery;
	newSelf.symbolQuery = self.symbolQuery;
	newSelf.selectedObject = self.selectedObject;
  
	return newSelf;
}

- (void)disableObservers
{
	[self removeObserver:self forKeyPath:SelectedObjectKeyPath];
}

// nil capable! super-power!
- (void)setStringValue:(NSString *)str
{
  [super setStringValue:str ?: @""];
}

- (void)drawRect:(NSRect)dirtyRect
{
  [self.placeholderTextField setHidden:!IsEmpty([self stringValue])];
}
@end